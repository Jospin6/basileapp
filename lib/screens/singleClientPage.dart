import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/paiement.dart';
import 'package:basileapp/screens/editClientPage.dart';
import 'package:basileapp/screens/paiementsPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SingleClientPage extends StatefulWidget {
  final dynamic clientID;

  const SingleClientPage({super.key, required this.clientID});

  @override
  State<SingleClientPage> createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  Map<String, dynamic>? _selectedTaxType;
  DatabaseHelper dbHelper = DatabaseHelper();

  // Liste des types de taxes
  List<Map<String, dynamic>> _taxTypes = [];
  String taxe = "Journalier";
  double amountTaxe = 0;
  String? agentID;

  @override
  void initState() {
    super.initState();
    fetchTaxes();
    loadUserData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');

    if (id != null) {
      setState(() {
        agentID = id;
      });
    } else {
      print("Aucune donnée utilisateur trouvée.");
    }
  }

  Future<double> fetchClientDebts(int id) async {
    double clientDebt = await dbHelper.getClientDebt(id);
    return clientDebt;
  }

  Future<double> getTotPaiedClient(int id) async {
    double totalPaid = await dbHelper.getTotalPaidByClient(id);
    return totalPaid;
  }

  void fetchTaxes() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    String taxesType = "Journalier"; // Remplacez par le type de taxe souhaité
    List<Map<String, dynamic>> taxes = await dbHelper.getTaxesByType(taxesType);

    setState(() {
      _taxTypes = taxes; // Met à jour l'état avec la liste des clients
    }); // Affiche les taxes récupérées
  }

  void _openAddTaxDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter une taxe"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menu déroulant pour le type de taxe
                DropdownButtonFormField<Map<String, dynamic>>(
                  value: _selectedTaxType,
                  items: _taxTypes.map((taxType) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: taxType['id'],
                      child: Text('${taxType['name']}'),
                    );
                  }).toList(),
                  onChanged: (Map<String, dynamic>? newValue) {
                    setState(() {
                      _selectedTaxType = newValue;
                      amountTaxe = newValue!['amount'];
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Type de taxe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null) {
                      return "Veuillez sélectionner un type de taxe";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Champ pour le montant
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: "Montant",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un montant";
                    }
                    if (double.tryParse(value) == null) {
                      return "Veuillez entrer un montant valide";
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le popup
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  // Traitement des données
                  final taxData = {
                    "id_client": widget.clientID,
                    "id_taxe": _selectedTaxType,
                    "id_agent": agentID,
                    "amount_tot": amountTaxe,
                    "amount_recu": double.parse(_amountController.text),
                    "created_at": DateTime.now().toIso8601String()
                  };
                  final taxHistData = {
                    "id_client": widget.clientID,
                    "id_taxe": _selectedTaxType,
                    "id_agent": agentID,
                    "amount_recu": double.parse(_amountController.text),
                    "created_at": DateTime.now().toIso8601String()
                  };
                  print("Taxe ajoutée : $taxData");

                  // Insérer les données dans la base de données
                  DatabaseHelper dbHelper = DatabaseHelper();
                  await dbHelper.insertPayment(taxData);
                  await dbHelper.insertPaymentHistory(taxHistData);

                  // Nettoyer les champs
                  _selectedTaxType = null;
                  _amountController.clear();

                  Navigator.pop(context); // Fermer le popup
                }
              },
              child: const Text("Enregistrer"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdatePaymentDialog(BuildContext context, Payment payment) {
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
                  final newAmountRecu = payment.amountRecu + enteredAmount;

                  await dbHelper.updatePayment(payment.id, {
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
              child: const Text("Mettre à jour"),
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
        title: const Text("Détails du client"),
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
              icon: const Icon(Icons.edit))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    _openAddTaxDialog;
                    setState(() {
                      taxe = "Journalier";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: const Text("Jour"),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _openAddTaxDialog;
                    setState(() {
                      taxe = "Mensuel";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: const Text("Mois"),
                  ),
                ),
                InkWell(
                  onTap: () {
                    _openAddTaxDialog;
                    setState(() {
                      taxe = "Annuel";
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    child: const Text("Année"),
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
              child: Card(
                elevation: 4,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _dashboardTile("Total Paiement",
                            "${getTotPaiedClient(widget.clientID)}"),
                        _dashboardTile("Total Dette",
                            "${fetchClientDebts(widget.clientID)}"),
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
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FutureBuilder<List<Payment>>(
                future: dbHelper.fetchLatestPayments(widget.clientID),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Erreur: ${snapshot.error}"));
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
                          'Montant Reçu: ${payment.amountRecu} Taxe: ${payment.taxeName}',
                        ),
                        subtitle: Text(
                          'Client: ${payment.clientName}, Date: ${payment.createdAt}',
                        ),
                        trailing: payment.amountRecu < payment.amountTot
                            ? IconButton(
                                onPressed: () {
                                  _showUpdatePaymentDialog(context, payment);
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
}
