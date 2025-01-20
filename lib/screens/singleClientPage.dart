import 'package:basileapp/db/database_helper.dart';
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
                    // Correction ici pour la structure
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Détails du client")),
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
              const SizedBox(height: 10,),
              Container(
                width: double.infinity,
                height: 150,
                margin: const EdgeInsets.all(10),
                child: const Card(
                  elevation: 4,
                  child: Column(
                    children: [
                      Row(children: [],),
                      SizedBox(height: 10,),
                      Row(children: [],),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
