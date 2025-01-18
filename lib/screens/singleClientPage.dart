import 'package:flutter/material.dart';

class SingleClientPage extends StatefulWidget {
  final dynamic clientID;

  const SingleClientPage({super.key, required this.clientID});

  @override
  State<SingleClientPage> createState() => _SingleClientPageState();
}

class _SingleClientPageState extends State<SingleClientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String? _selectedTaxType;

  // Liste des types de taxes
  final List<String> _taxTypes = ["Taxe mensuelle", "Taxe annuelle", "Taxe journalière"];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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
                DropdownButtonFormField<String>(
                  value: _selectedTaxType,
                  items: _taxTypes.map((String taxType) {
                    return DropdownMenuItem<String>(
                      value: taxType,
                      child: Text(taxType),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTaxType = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Type de taxe",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // Traitement des données
                  final taxData = {
                    "taxType": _selectedTaxType,
                    "amount": double.parse(_amountController.text),
                    "clientID": widget.clientID,
                  };
                  print("Taxe ajoutée : $taxData");

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
      body: Center(
        child: ElevatedButton(
          onPressed: _openAddTaxDialog,
          child: const Text("Ajouter une taxe"),
        ),
      ),
    );
  }
}
