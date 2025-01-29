import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/widgets/adminTaxesWidget.dart';
import 'package:basileapp/widgets/agentTaxesWidget.dart';
import 'package:flutter/material.dart';

class TaxesPage extends StatefulWidget {
  const TaxesPage({super.key});

  @override
  State<TaxesPage> createState() => _TaxesPageState();
}

class _TaxesPageState extends State<TaxesPage> {
  String? agentZone;
  late SharedData sharedData;
  SyncData syncData = SyncData();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    sharedData = SharedData();

    setState(() {
      agentZone = sharedData.getAgentZone().toString();
    });
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
          "Taxes",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await syncData.fetchAndSyncTaxes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Taxes synchronisées !')),
                );
              },
              icon: const Icon(Icons.sync, color: Colors.white,))
        ],
      ),
      body: agentZone == "Admin"
          ? const AdminTaxesWidget()
          : const AgentTaxesWidget(),
    );
  }
}
