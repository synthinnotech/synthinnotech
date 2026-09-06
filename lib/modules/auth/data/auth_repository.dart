import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/firebase_options.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/service/chat_service.dart';

const _notConfigured = AppException(
  'Firebase is not configured yet. See SETUP.md to finish setup.',
  code: 'unavailable',
);

/// The one place that talks to Firebase Auth.
///
/// Exposes a single [changes] stream carrying the merged Auth user + Firestore
/// profile, so the rest of the app never pokes at `FirebaseAuth` directly or
/// reconciles the two by hand. There is no offline/mock mode — if Firebase is
/// unavailable the app stays signed out and every action reports it.
class AuthRepository {
  Stream<AppUser?> changes() {
    if (!Db.enabled) return Stream<AppUser?>.value(null);
    return FirebaseAuth.instance.authStateChanges().asyncExpand((fbUser) {
      if (fbUser == null) return Stream<AppUser?>.value(null);
      return Db.users.doc(fbUser.uid).snapshots().map((doc) {
        if (doc.exists && doc.data() != null) {
          return AppUser.fromJson({...doc.data()!, 'uid': fbUser.uid});
        }
        // Auth account exists but no profile yet — provision a minimal one.
        final provisional = AppUser(
          uid: fbUser.uid,
          name: fbUser.displayName?.trim().isNotEmpty == true
              ? fbUser.displayName!
              : (fbUser.email ?? 'user').split('@').first,
          email: fbUser.email ?? '',
          role: 'employee',
        );
        Db.users.doc(fbUser.uid).set(
          {...provisional.toJson(), 'created_at': Db.now},
          SetOptions(merge: true),
        );
        return provisional;
      });
    });
  }

  Future<AppUser> signIn({required String email, required String password}) {
    if (!Db.enabled) return Future.error(_notConfigured);
    return Db.guard(() async {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      unawaited(ChatService.saveMyFCMToken(uid));

      final doc = await Db.users.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromJson({...doc.data()!, 'uid': uid});
      }
      final user = AppUser(
        uid: uid,
        name: email.split('@').first,
        email: email.trim(),
        role: 'employee',
      );
      await Db.users.doc(uid).set(
        {...user.toJson(), 'created_at': Db.now},
        SetOptions(merge: true),
      );
      return user;
    });
  }

  Future<void> signOut() {
    if (!Db.enabled) return Future.value();
    return Db.guard(() => FirebaseAuth.instance.signOut());
  }

  Future<void> sendPasswordReset(String email) {
    if (!Db.enabled) return Future.error(_notConfigured);
    return Db.guard(() =>
        FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim()));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (!Db.enabled) return Future.error(_notConfigured);
    return Db.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw const AppException('You need to be signed in.',
            code: 'unauthenticated');
      }
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    });
  }

  Future<void> updateMyProfile(Map<String, dynamic> fields) {
    if (!Db.enabled) return Future.error(_notConfigured);
    return Db.guard(() async {
      final uid = Db.uid;
      if (uid == null) {
        throw const AppException('You need to be signed in.',
            code: 'unauthenticated');
      }
      await Db.users
          .doc(uid)
          .set({...fields, 'updated_at': Db.now}, SetOptions(merge: true));
    });
  }

  /// Admin: create a staff sign-in account without disturbing the admin's own
  /// session. Uses a throw-away secondary Firebase app, then the admin writes
  /// the staff profile doc (permitted for admins by the security rules). No
  /// Cloud Function required — works on the free plan.
  Future<AppUser> createStaffAccount({
    required String email,
    required String tempPassword,
    required Map<String, dynamic> profile,
  }) {
    if (!Db.enabled) return Future.error(_notConfigured);
    return Db.guard(() async {
      FirebaseApp? secondary;
      try {
        secondary = await Firebase.initializeApp(
          name: 'staffProvisioner-${DateTime.now().microsecondsSinceEpoch}',
          options: DefaultFirebaseOptions.currentPlatform,
        );
        final cred = await FirebaseAuth.instanceFor(app: secondary)
            .createUserWithEmailAndPassword(
                email: email.trim(), password: tempPassword);
        final uid = cred.user!.uid;

        await Db.users.doc(uid).set({
          ...profile,
          'email': email.trim(),
          'uid': uid,
          'created_at': Db.now,
          'created_by': Db.uid,
        }, SetOptions(merge: true));

        return AppUser.fromJson({...profile, 'uid': uid, 'email': email.trim()});
      } finally {
        await secondary?.delete();
      }
    });
  }
}
