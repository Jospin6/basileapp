import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/screens/newClientPage.dart';
import 'package:basileapp/screens/singleClientPage.dart';
import 'package:flutter/material.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Map<String, dynamic>> _clients = []; // Liste pour stocker les clients
  DatabaseHelper dbHelper = DatabaseHelper();
  SyncData syncData = SyncData();
  late SharedData sharedData;
  String? agentZone;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _fetchClients();
  }

  Future<void> loadUserData() async {
    sharedData = SharedData();
    String newAgentZone = sharedData.getAgentZone().toString();
    setState(() {
      agentZone = newAgentZone;
    });
  }

  Future<void> _fetchClients() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> clients =
        await dbHelper.getClientsByZone(agentZone!);
    setState(() {
      _clients = clients;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text("Client Page", style: TextStyle(color: Colors.white),)
        ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewClientPage(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
                ),
                child: const Text("Add Client"),
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: () async {
                    await syncData.synchronizeData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Synchronisation terminée !')),
                    );
                  },
                  icon: const Icon(Icons.sync))
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return ListTile(
                  title: Text(client['name'] ?? 'Nom non disponible'),
                  subtitle:
                      Text(client['postName'] ?? 'Post-nom non disponible'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SingleClientPage(clientID: client['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
