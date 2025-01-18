import 'package:flutter/material.dart';

class NewAgentPage extends StatefulWidget {
  const NewAgentPage({super.key});

  @override
  State<NewAgentPage> createState() => _NewAgentPageState();
}

class _NewAgentPageState extends State<NewAgentPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _defaultPassword = "12345678"; // Mot de passe par défaut
  String? _selectedZone;
  String? _selectedRole;

  // Liste des zones d'activité
  final List<String> _zones = ["Centre-ville", "Marché central", "Quartier résidentiel"];

  // Liste des rôles disponibles
  final List<String> _roles = ["Agent", "Admin"];

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final agentData = {
        "name": _nameController.text,
        "surname": _surnameController.text,
        "phone": _phoneController.text,
        "password": _defaultPassword,
        "zone": _selectedZone,
        "role": _selectedRole,
      };

      print("Agent ajouté : $agentData");

      // Nettoyer le formulaire
      _formKey.currentState!.reset();
      setState(() {
        _selectedZone = null;
        _selectedRole = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agent ajouté avec succès !")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter un agent"),
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

              // Bouton pour soumettre le formulaire
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Ajouter l'agent"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
