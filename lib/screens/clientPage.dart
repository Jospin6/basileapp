import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/screens/newClientPage.dart';
import 'package:basileapp/screens/singleClientPage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
  bool isConnect = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    _fetchClients();
    _checkConnection();
  }

  Future<void> _handleClick() async {
    setState(() {
      _isLoading = true; // Affiche le CircularProgressIndicator
    });

    // Simule une tâche asynchrone (exemple : API call)
    await Future.delayed(Duration(seconds: 10));

    setState(() {
      _isLoading = false; // Cache le loader après exécution
    });
  }

  Future<bool> checkInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // Vérifie si l'appareil est connecté au Wi-Fi ou aux données mobiles
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  Future<void> _checkConnection() async {
    final isConnected = await checkInternetConnection();

    setState(() {
      isConnect = isConnected;
    });
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
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text(
          "Client Page",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewClientPage(),
                    ),
                  ),
              icon: const Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              )),
          _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : IconButton(
                  onPressed: () async {
                    _handleClick();
                    await syncData.synchronizeData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Synchronisation terminée !')),
                    );
                  },
                  icon: const Icon(
                    Icons.sync,
                    color: Colors.white,
                    size: 30,
                  ))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(client['name'].substring(0, 1).toUpperCase()),
                    ),
                    title: Text('${client['name']} ${client['postName']}'),
                    subtitle: Text(
                        '${client['commerce']},\n télé: ${client['phone']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SingleClientPage(clientID: client['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
