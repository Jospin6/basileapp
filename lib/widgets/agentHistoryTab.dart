import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
import 'package:flutter/material.dart';

class AgentHistoryTab extends StatefulWidget {
  final String agentID;
  const AgentHistoryTab({super.key, required this.agentID});

  @override
  State<AgentHistoryTab> createState() => _AgentHistoryTabState();
}

class _AgentHistoryTabState extends State<AgentHistoryTab> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Formatdate formatDate = Formatdate();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
              title: Text(
                'Montant: ${payment['amount_recu']} fc',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Client: ${payment['client_name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Taxe: ${payment['tax_amount']} fc'),
                  Text(
                      'Date: ${formatDate.formatCreatedAt(payment['created_at'])}'),
                ],
              ),
              isThreeLine: true,
            );
          },
        );
      },
    );
  }
}
