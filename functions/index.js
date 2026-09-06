/**
 * SynthInnoTech Cloud Functions — OPTIONAL.
 *
 * These are NOT required for the app to work. Deploying Cloud Functions needs
 * the Firebase **Blaze** (pay-as-you-go) plan. On the free **Spark** plan the
 * app already:
 *   - shows in-app notifications for new chat messages while the app is open
 *     (see MainNavigationScreen), and
 *   - creates staff sign-in accounts client-side via a throw-away secondary
 *     Firebase app (see AuthRepository.createStaffAccount).
 *
 * If you later upgrade to Blaze, deploying this function adds real push
 * notifications for chat messages received while the app is backgrounded:
 *   firebase deploy --only functions
 */

const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onNewChatMessage = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const message = event.data && event.data.data();
    if (!message) return;

    const chatId = event.params.chatId;
    const senderId = message.sender_id;
    const senderName = message.sender_name || 'Someone';
    const text = message.text || '';

    const chatDoc = await getFirestore().collection('chats').doc(chatId).get();
    if (!chatDoc.exists) return;

    const participants = chatDoc.data().participants || [];
    const recipientId = participants.find((uid) => uid !== senderId);
    if (!recipientId) return;

    const recipientDoc = await getFirestore()
      .collection('users')
      .doc(recipientId)
      .get();
    if (!recipientDoc.exists) return;

    const fcmToken = recipientDoc.data().fcm_token;
    if (!fcmToken) return;

    await getMessaging().send({
      token: fcmToken,
      notification: { title: senderName, body: text },
      data: { chat_id: chatId, sender_id: senderId, type: 'chat_message' },
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'chat_channel' },
      },
      apns: { payload: { aps: { sound: 'default', badge: 1 } } },
    });
  }
);
