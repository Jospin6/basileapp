import 'package:flutter/material.dart';

class EditZonePage extends StatefulWidget {
  final String zoneName;
  const EditZonePage({super.key, required this.zoneName});

  @override
  State<EditZonePage> createState() => _EditZonePageState();
}

class _EditZonePageState extends State<EditZonePage> {
  final TextEditingController _zoneNameController = TextEditingController();

  @override
  void dispose() {
    _zoneNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text(
          "Modifier la zone",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0)),
    );
  }
}