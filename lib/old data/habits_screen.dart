import 'package:flutter/material.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Habits"),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text("User habits can be shown or edited here."),
      ),
    );
  }
}
