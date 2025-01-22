import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/paiement.dart';
import 'package:basileapp/screens/agentsPage.dart';
import 'package:basileapp/screens/clientPage.dart';
import 'package:basileapp/screens/connexionPage.dart';
import 'package:basileapp/screens/settingsPage.dart';
import 'package:basileapp/screens/singleAgentPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  String? agentID;
  String? agentName;
  String? agentSurname;
  String? agentZone;
  String? agentRole;

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String? name = prefs.getString('name');
    String? surname = prefs.getString('surname');
    String? zone = prefs.getString('zone');
    String? role = prefs.getString('role');

    if (id != null) {
      print("ID: $id, Name: $name, Surname: $surname, Zone: $zone");
      setState(() {
        agentID = id;
        agentName = name;
        agentSurname = surname;
        agentZone = zone;
        agentRole = role;
      });
    } else {
      print("Aucune donnée utilisateur trouvée.");
    }
  }

  @override
  initState() {
    super.initState();
    loadUserData();
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
        appBar: AppBar(
          title: const Text('Basile'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar(
                    //   radius: 40,
                    //   backgroundImage: AssetImage('assets/profile_picture.png'), // Ajoutez une image dans vos assets
                    // ),
                    SizedBox(height: 10),
                    Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'johndoe@example.com',
                      style: TextStyle(
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
              agentRole == "Admin"
                  ? ListTile(
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
                    )
                  : const Text(""),
              agentRole == "Admin"
                  ? ListTile(
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
                    )
                  : const Text(""),
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
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context); // Ferme la Drawer
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
        body: Column(
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
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              width: double.infinity,
              height: 300,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dashboardTile("Total Clients", "${fetchClientCount()}"),
                      _dashboardTile("$agentZone", null),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _dashboardTile(
                          "Recolte du jour", "${fetchDailyAmount()}Fc"),
                      _dashboardTile("Dette Totale", "${fetchDebts()}Fc"),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Payment>>(
                future: dbHelper.fetchLatestClientsPayments(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun paiement trouvé.'));
                  }

                  final payments = snapshot.data!;

                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];

                      return ListTile(
                        title: Text(
                            'Montant Reçu: ${payment.amountRecu} | Taxe: ${payment.taxeName}'),
                        subtitle: Text(
                            'Client: ${payment.clientName}\nDate: ${payment.createdAt}'),
                        trailing: payment.amountRecu < payment.amountTot
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
