import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
import 'package:basileapp/outils/syncData.dart';
import 'package:flutter/material.dart';

class AgentDashboardTab extends StatefulWidget {
  final String agentID;
  final String agentName;
  final String agentSurname;
  final String agentZone;
  final String agentRole;
  const AgentDashboardTab(
      {super.key,
      required this.agentID,
      required this.agentName,
      required this.agentSurname,
      required this.agentZone,
      required this.agentRole});

  @override
  State<AgentDashboardTab> createState() => _AgentDashboardTabState();
}

class _AgentDashboardTabState extends State<AgentDashboardTab> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Formatdate formatDate = Formatdate();
  SyncData syncData = SyncData();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          elevation: 4,
          child: Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: 100,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${widget.agentName} ${widget.agentSurname}",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                    onPressed: () async {
                      await syncData.fetchAndSyncTaxes();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Taxes synchronisées !')),
                      );
                    },
                    icon: const Icon(Icons.sync))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Zone de ${widget.agentZone}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      "Rôle ${widget.agentRole}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
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
                        'Montant: ${payment['amount_recu']} \$ | Taxe: ${payment['taxe_name']}'),
                    subtitle: Text(
                        'Client: ${payment['client_name']}\nDate: ${formatDate.formatCreatedAt(payment['created_at'])}'),
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
    );
  }
}
