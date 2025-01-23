import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/paiement.dart';
import 'package:basileapp/screens/paiementHistoryPage.dart';
import 'package:flutter/material.dart';

class PaiementsPage extends StatefulWidget {
  final dynamic clientID;
  const PaiementsPage({super.key, required this.clientID});

  @override
  State<PaiementsPage> createState() => _PaiementsPageState();
}

class _PaiementsPageState extends State<PaiementsPage> {
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Basile'),
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaiementHistoryPage(),
                ),
              );
            },
          ),
        ),
        body: FutureBuilder<List<Payment>>(
          future: dbHelper.fetchClientPaiements(widget.clientID),
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
                  title: Text('Montant Reçu: ${payment.amountRecu}'),
                  subtitle: Text(
                    'Client: ${payment.clientName}, Taxe: ${payment.taxeName}, Date: ${payment.createdAt}',
                  ),
                  trailing: Text('Total: ${payment.amountTot}'),
                );
              },
            );
          },
        ));
  }
}
