import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show SetOptions;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/core/errors/app_exception.dart';
import 'package:synthinnotech/firebase_options.dart';
import 'package:synthinnotech/model/user/app_user.dart';
import 'package:synthinnotech/service/chat_service.dart';

/// The one place that talks to Firebase Auth.
///
/// It exposes a single [changes] stream that already carries the merged
/// Auth user + Firestore profile, so the rest of the app never has to poke at
/// `FirebaseAuth` or reconcile the two by hand.
class AuthRepository {
  AuthRepository() {
    if (!Db.enabled) {
      // Prime the demo stream with "signed out".
      _demoController.add(null);
    }
  }

  final _demoController = StreamController<AppUser?>.broadcast();
  AppUser? _demoUser;

  // ── Stream of the current user (or null) ────────────────────────────────
  Stream<AppUser?> changes() {
    if (!Db.enabled) {
      return _demoStream();
    }
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

  Stream<AppUser?> _demoStream() async* {
    yield _demoUser;
    yield* _demoController.stream;
  }

  AppUser? get currentSnapshot => _demoUser;

  // ── Sign in ────────────────────────────────────────────────────────────
  Future<AppUser> signIn({required String email, required String password}) {
    return Db.guard(() async {
      if (!Db.enabled) return _demoSignIn(email, password);

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
        name: (email.split('@').first),
        email: email.trim(),
        role: 'employee',
      );
      await Db.users
          .doc(uid)
          .set({...user.toJson(), 'created_at': Db.now}, SetOptions(merge: true));
      return user;
    });
  }

  AppUser _demoSignIn(String email, String password) {
    if (email.trim().isEmpty || password.length < 6) {
      throw const AppException('Enter an email and a password of 6+ characters.',
          code: 'invalid-credential');
    }
    _demoUser = AppUser(
      uid: 'demo-uid',
      name: email.contains('admin') ? 'Demo Admin' : 'Demo User',
      email: email.trim(),
      phone: '+91 90000 00000',
      role: email.contains('admin') ? 'admin' : 'employee',
      department: 'Technology',
      jobTitle: email.contains('admin') ? 'Administrator' : 'Team Member',
      isActive: true,
    );
    _demoController.add(_demoUser);
    return _demoUser!;
  }

  // ── Sign out ───────────────────────────────────────────────────────────
  Future<void> signOut() async {
    if (!Db.enabled) {
      _demoUser = null;
      _demoController.add(null);
      return;
    }
    await Db.guard(() => FirebaseAuth.instance.signOut());
  }

  // ── Password reset ─────────────────────────────────────────────────────
  Future<void> sendPasswordReset(String email) {
    if (!Db.enabled) {
      return Future.error(const AppException(
          'Password reset needs Firebase to be configured.',
          code: 'unavailable'));
    }
    return Db.guard(() =>
        FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim()));
  }

  // ── Change password (requires re-auth) ─────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
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

  // ── Update my own profile ──────────────────────────────────────────────
  Future<void> updateMyProfile(Map<String, dynamic> fields) {
    return Db.guard(() async {
      if (!Db.enabled) {
        _demoUser = _demoUser?.copyWith(
          name: fields['name'] as String?,
          phone: fields['phone'] as String?,
          department: fields['department'] as String?,
          jobTitle: fields['job_title'] as String?,
          address: fields['address'] as String?,
          gender: fields['gender'] as String?,
        );
        _demoController.add(_demoUser);
        return;
      }
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

  // ── Admin: create a staff account without being signed out ─────────────
  //
  // Uses a throw-away secondary Firebase app so the *admin's* session is
  // untouched. The admin then writes the staff profile doc (allowed by the
  // security rules for admins). No Cloud Function required.
  Future<AppUser> createStaffAccount({
    required String email,
    required String tempPassword,
    required Map<String, dynamic> profile,
  }) {
    return Db.guard(() async {
      if (!Db.enabled) {
        throw const AppException(
            'Creating staff accounts needs Firebase to be configured.',
            code: 'unavailable');
      }
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
