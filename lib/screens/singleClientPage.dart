import 'package:flutter/material.dart';

class SingleClientPage extends StatefulWidget {
  final dynamic clientID;

  const SingleClientPage({super.key, required this.clientID});

  @override
  State<SingleClientPage> createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}