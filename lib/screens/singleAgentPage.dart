import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/paiement.dart';
import 'package:basileapp/screens/editAgentPage.dart';
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
    String? id = prefs.getString('id');
    String? name = prefs.getString('name');
    String? surname = prefs.getString('surname');
    String? zone = prefs.getString('zone');
    String? role = prefs.getString('role');

    if (id != null) {
      print("ID: $id, Name: $name, Surname: $surname, Zone: $zone");
      setState(() {
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
            Tab(text: "History", icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Contenu pour chaque onglet
          _buildDashboardTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAgentPage(agentId: widget.agentID,),
                    ),
                  );
              }, 
              child: const Icon(Icons.edit))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$agentName $agentSurname"),
            Text("Rôle $agentRole"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Zone d'activité $agentZone"),
          ],
        ),
        const SizedBox(
          height: 10,
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
    );
  }

  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      child: FutureBuilder<List<Map<String, dynamic>>>(  
      future: dbHelper.getPaymentHistoryByAgent(widget.agentID),  
      builder: (context, snapshot) {  
        if (snapshot.connectionState == ConnectionState.waiting) {  
          return const Center(child: CircularProgressIndicator());  
        } else if (snapshot.hasError) {  
          return Center(child: Text('Erreur: ${snapshot.error}'));  
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {  
          return const Center(child: Text('Aucun historique de paiement trouvé.'));  
        }  

        final paymentHistory = snapshot.data!;  

        return ListView.builder(  
          itemCount: paymentHistory.length,  
          itemBuilder: (context, index) {  
            final payment = paymentHistory[index];  
            return ListTile(  
              title: Text('Montant: ${payment['amount_recu']}'), 
              subtitle: Column(  
                crossAxisAlignment: CrossAxisAlignment.start,  
                children: [  
                  Text('Client: ${payment['client_name']}'),  
                  Text('Taxe: ${payment['tax_amount']}'),  
                  Text('Agent: ${payment['agent_name']}'), 
                  Text('Date: ${payment['created_at']}'), 
                ],  
              ),  
              isThreeLine: true,  
            );  
          },  
        );  
      },  
    ),
    );
  }
}
