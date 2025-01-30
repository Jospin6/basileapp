import 'package:basileapp/db/database_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncData {
  final DatabaseHelper dbHelper = DatabaseHelper();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> synchronizeData() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? idAgent = prefs.getString('id');
      if (idAgent == null || idAgent.isEmpty) {
        print("❌ ID utilisateur introuvable !");
        return;
      }

      // 📥 Récupération des données SQLite
      List<Map<String, dynamic>> clients = await dbHelper.getAllClients();
      List<Map<String, dynamic>> paiements = await dbHelper.getAllPayments();
      List<Map<String, dynamic>> paiementsHistory =
          await dbHelper.getAllPaymentsHistory();

      print("👤 Clients trouvés : ${clients.length}");
      print("💰 Paiements trouvés : ${paiements.length}");
      print("📜 Historique trouvé : ${paiementsHistory.length}");

      if (clients.isEmpty && paiements.isEmpty && paiementsHistory.isEmpty) {
        print("⚠️ Aucune donnée à synchroniser !");
        return;
      }

      // ❌ Supprimer d'abord les anciennes données où id_agent == idAgent
      Future<void> deleteExistingData(String collection) async {
        QuerySnapshot querySnapshot = await firestore
            .collection(collection)
            .where('id_agent', isEqualTo: idAgent)
            .get();

        for (var doc in querySnapshot.docs) {
          await firestore.collection(collection).doc(doc.id).delete();
        }
        print(
            "🗑️ Toutes les données de $collection pour id_agent = $idAgent supprimées !");
      }

      await deleteExistingData('clients');
      await deleteExistingData('paiements');
      await deleteExistingData('paiements_history');

      // 🔹 Ajout des clients
      for (var client in clients) {
        await firestore.collection('clients').add({
          'id_client': client['id'].toString(),
          'name': client['name'].toString(),
          'postName': client['postName'].toString(),
          'commerce': client['commerce'].toString(),
          'address': client['address'].toString(),
          'phone': client['phone'].toString(),
          'zone': client['zone'].toString(),
          'id_agent': client['agent'].toString(),
          'created_at': client['created_at'].toString(),
        }).then((_) {
          print("✅ Client ajouté : ${client['id']}");
        }).catchError((error) {
          print("❌ Erreur ajout client : $error");
        });
      }

      // 🔹 Ajout des paiements
      for (var paiement in paiements) {
        await firestore.collection('paiements').add({
          'id_paiement': paiement['id'].toString(),
          'id_client': paiement['id_client'].toString(),
          'id_taxe': paiement['id_taxe'].toString(),
          'id_agent': paiement['id_agent'].toString(),
          'amount_tot': paiement['amount_tot'].toString(),
          'amount_recu': paiement['amount_recu'].toString(),
          'zone': paiement['zone'].toString(),
          'created_at': paiement['created_at'].toString(),
        }).then((_) {
          print("✅ Paiement ajouté : ${paiement['id']}");
        }).catchError((error) {
          print("❌ Erreur ajout paiement : $error");
        });
      }

      // 🔹 Ajout de l'historique des paiements
      for (var history in paiementsHistory) {
        await firestore.collection('paiements_history').add({
          'id_history': history['id'].toString(),
          'id_client': history['id_client'].toString(),
          'id_taxe': history['id_taxe'].toString(),
          'id_agent': history['id_agent'].toString(),
          'amount_recu': history['amount_recu'].toString(),
          'zone': history['zone'].toString(),
          'created_at': history['created_at'].toString(),
        }).then((_) {
          print("✅ Historique ajouté : ${history['id']}");
        }).catchError((error) {
          print("❌ Erreur ajout historique : $error");
        });
      }

      print("🚀 Synchronisation terminée avec succès !");
    } catch (error) {
      print("❌ Erreur lors de la synchronisation : $error");
    }
  }

  Future<void> fetchAndSyncTaxes() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Récupération des données depuis la collection Firestore "taxes"
      QuerySnapshot querySnapshot = await firestore.collection('taxes').get();

      // Extraction des documents sous forme de liste de Map
      List<Map<String, dynamic>> taxes = querySnapshot.docs.map((doc) {
        return {
          'id_collection': doc.id,
          'type': doc['type'],
          'name': doc['name'],
          'amount': doc['amount'],
        };
      }).toList();

      // Insertion ou mise à jour des données dans la table SQLite "taxes"
      await dbHelper.insertOrUpdateTaxes(taxes);

      print("Taxes synchronisées avec succès !");
    } catch (error) {
      print("Erreur lors de la synchronisation des taxes : $error");
    }
  }
}
