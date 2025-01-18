import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Contrôleurs pour le formulaire de taxe
  final TextEditingController _taxNameController = TextEditingController();
  final TextEditingController _taxAmountController = TextEditingController();
  String? _selectedTaxType;

  // Contrôleur pour le formulaire de zone
  final TextEditingController _zoneNameController = TextEditingController();

  // Types de taxes
  final List<String> _taxTypes = ["Journalier", "Mensuel", "Annuel"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _taxNameController.dispose();
    _taxAmountController.dispose();
    _zoneNameController.dispose();
    super.dispose();
  }

  void _submitTaxForm() {
    if (_selectedTaxType != null &&
        _taxNameController.text.isNotEmpty &&
        _taxAmountController.text.isNotEmpty) {
      print("Taxe ajoutée :");
      print("Type : $_selectedTaxType");
      print("Nom : ${_taxNameController.text}");
      print("Montant : ${_taxAmountController.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Taxe ajoutée avec succès !")),
      );

      _taxNameController.clear();
      _taxAmountController.clear();
      setState(() {
        _selectedTaxType = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs !")),
      );
    }
  }

  void _submitZoneForm() {
    if (_zoneNameController.text.isNotEmpty) {
      print("Zone ajoutée : ${_zoneNameController.text}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Zone ajoutée avec succès !")),
      );

      _zoneNameController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le nom de la zone !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Infos"),
            Tab(text: "Autres"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Infos
          const Center(child: Text("Informations générales")),

          // Onglet Autres
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Card pour ajouter une taxe
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
                          ElevatedButton(
                            onPressed: _submitTaxForm,
                            child: const Text("Ajouter la taxe"),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card pour ajouter une zone
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
