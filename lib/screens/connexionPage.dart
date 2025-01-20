import 'package:flutter/material.dart';  
import 'package:cloud_firestore/cloud_firestore.dart';  
import 'package:shared_preferences/shared_preferences.dart';  

class ConnexionPage extends StatefulWidget {  
  const ConnexionPage({super.key});  

  @override  
  State<ConnexionPage> createState() => _ConnexionPageState();  
}  

class _ConnexionPageState extends State<ConnexionPage> {  
  final _formKey = GlobalKey<FormState>();  
  final TextEditingController _phoneController = TextEditingController();  
  final TextEditingController _passwordController = TextEditingController();  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      body: Center(  
        child: Padding(  
          padding: const EdgeInsets.all(16.0),  
          child: Form(  
            key: _formKey,  
            child: Column(  
              mainAxisSize: MainAxisSize.min,  
              children: [  
                const Text(  
                  'Connexion',  
                  style: TextStyle(  
                    fontSize: 24,  
                    fontWeight: FontWeight.bold,  
                  ),  
                ),  
                const SizedBox(height: 20),  

                TextFormField(  
                  controller: _phoneController,  
                  keyboardType: TextInputType.phone,  
                  decoration: InputDecoration(  
                    labelText: 'Numéro de téléphone',  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(10.0),  
                    ),  
                  ),  
                  validator: (value) {  
                    if (value == null || value.isEmpty) {  
                      return 'Veuillez entrer votre numéro de téléphone';  
                    }  
                    return null;  
                  },  
                ),  
                const SizedBox(height: 20),  

                TextFormField(  
                  controller: _passwordController,  
                  obscureText: true,  
                  decoration: InputDecoration(  
                    labelText: 'Mot de passe',  
                    border: OutlineInputBorder(  
                      borderRadius: BorderRadius.circular(10.0),  
                    ),  
                  ),  
                  validator: (value) {  
                    if (value == null || value.isEmpty) {  
                      return 'Veuillez entrer votre mot de passe';  
                    }  
                    if (value.length < 6) {  
                      return 'Le mot de passe doit contenir au moins 6 caractères';  
                    }  
                    return null;  
                  },  
                ),  
                const SizedBox(height: 20),  

                ElevatedButton(  
                  onPressed: () async {  
                    if (_formKey.currentState!.validate()) {  
                      // Logique de connexion  
                      await _loginUser();  
                    }  
                  },  
                  style: ElevatedButton.styleFrom(  
                    padding: const EdgeInsets.symmetric(  
                        horizontal: 40.0, vertical: 12.0),  
                    shape: RoundedRectangleBorder(  
                      borderRadius: BorderRadius.circular(10.0),  
                    ),  
                  ),  
                  child: const Text(  
                    'Se connecter',  
                    style: TextStyle(fontSize: 16),  
                  ),  
                ),  
              ],  
            ),  
          ),  
        ),  
      ),  
    );  
  }  

  Future<void> _loginUser() async {  
    final phone = _phoneController.text.trim();  
    final password = _passwordController.text.trim();  

    // Vérifiez si l'utilisateur existe dans Firestore  
    final QuerySnapshot result = await FirebaseFirestore.instance  
        .collection('users')  
        .where('phone', isEqualTo: phone)  
        .where('password', isEqualTo: password) // Assurez-vous que le mot de passe est stocké correctement  
        .get();  

    if (result.docs.isNotEmpty) {  
      // Connexion réussie  
      final userData = result.docs.first.data() as Map<String, dynamic>;  
      // Récupérer les données utilisateur  
      String id = result.docs.first.id; // Obtient l'ID du document  
      String name = userData['name'];  
      String surname = userData['surname'];  
      String zone = userData['zone'];  

      // Stocke les informations dans SharedPreferences  
      SharedPreferences prefs = await SharedPreferences.getInstance();  
      await prefs.setString('id', id);  
      await prefs.setString('name', name);  
      await prefs.setString('surname', surname);  
      await prefs.setString('zone', zone);  

      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Connexion réussie !')),  
      );  

      // Ajoutez ici la navigation vers une autre page si nécessaire  
    } else {  
      // Connexion échouée  
      ScaffoldMessenger.of(context).showSnackBar(  
        const SnackBar(content: Text('Échec de la connexion. Vérifiez vos informations.')),  
      );  
    }  
  }  

  @override  
  void dispose() {  
    _phoneController.dispose();  
    _passwordController.dispose();  
    super.dispose();  
  }  
}