import 'package:basileapp/db/database_helper.dart';
import 'package:flutter/material.dart';  

class NewClientPage extends StatefulWidget {  
  const NewClientPage({super.key});  

  @override  
  State<NewClientPage> createState() => _NewClientPageState();  
}  

class _NewClientPageState extends State<NewClientPage> {  
  final _formKey = GlobalKey<FormState>();  
  
  // Contrôleurs pour les champs de texte  
  final TextEditingController _nameController = TextEditingController();  
  final TextEditingController _postNameController = TextEditingController();  
  final TextEditingController _commerceController = TextEditingController();  
  final TextEditingController _addressController = TextEditingController();  
  final TextEditingController _phoneController = TextEditingController();  
  final TextEditingController _zoneController = TextEditingController();  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(  
        title: const Text("Ajouter un Client"),  
      ),  
      body: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Form(  
          key: _formKey,  
          child: SingleChildScrollView(  
            child: Column(  
              mainAxisSize: MainAxisSize.min,  
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
                TextFormField(  
                  controller: _zoneController,  
                  decoration: const InputDecoration(  
                    labelText: "Zone d'activité",  
                    border: OutlineInputBorder(),  
                  ),  
                  validator: (value) {  
                    if (value == null || value.isEmpty) {  
                      return "Veuillez entrer la zone d'activité";  
                    }  
                    return null;  
                  },  
                ),  
                const SizedBox(height: 20),  
                ElevatedButton(  
                  onPressed: () async {  
                    if (_formKey.currentState!.validate()) {  
                      // Traitement des données  
                      final clientData = {  
                        "name": _nameController.text,  
                        "postName": _postNameController.text,  
                        "commerce": _commerceController.text,  
                        "address": _addressController.text,  
                        "phone": _phoneController.text,  
                        "zone": _zoneController.text,  
                        "agent": 1, // Remplacez par l'ID de l'agent approprié
                        "created_at": DateTime.now().toIso8601String()  
                      };  
                      print("Client ajouté : $clientData");  

                      // Insérer les données dans la base de données  
                      DatabaseHelper dbHelper = DatabaseHelper();  
                      await dbHelper.insertClient(clientData);  

                      // Nettoyer les champs  
                      _nameController.clear();  
                      _postNameController.clear();  
                      _commerceController.clear();  
                      _addressController.clear();  
                      _phoneController.clear();  
                      _zoneController.clear();  

                      // Afficher un message de succès ou rediriger si nécessaire  
                      ScaffoldMessenger.of(context).showSnackBar(  
                        const SnackBar(content: Text("Client ajouté avec succès")),  
                      );  
                    }  
                  },  
                  child: const Text("Enregistrer"),  
                ),  
              ],  
            ),  
          ),  
        ),  
      ),  
    );  
  }  
}