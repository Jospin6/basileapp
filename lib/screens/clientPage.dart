import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/screens/newClientPage.dart';
import 'package:basileapp/screens/singleClientPage.dart'; // Ajoutez cette importation pour SingleClientPage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientPage extends StatefulWidget {
  const ClientPage({super.key});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  List<Map<String, dynamic>> _clients = []; // Liste pour stocker les clients
  final String _selectedZone =
      "VotreZone"; // Remplacez cela par la zone que vous souhaitez utiliser
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchClients(); // Récupération des clients lors de l'initialisation de l'état
  }

  Future<void> _fetchClients() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> clients =
        await dbHelper.getClientsByZone(_selectedZone);
    setState(() {
      _clients = clients; // Met à jour l'état avec la liste des clients
    });
  }

  Future<void> synchronizeData() async {
    try {
      // Récupérer l'ID utilisateur depuis SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('id');

      if (userId == null) {
        throw Exception("ID utilisateur non trouvé dans SharedPreferences");
      }

      // Initialisation Firestore
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Lecture des données locales SQLite
      List<Map<String, dynamic>> clients = await dbHelper.getAllClients();
      List<Map<String, dynamic>> paiements = await dbHelper.getAllPayments();
      List<Map<String, dynamic>> paiementsHistory =
          await dbHelper.getAllPaymentsHistory();

      // Utilisation d'un batch pour les écritures Firestore
      WriteBatch batch = firestore.batch();

      // Synchronisation des données des clients
      for (var client in clients) {
        DocumentReference docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('clients')
            .doc(client['id'].toString());
        batch.set(docRef, client);
      }

      // Synchronisation des paiements
      for (var paiement in paiements) {
        DocumentReference docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('paiements')
            .doc(paiement['id'].toString());
        batch.set(docRef, paiement);
      }

      // Synchronisation des paiements_history
      for (var history in paiementsHistory) {
        DocumentReference docRef = firestore
            .collection('users')
            .doc(userId)
            .collection('paiements_history')
            .doc(history['id'].toString());
        batch.set(docRef, history);
      }

      // Exécuter le batch
      await batch.commit();

      // Afficher un message de succès
      print("Synchronisation terminée avec succès !");
    } catch (error) {
      print("Erreur lors de la synchronisation : $error");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Client Page")),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewClientPage(),
                    ),
                  );
                },
                child: const Text("Add Client"),
              ),
              const SizedBox(
                width: 10,
              ),
              IconButton(
                  onPressed: () async {
                    await synchronizeData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Synchronisation terminée !')),
                    );
                  },
                  icon: const Icon(Icons.sync))
            ],
          ),
          const SizedBox(
              height: 10), // Ajoute un espacement entre le bouton et la liste
          Expanded(
            child: ListView.builder(
              itemCount: _clients.length,
              itemBuilder: (context, index) {
                final client = _clients[index];
                return ListTile(
                  title: Text(client['name'] ?? 'Nom non disponible'),
                  subtitle:
                      Text(client['postName'] ?? 'Post-nom non disponible'),
                  onTap: () {
                    // Naviguer vers SingleClientPage avec l'ID du client
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SingleClientPage(clientID: client['id']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
