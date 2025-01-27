import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/screens/editAgentPage.dart';
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditAgentPage(
                        agentId: widget.agentID,
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.edit))
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${widget.agentName} ${widget.agentSurname}"),
            Text("Rôle ${widget.agentRole}"),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Zone d'activité ${widget.agentZone}"),
          ],
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
    );
  }
}
