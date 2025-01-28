import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/screens/editAgentPage.dart';
import 'package:basileapp/widgets/agentDashboardTab.dart';
import 'package:basileapp/widgets/agentHistoryTab.dart';
import 'package:flutter/material.dart';

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
    sharedData = SharedData();

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
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text(
          "Agent Details",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditAgentPage(agentId: widget.agentID,),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(255, 209, 208, 208),
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
