import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/pdfPrinter.dart';
import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/screens/editClientPage.dart';
import 'package:basileapp/screens/newPaiementPage.dart';
import 'package:basileapp/screens/paiementsPage.dart';
import 'package:flutter/material.dart';

class SingleClientPage extends StatefulWidget {
  final dynamic clientID;

  const SingleClientPage({super.key, required this.clientID});

  @override
  State<SingleClientPage> createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  DatabaseHelper dbHelper = DatabaseHelper();
  String? agentName;
  String? agentSurname;
  String? agentZone;

  final pdfPrinter = PdfPrinter();

  String? agentID;
  String? numTeleAdmin;

  late SharedData sharedData;
  // List<Map<String, dynamic>> _taxes = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    // _fetchTaxes();
  }

  // Future<void> _fetchTaxes() async {
  //   List<Map<String, dynamic>> taxes =
  //       await dbHelper.getAllTaxes(); // Récupération des données
  //   setState(() {
  //     _taxes = taxes; // Mise à jour de l'état avec les taxes récupérées
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadUserData() async {
    sharedData = SharedData();

    setState(() {
      agentID = sharedData.getAgentId().toString();
      numTeleAdmin = sharedData.getNumTeleAdmin().toString();
      agentName = sharedData.getAgentName().toString();
      agentSurname = sharedData.getAgentSurname().toString();
      agentZone = sharedData.getAgentZone().toString();
    });
  }

  Future<double> fetchClientDebts(int id) async {
    double clientDebt = await dbHelper.getClientDebt(id);
    return clientDebt;
  }

  Future<double> getTotPaiedClient(int id) async {
    double totalPaid = await dbHelper.getTotalPaidByClient(id);
    return totalPaid;
  }

  void _showUpdatePaymentDialog(BuildContext context, double amountRecu, int idTaxe) {
    final TextEditingController _updateAmountController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Mettre à jour le paiement"),
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
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text(
          "Détails du client",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditClientPage(
                        clientId: widget.clientID,
                      ),
                    ),
                  ),
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () => {showTaxesDialog(context)},
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: const Text("Payer taxe"),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.all(10),
              child: const Card(
                elevation: 4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        // _dashboardTile("Total Paiement",
                        //     "${getTotPaiedClient(widget.clientID)}"),
                        // _dashboardTile("Total Dette",
                        //     "${fetchClientDebts(widget.clientID)}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaiementsPage(
                            clientID: widget.clientID,
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      "plus",
                      style: TextStyle(color: Colors.blue),
                    ))
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            // Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: MediaQuery.of(context).size.height,
            //     padding: const EdgeInsets.only(left: 10, right: 10),
            //     child: _taxes.isEmpty
            //         ? Center(
            //             child:
            //                 CircularProgressIndicator()) // Affiche un indicateur de chargement pendant la récupération
            //         : ListView.builder(
            //             itemCount: _taxes.length,
            //             itemBuilder: (context, index) {
            //               final tax = _taxes[index];
            //               return ListTile(
            //                 title: Text(tax['name'] ??
            //                     'Nom inconnu'), // Affiche le nom de la taxe
            //                 subtitle: Text(
            //                     'ID: ${tax['id']}'), // Montre l'ID de la taxe
            //                 trailing: Text(
            //                     '${tax['amount']} €'), // Montre le montant de la taxe
            //               );
            //             },
            //           )),

            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.fetchLatestPayments(widget.clientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur putain: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucun paiement trouvé"));
                  }

                  final payments = snapshot.data!;

                  return ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      final payment = payments[index];

                      return ListTile(
                        title: Text(
                          'Montant Reçu: ${payment['amount_recu']} Taxe: ${payment['taxe_name']}',
                        ),
                        subtitle: Text(
                          'Client: ${payment['client_name']}, Date: ${payment['created_at']}',
                        ),
                        trailing: payment['amount_recu'] < payment['amount_tot']
                            ? IconButton(
                                onPressed: () {
                                  _showUpdatePaymentDialog(context, payment['amount_recu'], payment['id']);
                                },
                                icon: const Icon(Icons.payment,
                                    color: Colors.red),
                              )
                            : const Icon(Icons.check, color: Colors.green),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  Future<void> showTaxesDialog(BuildContext context) async {
    final taxes = await dbHelper.getAllTaxes(); // Récupère les taxes

    // Regrouper les taxes par type avec ID, nom, typeTaxe et montant
    Map<String, List<Map<String, dynamic>>> taxesByType = {};
    for (var tax in taxes) {
      String type = tax['type'] ?? ""; // Assurez-vous que 'type' n'est pas nul
      String name = tax['name'] ?? ""; // Assurez-vous que 'name' n'est pas nul
      int id = tax['id']; // ID de la taxe
      double amount = tax['amount'] ?? 0.0; // Montant de la taxe

      // Créez un mappage pour chaque taxe
      Map<String, dynamic> taxInfo = {
        'id': id,
        'name': name,
        'amount': amount,
      };

      // Ajoutez cette taxe à la liste correspondante dans le Map
      if (!taxesByType.containsKey(type)) {
        taxesByType[type] = [];
      }
      taxesByType[type]!.add(taxInfo); // Ajoute le mappage à la liste
    }

    // Créer une liste de Widgets pour le dialogue
    List<Widget> taxWidgets = [];
    taxesByType.forEach((type, taxList) {
      taxWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              ...taxList.map((taxInfo) {
                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewPaiementPage(
                        clientID: widget.clientID,
                        typeTaxe: type,
                        nameTaxe: taxInfo['name'],
                        idTaxe: taxInfo['id'],
                        montantTaxe: taxInfo['amount'],
                      ),
                    ),
                  ),
                  title: Text(
                    '${taxInfo['name']}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });

    // Affichage du dialogue
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Liste des Taxes'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: taxWidgets,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer le dialogue
              },
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  // Future<void> _sendSMS(String message, List<String> recipients) async {
  //   try {
  //     String result = await sendSMS(
  //         message: message, recipients: recipients, sendDirect: true);
  //     print(result);
  //   } catch (e) {
  //     print("Erreur lors de l'envoi du SMS : $e");
  //   }
  // }
}
