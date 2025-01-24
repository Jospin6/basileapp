import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/paiement.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/widgets/adminDashboard.dart';
import 'package:basileapp/widgets/drawerWidget.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  late SharedData sharedData;
  String? agentID;
  String? agentName;
  String? agentSurname;
  String? agentZone;
  String? agentRole;

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sharedData = SharedData(prefs: prefs);

    setState(() {
      agentID = sharedData.getAgentId().toString();
      agentName = sharedData.getAgentName().toString();
      agentSurname = sharedData.getAgentSurname().toString();
      agentZone = sharedData.getAgentZone().toString();
      agentRole = sharedData.getAgentRole().toString();
    });
  }

  @override
  void initState() {
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
        drawer: DrawerWidget(
            agentID: agentID!,
            agentName: agentName!,
            agentSurname: agentSurname!,
            agentZone: agentZone!,
            agentRole: agentRole!),
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
                    width: double.infinity,
                    height: 300,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _dashboardTile(
                                "Total Clients", "${fetchClientCount()}"),
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Erreur: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('Aucun paiement trouvé.'));
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
