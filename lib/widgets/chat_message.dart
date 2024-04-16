import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pictonnary/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    if (authenticatedUser == null) {
      return Center(child: Text(''));
    }

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('rooms')
          .doc('commonRoom')
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .snapshots(),
      builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages found.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
              child: Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 10, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            var chatMessage =
                loadedMessages[index].data() as Map<String, dynamic>;
            bool nextUserIsSame = false;
            if (index + 1 < loadedMessages.length) {
              var nextChatMessage =
                  loadedMessages[index + 1].data() as Map<String, dynamic>;
              nextUserIsSame =
                  nextChatMessage['userId'] == chatMessage['userId'];
            }

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == chatMessage['userId'],
              );
            } else {
              return MessageBubble.first(
                userImage: chatMessage['userImage'],
                username: chatMessage['username'],
                message: chatMessage['text'],
                isMe: authenticatedUser.uid == chatMessage['userId'],
              );
            }
          },
        );
      },
    );
  }
}
