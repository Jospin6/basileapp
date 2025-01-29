import 'package:basileapp/outils/syncData.dart';
import 'package:basileapp/screens/taxesPage.dart';
import 'package:basileapp/services/firebaseServices.dart';
import 'package:flutter/material.dart';

class CardAddTaxWidget extends StatefulWidget {
  const CardAddTaxWidget({super.key});

  @override
  State<CardAddTaxWidget> createState() => _CardAddTaxWidgetState();
}

class _CardAddTaxWidgetState extends State<CardAddTaxWidget> {
  FirebaseServices firebaseServices = FirebaseServices();
  SyncData syncData = SyncData();

  // Contrôleurs pour le formulaire de taxe
  final TextEditingController _taxNameController = TextEditingController();
  final TextEditingController _taxAmountController = TextEditingController();
  String? _selectedTaxType;
  bool _isLoading = false;

  Future<void> _handleClick() async {
    setState(() {
      _isLoading = true; // Affiche le CircularProgressIndicator
    });

    // Simule une tâche asynchrone (exemple : API call)
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isLoading = false; // Cache le loader après exécution
    });
  }

  // Types de taxes
  final List<String> _taxTypes = ["Journalier", "Mensuel", "Annuel"];

  void _submitTaxForm() async {
    _handleClick();
    if (_selectedTaxType != null &&
        _taxNameController.text.isNotEmpty &&
        _taxAmountController.text.isNotEmpty) {
      // Préparation des données
      String? taxType = _selectedTaxType;
      String taxName = _taxNameController.text;
      double taxAmount = double.tryParse(_taxAmountController.text) ?? 0.0;

      // Envoi des données à Firebase
      try {
        firebaseServices.addTaxe(taxType!, taxName, taxAmount);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Taxe ajoutée avec succès !")),
        );

        // Réinitialisation des champs
        _taxNameController.clear();
        _taxAmountController.clear();
        setState(() {
          _selectedTaxType = null;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TaxesPage(),
          ),
        );
      } catch (e) {
        print("Erreur lors de l'ajout de la taxe : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout de la taxe.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs !")),
      );
    }
  }

  @override
  void dispose() {
    _taxNameController.dispose();
    _taxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return // Card pour ajouter une taxe
        Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ajouter une taxe",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Menu déroulant pour le type de taxe
            DropdownButtonFormField<String>(
              value: _selectedTaxType,
              items: _taxTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
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
            ),
            const SizedBox(height: 10),

            // Champ pour le nom de la taxe
            TextFormField(
              controller: _taxNameController,
              decoration: const InputDecoration(
                labelText: "Nom de la taxe",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Champ pour le montant de la taxe
            TextFormField(
              controller: _taxAmountController,
              decoration: const InputDecoration(
                labelText: "Montant de la taxe",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),

            // Bouton pour soumettre le formulaire de taxe
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitTaxForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
                    ),
                    child: const Text(
                      "Ajouter la taxe",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
