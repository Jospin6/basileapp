import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/widgets/agentDashboardTab.dart';
import 'package:basileapp/widgets/agentHistoryTab.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleAgentPage extends StatefulWidget {
  final dynamic agentID;
  const SingleAgentPage({super.key, required this.agentID});

  @override
  State<SingleAgentPage> createState() => _SingleAgentPageState();
}

class _SingleAgentPageState extends State<SingleAgentPage>
    with SingleTickerProviderStateMixin {
  DatabaseHelper dbHelper = DatabaseHelper();
  late TabController _tabController;
  late SharedData sharedData;
  String? agentName;
  String? agentSurname;
  String? agentZone;
  String? agentRole;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedData = SharedData(prefs: prefs);

    setState(() {
      agentName = sharedData.getAgentName().toString();
      agentSurname = sharedData.getAgentSurname().toString();
      agentZone = sharedData.getAgentZone().toString();
      agentRole = sharedData.getAgentRole().toString();
    });
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
        title: const Text("Agent Details"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenu pour chaque onglet
          AgentDashboardTab(
              agentID: widget.agentID,
              agentName: agentName!,
              agentSurname: agentSurname!,
              agentZone: agentZone!,
              agentRole: agentRole!),
          AgentHistoryTab(agentID: widget.agentID),
        ],
      ),
    );
  }
}
