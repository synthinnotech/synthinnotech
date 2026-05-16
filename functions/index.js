const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.onNewChatMessage = onDocumentCreated(
  'chats/{chatId}/messages/{messageId}',
  async (event) => {
    const message = event.data.data();
    const chatId = event.params.chatId;

    const senderId = message.sender_id;
    const senderName = message.sender_name || 'Someone';
    const text = message.text || '';

    // Get chat doc to find participants
    const chatDoc = await getFirestore()
      .collection('chats')
      .doc(chatId)
      .get();

    if (!chatDoc.exists) return;
    const chatData = chatDoc.data();

    const participants = chatData.participants || [];
    const recipientId = participants.find((uid) => uid !== senderId);
    if (!recipientId) return;

    // Get recipient's FCM token
    const recipientDoc = await getFirestore()
      .collection('users')
      .doc(recipientId)
      .get();

    if (!recipientDoc.exists) return;
    const fcmToken = recipientDoc.data().fcm_token;
    if (!fcmToken) return;

    // Send FCM push notification
    await getMessaging().send({
      token: fcmToken,
      notification: {
        title: senderName,
        body: text,
      },
      data: {
        chat_id: chatId,
        sender_id: senderId,
        type: 'chat_message',
      },
      android: {
        priority: 'high',
        notification: { sound: 'default', channelId: 'chat_channel' },
      },
      apns: {
        payload: { aps: { sound: 'default', badge: 1 } },
      },
    });
  }
);
