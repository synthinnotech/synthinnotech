import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:synthinnotech/core/data/db.dart';
import 'package:synthinnotech/model/chat/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  static const _uuid = Uuid();

  /// Deterministic 1:1 chat id (sorted so both sides compute the same value).
  static String chatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  static Stream<List<ChatMessage>> messageStream(String id) {
    if (!Db.enabled) return const Stream.empty();
    return Db.guardStream(
      Db.messages(id).orderBy('timestamp').snapshots().map(
            (s) => s.docs
                .map((d) => ChatMessage.fromJson(d.data(), d.id))
                .toList(),
          ),
    );
  }

  /// Conversations for [uid], newest first. Sorted client-side to avoid a
  /// composite index on (participants array-contains + updated_at).
  static Stream<List<Map<String, dynamic>>> conversationStream(String uid) {
    if (!Db.enabled) return const Stream.empty();
    return Db.guardStream(
      Db.chats.where('participants', arrayContains: uid).snapshots().map((s) {
        final list = s.docs.map((d) => {...d.data(), 'id': d.id}).toList();
        list.sort((a, b) {
          final at = Db.readDate(a['updated_at']) ?? DateTime(0);
          final bt = Db.readDate(b['updated_at']) ?? DateTime(0);
          return bt.compareTo(at);
        });
        return list;
      }),
    );
  }

  static Future<void> sendMessage({
    required String id,
    required ChatMessage message,
    required String myUid,
    required String myName,
    required String peerUid,
    required String peerName,
  }) async {
    if (!Db.enabled) return;
    return Db.guard(() async {
      final batch = FirebaseFirestore.instance.batch();
      batch.set(Db.messages(id).doc(_uuid.v4()), message.toJson());
      batch.set(
        Db.chats.doc(id),
        {
          'participants': [myUid, peerUid],
          'participant_names': {myUid: myName, peerUid: peerName},
          'last_message': message.text,
          'last_sender_id': myUid,
          'updated_at': message.timestamp.toIso8601String(),
          'updated_ts': Db.now,
        },
        SetOptions(merge: true),
      );
      await batch.commit();
    });
  }

  static Future<void> saveMyFCMToken(String uid) async {
    if (!Db.enabled) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await Db.users.doc(uid).set(
          {'fcm_token': token, 'fcm_token_updated_at': Db.now},
          SetOptions(merge: true),
        );
      }
    } catch (_) {
      // Token refresh is best-effort; never block chat on it.
    }
  }
}
