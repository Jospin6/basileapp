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
  late TabController _tabController;
  String? agentName;
  String? agentSurname;
  String? agentZone;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Trois onglets
    loadUserData();
  }


  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String? name = prefs.getString('name');
    String? surname = prefs.getString('surname');
    String? zone = prefs.getString('zone');

    if (id != null) {
      print("ID: $id, Name: $name, Surname: $surname, Zone: $zone");
      setState(() {
        agentName = name;
        agentSurname = surname;
        agentZone = zone;
      });
    } else {
      print("Aucune donnée utilisateur trouvée.");
    }
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
        title: const Text("Agent Details"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dashboard", icon: Icon(Icons.dashboard)),
            Tab(text: "Params", icon: Icon(Icons.settings)),
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenu pour chaque onglet
          _buildDashboardTab(),
          _buildParamsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard, size: 100, color: Colors.blue),
          SizedBox(height: 10),
          Text(
            "Dashboard Content",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildParamsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 100, color: Colors.green),
          SizedBox(height: 10),
          Text(
            "Params Content",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 100, color: Colors.orange),
          SizedBox(height: 10),
          Text(
            "History Content",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
