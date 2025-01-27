import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/screens/homePage.dart';
import 'package:basileapp/services/firebaseServices.dart';
import 'package:flutter/material.dart';

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({super.key});

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  FirebaseServices firebaseServices = FirebaseServices();
  late SharedData sharedData;

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
                    backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
                  ),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
    final result = await firebaseServices.login(phone, password);
    sharedData = SharedData();

    // Vérifiez si l'utilisateur existe dans Firestore

    if (result.docs.isNotEmpty) {
      // Connexion réussie
      final userData = result.docs.first.data() as Map<String, dynamic>;
      // Récupérer les données utilisateur
      String id = result.docs.first.id; // Obtient l'ID du document
      String name = userData['name'];
      String surname = userData['surname'];
      String zone = userData['zone'];
      String role = userData['role'];
      String numTeleAdmin = userData['numTeleAdmin'] ?? "0976774112";

      sharedData.setId(id);
      sharedData.setName(name);
      sharedData.setSurename(surname);
      sharedData.setZone(zone);
      sharedData.setRole(role);
      sharedData.setNumTeleAdmin(numTeleAdmin);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connexion réussie !')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Homepage(),
        ),
      );

      // Ajoutez ici la navigation vers une autre page si nécessaire
    } else {
      // Connexion échouée
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Échec de la connexion. Vérifiez vos informations.')),
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
