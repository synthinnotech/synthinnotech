import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:synthinnotech/model/chat/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static bool get _ready => Firebase.apps.isNotEmpty;
  static const _chats = 'chats';
  static const _messages = 'messages';
  static const _users = 'users';

  static String chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static Stream<List<ChatMessage>> messageStream(String id) {
    if (!_ready) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection(_chats)
        .doc(id)
        .collection(_messages)
        .orderBy('timestamp')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => ChatMessage.fromJson(d.data(), d.id)).toList());
  }

  // Client-side sort avoids Firestore composite index requirement.
  static Stream<List<Map<String, dynamic>>> conversationStream(String uid) {
    if (!_ready) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection(_chats)
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
      list.sort((a, b) {
        final at = a['updated_at']?.toString() ?? '';
        final bt = b['updated_at']?.toString() ?? '';
        return bt.compareTo(at);
      });
      return list;
    });
  }

  static Future<void> sendMessage({
    required String id,
    required ChatMessage message,
    required String myUid,
    required String myName,
    required String peerUid,
    required String peerName,
  }) async {
    if (!_ready) return;
    final docId = const Uuid().v4();
    await FirebaseFirestore.instance
        .collection(_chats)
        .doc(id)
        .collection(_messages)
        .doc(docId)
        .set(message.toJson());

    await FirebaseFirestore.instance.collection(_chats).doc(id).set({
      'participants': [myUid, peerUid],
      'participant_names': {myUid: myName, peerUid: peerName},
      'last_message': message.text,
      'last_sender_id': myUid,
      'updated_at': message.timestamp.toIso8601String(),
    }, SetOptions(merge: true));
  }

  static Future<void> saveMyFCMToken(String uid) async {
    if (!_ready) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance
            .collection(_users)
            .doc(uid)
            .set({'fcm_token': token}, SetOptions(merge: true));
      }
    } catch (_) {}
  }
}
