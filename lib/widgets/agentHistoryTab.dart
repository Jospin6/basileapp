import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentHistoryTab extends StatefulWidget {
  final String agentID;
  final String agentRole;
  const AgentHistoryTab(
      {super.key, required this.agentID, required this.agentRole});

  @override
  State<AgentHistoryTab> createState() => _AgentHistoryTabState();
}

class _AgentHistoryTabState extends State<AgentHistoryTab> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Formatdate formatDate = Formatdate();

  Future<List<Map<String, dynamic>>> fetchPaymentHistoryByAgent(
      String idAgent) async {
    try {
      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('paiements_history')
          .where('id_agent', isEqualTo: idAgent)
          .get();

      List<Map<String, dynamic>> history = historySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return history;
    } catch (e) {
      print(
          "❌ Erreur lors de la récupération de l'historique des paiements : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if(widget.agentRole == "Admin")
        Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPaymentHistoryByAgent(
                widget.agentID), // Remplace par l'ID réel de l'agent
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("❌ Erreur : ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("⚠️ Aucun historique trouvé"));
              } else {
                List<Map<String, dynamic>> history = snapshot.data!;
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final payment = history[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("👤 ${payment['id_client']}"),
                        subtitle: Text(
                          "💰 Montant: \$${payment['amount_recu']}\n📅 ${formatDate.formatCreatedAt(payment['created_at'])}",
                        ),
                        trailing: Text("🆔 Agent : ${payment['id_agent']}"),
                      ),
                    );
                  },
                );
              }
            },
          )),
        if(widget.agentRole != "Admin")
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.getPaymentHistoryByAgent(widget.agentID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('Aucun historique de paiement trouvé.'));
                }
          
                final paymentHistory = snapshot.data!;
          
                return ListView.builder(
                  itemCount: paymentHistory.length,
                  itemBuilder: (context, index) {
                    final payment = paymentHistory[index];
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          '💰 Montant: ${payment['amount_recu']} \$',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('👤 ${payment['client_name']}',
                                style:
                                    const TextStyle(fontWeight: FontWeight.bold)),
                            Text('💰 Taxe: ${payment['tax_amount']} \$'),
                            Text(
                                '📅 ${formatDate.formatCreatedAt(payment['created_at'])}'),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
              },
            ),
        )
      ],
    );
  }
}
