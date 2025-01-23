import 'package:basileapp/services/firebaseServices.dart';
import 'package:flutter/material.dart';

class CardAddZoneWidget extends StatefulWidget {
  const CardAddZoneWidget({super.key});

  @override
  State<CardAddZoneWidget> createState() => _CardAddZoneWidgetState();
}

class _CardAddZoneWidgetState extends State<CardAddZoneWidget> {
  FirebaseServices firebaseServices = FirebaseServices();

  void _submitZoneForm() async {
    if (_zoneNameController.text.isNotEmpty) {
      String zoneName = _zoneNameController.text;
      firebaseServices.addZone(zoneName);
      // Envoi des données à Firebase
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Zone ajoutée avec succès !")),
        );

        _zoneNameController.clear();
      } catch (e) {
        print("Erreur lors de l'ajout de la zone : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout de la zone.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le nom de la zone !")),
      );
    }
  }

  @override
  void dispose() {
    _zoneNameController.dispose();
    super.dispose();
  }

  // Contrôleur pour le formulaire de zone
  final TextEditingController _zoneNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Card(
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
              "Ajouter une zone",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Champ pour le nom de la zone
            TextFormField(
              controller: _zoneNameController,
              decoration: const InputDecoration(
                labelText: "Nom de la zone",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Bouton pour soumettre le formulaire de zone
            ElevatedButton(
              onPressed: _submitZoneForm,
              child: const Text("Ajouter la zone"),
            ),
          ],
        ),
      ),
    );
  }
}
