import 'package:flutter/material.dart';
import 'dart:async';
import 'package:my_pictonnary/screens/end_game.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTimerWidget extends StatefulWidget {
  final bool canNotSeeTime;
  final arg = "loose";
  const MyTimerWidget({Key? key, this.canNotSeeTime = false}) : super(key: key);

  @override
  _MyTimerWidgetState createState() => _MyTimerWidgetState();
}

class _MyTimerWidgetState extends State<MyTimerWidget> {
  Timer? _timer;
  int _start = 120;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (context) => Test(
                    arg: widget.arg,
                  )),
        );
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;
    if (authenticatedUser == null) {
      _timer?.cancel();
      return Center(child: Text('Please log in.'));
    }

    return widget.canNotSeeTime
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Text(
                'Remaining Time : ${_start ~/ 60}:${(_start % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 20,
                  color: _start <= 30 ? Colors.red : Colors.black,
                ),
              ),
            ),
          )
        : Scaffold();
  }
}
