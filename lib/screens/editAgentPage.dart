import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditAgentPage extends StatefulWidget {
  final String agentId; // ID de l'agent à modifier

  const EditAgentPage({super.key, required this.agentId});

  @override
  State<EditAgentPage> createState() => _EditAgentPageState();
}

class _EditAgentPageState extends State<EditAgentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedZone;
  String? _selectedRole;

  // Liste des zones d'activité
  final List<String> _zones = [];

  // Liste des rôles disponibles
  final List<String> _roles = ["Agent", "Admin"];

  @override
  void initState() {
    super.initState();
    _loadZones();
    _loadAgentData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> fetchZones(List<String> zonesList) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('zones').get();
      List<String> zones = querySnapshot.docs.map((doc) {
        return doc['name'] as String;
      }).toList();

      zonesList.clear();
      zonesList.addAll(zones);
      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des zones : $e");
    }
  }

  Future<void> _loadZones() async {
    await fetchZones(_zones);
  }

  Future<void> _loadAgentData() async {
    try {
      DocumentSnapshot agentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.agentId)
          .get();

      if (agentDoc.exists) {
        Map<String, dynamic> data = agentDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _surnameController.text = data['surname'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _selectedZone = data['zone'];
          _selectedRole = data['role'];
        });
      } else {
        print("Aucun document trouvé pour l'ID : ${widget.agentId}");
      }
    } catch (e) {
      print("Erreur lors du chargement des données de l'agent : $e");
    }
  }

  void _updateAgentData() async {
    if (_formKey.currentState!.validate()) {
      final updatedAgentData = {
        "name": _nameController.text,
        "surname": _surnameController.text,
        "phone": _phoneController.text,
        "zone": _selectedZone,
        "role": _selectedRole,
      };

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.agentId)
            .update(updatedAgentData);

        print("Agent mis à jour : $updatedAgentData");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Agent mis à jour avec succès !")),
        );

        Navigator.pop(context); // Retour à la page précédente
      } catch (e) {
        print("Erreur lors de la mise à jour de l'agent : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de la mise à jour.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier un agent"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ pour le nom
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

              // Champ pour le post-nom
              TextFormField(
                controller: _surnameController,
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

              // Champ pour le numéro de téléphone
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
                  if (!RegExp(r'^\d+$').hasMatch(value)) {
                    return "Veuillez entrer un numéro valide";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              if(_selectedRole == "Admin")
              // Menu déroulant pour la zone d'activité
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
              const SizedBox(height: 10),
              if(_selectedRole == "Admin")
                  // Menu déroulant pour le rôle
                  DropdownButtonFormField<String>(
                      value: _selectedRole,
                      items: _roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Rôle de l'agent",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez sélectionner un rôle";
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 20),

              // Bouton pour soumettre les modifications
              ElevatedButton(
                onPressed: _updateAgentData,
                child: const Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
