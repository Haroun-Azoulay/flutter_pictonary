import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_pictonnary/screens/home.dart';

void _deleteRoom(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final roomRef =
        FirebaseFirestore.instance.collection('rooms').doc('commonRoom');

    final messagesSnapshot = await roomRef.collection('messages').get();
    for (var doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    final drawingSnapshot = await roomRef.collection('drawings').get();
    for (var draw in drawingSnapshot.docs) {
      await draw.reference.delete();
    }

    await roomRef.delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Room deleted successfully.")));
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  } else {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("No user logged in.")));
  }
}

class Test extends StatelessWidget {
  final String arg;
  const Test({Key? key, required this.arg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(arg == "victory"
                    ? 'assets/images/wallpaper-victory.jpg'
                    : 'assets/images/wallpaper-defeat.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (arg == "victory")
                  Text('You Win.',
                      style: TextStyle(
                        fontSize: 60,
                        color: Colors.white,
                      ))
                else
                  Text('Loose, try again !',
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      )),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _deleteRoom(context),
                  child: Text('Return in home page'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
