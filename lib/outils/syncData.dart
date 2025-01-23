import 'package:basileapp/db/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncData {
  Future<void> synchronizeData() async {
    DatabaseHelper dbHelper = DatabaseHelper();
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
}