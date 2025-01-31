import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
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
  Formatdate formatDate = Formatdate();

  void _showUpdatePaymentDialog(
      BuildContext context, double amountRecu, int idTaxe) {
    final TextEditingController _updateAmountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Payer le reste du: $amountRecu \$ reçu",
            style: const TextStyle(fontSize: 16),
          ),
          content: TextFormField(
            controller: _updateAmountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Montant supplémentaire",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                final enteredAmount =
                    double.tryParse(_updateAmountController.text);

                if (enteredAmount != null) {
                  final newAmountRecu = amountRecu + enteredAmount;

                  await dbHelper.updatePayment(idTaxe, {
                    "amount_recu": newAmountRecu,
                  });

                  Navigator.pop(context);

                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Paiement mis à jour avec succès"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
              ),
              child: const Text(
                "Mettre à jour",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: const Text(
            'Paiements du client',
            style: TextStyle(color: Colors.white),
          ),
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
                    builder: (context) => PaiementHistoryPage(clientID: widget.clientID,),
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
                return Card(
                  elevation: 3,
                  child: ListTile(
                    title: Text('💰 Montant: ${payment['amount_recu']} \$'),
                    subtitle: Text(
                      '👤 ${payment['client_name']},\n📍 Taxe: ${payment['tax_name']},\n📅 ${formatDate.formatCreatedAt(payment['created_at'])}',
                    ),
                    trailing: Column(
                      children: [
                        payment['amount_recu'] < payment['amount_tot']
                            ? IconButton(
                                onPressed: () {
                                  _showUpdatePaymentDialog(context,
                                      payment['amount_recu'], payment['id']);
                                },
                                icon:
                                    const Icon(Icons.payment, color: Colors.red),
                              )
                            : const Icon(Icons.check, color: Colors.green),
                        if (payment['amount_recu'] >= payment['amount_tot'])
                          Text('Total: ${payment['amount_tot']} \$')
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
