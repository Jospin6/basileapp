import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:basileapp/db/database_helper.dart';

class EditClientPage extends StatefulWidget {
  final int clientId;

  const EditClientPage({super.key, required this.clientId});

  @override
  State<EditClientPage> createState() => _EditClientPageState();
}

class _EditClientPageState extends State<EditClientPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour les champs de texte
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _postNameController = TextEditingController();
  final TextEditingController _commerceController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedZone;
  String? _agentId;
  final List<String> _zones = [];

  @override
  void initState() {
    super.initState();
    _loadClientData();
    _loadZones();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _postNameController.dispose();
    _commerceController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('zones').get();
      List<String> zones = querySnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      setState(() {
        _zones.clear();
        _zones.addAll(zones);
      });

      print("Zones récupérées avec succès : $zones");
    } catch (e) {
      print("Erreur lors de la récupération des zones : $e");
    }
  }

  Future<void> _loadClientData() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    try {
      // Récupère la liste des clients correspondant à l'ID
      final clients = await dbHelper.getClient(widget.clientId);

      // Vérifie si la liste n'est pas vide, puis utilise le premier élément
      if (clients.isNotEmpty) {
        final client = clients.first;

        setState(() {
          _nameController.text = client['name'] as String? ?? '';
          _postNameController.text = client['postName'] as String? ?? '';
          _commerceController.text = client['commerce'] as String? ?? '';
          _addressController.text = client['address'] as String? ?? '';
          _phoneController.text = client['phone'] as String? ?? '';
          _selectedZone = client['zone'] as String? ?? '';
          _agentId = client['agent']
              .toString(); // Convertit à une chaîne si nécessaire
        });
      }
    } catch (e) {
      print("Erreur lors du chargement des données du client : $e");
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final updatedClientData = {
        "name": _nameController.text,
        "postName": _postNameController.text,
        "commerce": _commerceController.text,
        "address": _addressController.text,
        "phone": _phoneController.text,
        "zone": _selectedZone,
        "agent": _agentId,
        "updated_at": DateTime.now().toIso8601String(),
      };

      try {
        DatabaseHelper dbHelper = DatabaseHelper();
        await dbHelper.updateClient(widget.clientId, updatedClientData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Client modifié avec succès !")),
        );

        Navigator.pop(context);
      } catch (e) {
        print("Erreur lors de la modification du client : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Erreur lors de la modification du client.")),
        );
      }
    }
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
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: const Text(
          "Modifier un Client",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le nom";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _postNameController,
                  decoration: const InputDecoration(
                    labelText: "Post-nom",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le post-nom";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _commerceController,
                  decoration: const InputDecoration(
                    labelText: "Commerce",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le commerce";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: "Adresse",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer l'adresse";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Numéro de téléphone",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer le numéro de téléphone";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedZone,
                  items: _zones.map((String zone) {
                    return DropdownMenuItem<String>(
                      value: zone,
                      child: Text(zone),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedZone = newValue;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: "Zone d'activité",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez sélectionner une zone d'activité";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
                    ),
                    child: const Text(
                      "Enregistrer les modifications",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
