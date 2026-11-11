import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_model.dart';
import '../services/firebase_service.dart';
import 'chat_repository.dart';

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore? _customFirestore;

  FirebaseChatRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore? get _firestore {
    if (_customFirestore != null) return _customFirestore;
    if (FirebaseService().isInitialized) {
      try {
        return FirebaseFirestore.instance;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  @override
  Stream<List<ChatThread>> streamUserChats(String userId) {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatThread.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Stream<List<ChatMessage>> streamMessages(String chatId, String currentUserId) {
    final fs = _firestore;
    if (fs == null) return Stream.value([]);
    return fs
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromMap(doc.data(), doc.id, currentUserId: currentUserId);
      }).toList();
    });
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    final fs = _firestore;
    if (fs == null) return;
    final now = DateTime.now();

    final msgRef = fs
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final message = ChatMessage(
      id: msgRef.id,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: now,
      isFromMe: true,
    );

    await msgRef.set(message.toMap());

    await fs.collection('chats').doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': now.toIso8601String(),
    });
  }

  @override
  Future<String> startOrGetChatThread({
    required String currentUserId,
    required String otherUserId,
    required String otherUserName,
    required String otherUserCollege,
    required String relatedItemId,
    required String relatedItemTitle,
  }) async {
    final fs = _firestore;
    if (fs == null) return 'chat_demo';

    final query = await fs
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc.data()['participants'] ?? []);
      if (participants.contains(otherUserId) && doc.data()['relatedItemId'] == relatedItemId) {
        return doc.id;
      }
    }

    final newThreadRef = fs.collection('chats').doc();
    final thread = ChatThread(
      id: newThreadRef.id,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserCollege: otherUserCollege,
      relatedItemId: relatedItemId,
      relatedItemTitle: relatedItemTitle,
      lastMessage: 'Chat opened',
      lastMessageTime: DateTime.now(),
      messages: const [],
    );

    final map = thread.toMap();
    map['participants'] = [currentUserId, otherUserId];

    await newThreadRef.set(map);
    return newThreadRef.id;
  }
}
