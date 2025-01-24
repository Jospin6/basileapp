import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/services/firebaseServices.dart';
import 'package:basileapp/widgets/tabAutreWidget.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SyncData syncData = SyncData();
  FirebaseServices firebaseServices = FirebaseServices();

  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text("Paramètres"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.black,
          tabs: const [
            Tab(text: "Infos"),
            Tab(text: "Autres"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          // Onglet Infos
          Center(child: Text("Informations générales")),
          // Onglet Autres
          TabAutreWidget()
        ],
      ),
    );
  }
}
