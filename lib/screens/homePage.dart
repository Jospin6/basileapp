import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/screens/agentsPage.dart';
import 'package:basileapp/screens/clientPage.dart';
import 'package:basileapp/screens/connexionPage.dart';
import 'package:basileapp/screens/settingsPage.dart';
import 'package:basileapp/screens/singleAgentPage.dart';
import 'package:basileapp/widgets/adminDashboard.dart';

import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DatabaseHelper dbHelper = DatabaseHelper();
  late SharedData sharedData;
  String? agentID;
  String? agentName;
  String? agentSurname;
  String? agentZone;
  String? agentRole;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      sharedData = SharedData();

      // Récupération des données avec des valeurs par défaut si nécessaire
      String newAgentID = sharedData.getAgentId().toString();
      String newAgentName = sharedData.getAgentName().toString();
      String newAgentSurname = sharedData.getAgentSurname().toString();
      String newAgentZone = sharedData.getAgentZone().toString();
      String newAgentRole = sharedData.getAgentRole().toString();

      print("id: $newAgentID");
      print("name: $newAgentName");
      print("sur: $newAgentSurname");
      print("zone: $newAgentZone");
      print("role: $newAgentRole");

      // Mise à jour de l'état uniquement si les valeurs changent
      setState(() {
        agentID = newAgentID;
        agentName = newAgentName;
        agentSurname = newAgentSurname;
        agentZone = newAgentZone;
        agentRole = newAgentRole;
      });
    } catch (e) {
      // Log ou gestion de l'erreur
      print("Erreur lors du chargement des données utilisateur : $e");
    }
  }

  Future<int> fetchClientCount() async {
    int clientCount = await dbHelper.getClientCount();
    return clientCount;
  }

  Future<double> fetchDailyAmount() async {
    double dailyAmount = await dbHelper.getDailyAmount();
    return dailyAmount;
  }

  Future<double> fetchDebts() async {
    double totalDebt = await dbHelper.getTotalDebt();
    return totalDebt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text(
            'Basile',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(173, 104, 0, 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/basile.jpg'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$agentName $agentSurname',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Role $agentRole',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Accueil'),
                onTap: () {
                  Navigator.pop(context); // Ferme la Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Homepage(),
                    ),
                  );
                },
              ),
              if (agentRole != "Admin")
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Clients'),
                  onTap: () {
                    Navigator.pop(context); // Ferme la Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClientPage(),
                      ),
                    );
                  },
                ),
              if (agentRole == "Admin")
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Agents'),
                  onTap: () {
                    Navigator.pop(context); // Ferme la Drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AgentsPage(),
                      ),
                    );
                  },
                ),
              if (agentRole == "Admin")
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context); // Ferme la Drawer
                    // Ajoutez une action ici
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Mon compte'),
                onTap: () {
                  Navigator.pop(context); // Ferme la Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SingleAgentPage(
                        agentID: agentID,
                      ),
                    ),
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Deconnexion'),
                onTap: () {
                  Navigator.pop(context); // Ferme la Drawer
                  sharedData = SharedData();
                  sharedData.clearSharedPreferences();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ConnexionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        body: agentRole == "Admin"
            ? const AdminDashboard()
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$agentName $agentSurname"),
                      Text("Rôle $agentRole"),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                    child: const Column(
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     _dashboardTile(
                        //         "Total Clients", "${fetchClientCount()}"),
                        //     _dashboardTile("$agentZone", null),
                        //   ],
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     _dashboardTile(
                        //         "Recolte du jour", "${fetchDailyAmount()}Fc"),
                        //     _dashboardTile("Dette Totale", "${fetchDebts()}Fc"),
                        //   ],
                        // )
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: dbHelper.fetchLatestClientsPayments(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Erreur: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                              child: Text(
                                  'Aucun paiement trouvé. role $agentRole sur $agentSurname , $agentName , $agentZone , $agentID'));
                        }

                        final payments = snapshot.data!;

                        return ListView.builder(
                          itemCount: payments.length,
                          itemBuilder: (context, index) {
                            final payment = payments[index];

                            return ListTile(
                              title: Text(
                                  'Montant Reçu: ${payment['amount_recu']} | Taxe: ${payment['taxe_name']}'),
                              subtitle: Text(
                                  'Client: ${payment['client_name']}\nDate: ${payment['created_at']}'),
                              trailing: payment['amount_recu'] < payment['amount_tot']
                                  ? const Icon(Icons.warning,
                                      color: Colors
                                          .red) // Icône d'avertissement si paiement incomplet
                                  : const Icon(Icons.check,
                                      color: Colors
                                          .green), // Icône de validation si paiement complet
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ));
  }

  // Widget pour les tuiles du dashboard
  Widget _dashboardTile(String title, dynamic value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        value != null
            ? Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
            : const Text(""),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }
}
