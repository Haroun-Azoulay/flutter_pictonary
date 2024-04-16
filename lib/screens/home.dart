import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_pictonnary/screens/rules.dart';
import 'package:my_pictonnary/screens/paint_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void _joinCommonRoom(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    await FirebaseFirestore.instance.collection('rooms').doc('commonRoom').set({
      'users': FieldValue.arrayUnion([
        {
          'userId': user.uid,
          'username': userData.data()!['username'],
          'joinedAt': Timestamp.now(),
        }
      ]),
    }, SetOptions(merge: true));

    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => PaintPagea()));
  } else {
    print("User not logged in.");
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper-pictonnary.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _joinCommonRoom(context),
                    child: const Text('Play', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RulesScreen()));
                    },
                    child: const Text('Rules', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
