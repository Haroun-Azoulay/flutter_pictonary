import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pictonnary/widgets/chat_message.dart';
import 'package:my_pictonnary/widgets/new_message.dart';
import 'package:my_pictonnary/widgets/time.dart';
import 'package:my_pictonnary/widgets/painting_area.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaintPagea extends StatefulWidget {
  const PaintPagea({Key? key}) : super(key: key);

  @override
  _PaintPageaState createState() => _PaintPageaState();
}

class _PaintPageaState extends State<PaintPagea> {
  String? randomDrawerUserId;
  String? lastDrawerUserId;
  String? wordToGuess;

  @override
  void initState() {
    super.initState();
    prepareGameWord();
    designateDrawer();
  }

  Future<void> prepareGameWord() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference roomDocRef =
        db.collection('rooms').doc('commonRoom');

    DocumentSnapshot roomSnapshot = await roomDocRef.get();
    Map<String, dynamic>? roomData =
        roomSnapshot.data() as Map<String, dynamic>?;

    if (roomSnapshot.exists && roomData?.containsKey('currentWord') == true) {
      setState(() {
        wordToGuess = roomData?['currentWord'];
      });
      return;
    }

    var list = [
      'fly',
      'balloon',
      'dog',
      'cat',
      'tiger',
      'rabbit',
      "car",
      "girl",
      "boy"
    ];

    final _random = Random();
    wordToGuess = list[_random.nextInt(list.length)];

    await roomDocRef.set({
      'currentWord': wordToGuess,
    }, SetOptions(merge: true)).catchError((e) {
      print("Error for define word : $e");
    });
  }

  Future<void> designateDrawer() async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentReference roomDocRef =
        db.collection('rooms').doc('commonRoom');

    await db.runTransaction((transaction) async {
      DocumentSnapshot roomSnapshot = await transaction.get(roomDocRef);

      Map<String, dynamic>? data = roomSnapshot.data() as Map<String, dynamic>?;
      if (roomSnapshot.exists && data != null && data.containsKey('users')) {
        List<dynamic> users = data['users'];
        if (users.isNotEmpty) {
          users.forEach((user) {
            if (user is Map<String, dynamic>) {
              user['isDrawer'] = false;
            }
          });

          final _random = Random();
          int randomIndex;
          do {
            randomIndex = _random.nextInt(users.length);
          } while (users.length > 1 &&
              users[randomIndex]['userId'] == lastDrawerUserId);

          if (users[randomIndex] is Map<String, dynamic>) {
            Map<String, dynamic> selectedUser = users[randomIndex];
            selectedUser['isDrawer'] = true;
            lastDrawerUserId = selectedUser['userId'];
          }

          transaction.update(roomDocRef, {'users': users});
        }
      }
    }).catchError((e) {
      print("An error occurred while designating a drawer: $e");
    });

    setState(() {
      randomDrawerUserId = lastDrawerUserId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    bool isUserDrawer = authenticatedUser != null &&
        authenticatedUser.uid == randomDrawerUserId;
    bool isUserNotDrawer = !isUserDrawer;
    String displayedWord = isUserNotDrawer ? "???" : (wordToGuess ?? "");

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            text: 'Guess Word - ',
            style: TextStyle(color: Colors.white, fontSize: 20),
            children: <TextSpan>[
              TextSpan(
                text: displayedWord,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary, fontSize: 25),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 0),
          Expanded(
            child: MyTimerWidget(canNotSeeTime: isUserNotDrawer),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: PaintingArea(
                  initialColor: Colors.black, canNotDraw: isUserNotDrawer),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.black, width: 4, style: BorderStyle.solid),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/wallpaper-pictonnary.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ChatMessages(),
                  ),
                  NewMessage(
                      element: wordToGuess ?? "", canWrite: isUserNotDrawer),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
