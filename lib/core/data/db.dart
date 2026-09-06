import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../errors/app_exception.dart';

/// Thin, centralised access to Firestore.
///
/// Everything that talks to the database goes through here so that:
///  * collection names live in exactly one place,
///  * every call is wrapped with [guard] and surfaces a clean [AppException]
///    instead of the old `catch (_) {}` that hid every failure, and
///  * timestamps are read/written consistently (Firestore [Timestamp], with a
///    tolerant parser for the ISO-string data the previous version wrote).
class Db {
  const Db._();

  static FirebaseFirestore get _fs => FirebaseFirestore.instance;

  /// True when Firebase has been initialised and we should read/write for real.
  /// When false the app runs in local "demo" mode with sample data.
  static bool get enabled => Firebase.apps.isNotEmpty;

  static String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // ── Collections ──────────────────────────────────────────────────────────
  static CollectionReference<Map<String, dynamic>> get users =>
      _fs.collection('users');
  static CollectionReference<Map<String, dynamic>> get projects =>
      _fs.collection('projects');
  static CollectionReference<Map<String, dynamic>> get tasks =>
      _fs.collection('project_tasks');
  static CollectionReference<Map<String, dynamic>> get transactions =>
      _fs.collection('transactions');
  static CollectionReference<Map<String, dynamic>> get chats =>
      _fs.collection('chats');
  static CollectionReference<Map<String, dynamic>> messages(String chatId) =>
      chats.doc(chatId).collection('messages');
  static CollectionReference<Map<String, dynamic>> get notifications =>
      _fs.collection('notifications');
  static CollectionReference<Map<String, dynamic>> get announcements =>
      _fs.collection('announcements');
  static CollectionReference<Map<String, dynamic>> get notes =>
      _fs.collection('notes');
  static CollectionReference<Map<String, dynamic>> get attendance =>
      _fs.collection('attendance');
  static CollectionReference<Map<String, dynamic>> get leaveRequests =>
      _fs.collection('leave_requests');
  static DocumentReference<Map<String, dynamic>> get meta =>
      _fs.collection('_meta').doc('app');

  // ── Helpers ──────────────────────────────────────────────────────────────

  static FieldValue get now => FieldValue.serverTimestamp();

  /// Runs [action] and converts anything it throws into an [AppException].
  static Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } catch (e, st) {
      throw AppException.from(e, st);
    }
  }

  /// Wraps a Firestore stream so errors become [AppException]s downstream.
  static Stream<T> guardStream<T>(Stream<T> source) {
    return source.handleError((Object e, StackTrace st) {
      throw AppException.from(e, st);
    });
  }

  /// Tolerant timestamp reader — accepts Firestore [Timestamp], epoch millis,
  /// epoch seconds, or ISO-8601 strings (all of which exist in older docs).
  static DateTime? readDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      // Heuristic: < 10^12 → seconds, else millis.
      return value < 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(value * 1000)
          : DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.tryParse(value.toString());
  }

  static Timestamp? writeDate(DateTime? value) =>
      value == null ? null : Timestamp.fromDate(value);
}
