import 'package:basileapp/db/database_helper.dart';
import 'package:flutter/material.dart';

class AgentHistoryTab extends StatefulWidget {
  final String agentID;
  const AgentHistoryTab({super.key, required this.agentID});

  @override
  State<AgentHistoryTab> createState() => _AgentHistoryTabState();
}

class _AgentHistoryTabState extends State<AgentHistoryTab> {
  DatabaseHelper dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
