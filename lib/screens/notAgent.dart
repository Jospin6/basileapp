import 'package:flutter/material.dart';

class NotAgent extends StatelessWidget {
  const NotAgent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
      child: Column(
        children: [
          Text("Vous avez été bani entant qu'agent !!!"),
          SizedBox(height: 10,),
          CircularProgressIndicator(),
        ],
      ),
    ),
    );
  }
}