import 'package:basileapp/db/database_helper.dart';
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
          title: const Text('Basile', style: TextStyle(color: Colors.white),),
          backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.history,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PaiementHistoryPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
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
                  title: Text('Montant Reçu: ${payment['amount_recu']}'),
                  subtitle: Text(
                    'Client: ${payment['client_name']}, Taxe: ${payment['tax_name']}, Date: ${payment['created_at']}',
                  ),
                  trailing: Text('Total: ${payment['amount_tot']}'),
                );
              },
            );
          },
        ));
  }
}
