import 'package:basileapp/outils/sharedData.dart';
import 'package:basileapp/screens/connexionPage.dart';
import 'package:basileapp/screens/homePage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedData.initialize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chefferie de Basile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(173, 104, 0, 1)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Chefferie de Basile'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? agentID;

  @override
  void initState() {
    super.initState();
    loadUserData();
    checkInternetAndFetchData(); // Appel d'une méthode distincte.
  }

  void checkInternetAndFetchData() async {
    bool connected = await isConnectedToInternet(); // Attente du Future ici.
    if (connected && agentID != null) {
      fetchAndStoreUserData(agentID!);
    } else {
      print("Pas de connexion Internet ou agentID est null.");
    }
  }

  Future<bool> isConnectedToInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi;
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('id');
    String? name = prefs.getString('name');
    String? surname = prefs.getString('surname');
    String? zone = prefs.getString('zone');

    if (id != null) {
      print("ID: $id, Name: $name, Surname: $surname, Zone: $zone");
      setState(() {
        agentID = id;
      });
    } else {
      print("Aucune donnée utilisateur trouvée.");
    }
  }

  Future<void> fetchAndStoreUserData(String userId) async {
    try {
      // Connexion à Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Récupère le document utilisateur correspondant à l'ID donné
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Obtient les données utilisateur
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Récupère les informations nécessaires
        String id = userDoc.id; // ID du document
        String name = userData['name'] ??
            ''; // Utilisez une valeur par défaut si le champ est absent
        String surname = userData['surname'] ?? '';
        String zone = userData['zone'] ?? '';
        String role = userData['role'] ?? '';

        // Stocke les informations dans SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('id', id);
        await prefs.setString('name', name);
        await prefs.setString('surname', surname);
        await prefs.setString('zone', zone);
        await prefs.setString('role', role);

        print("Données utilisateur stockées avec succès.");
      } else {
        print("Aucun utilisateur trouvé avec cet ID : $userId");
      }
    } catch (e) {
      print("Erreur lors de la récupération des données utilisateur : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 300,
              margin: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/basile.jpg'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => agentID != null
                            ? const Homepage()
                            : const ConnexionPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
                  ),
                  child: const Text(
                    "Commencer",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
