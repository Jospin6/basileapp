import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Object?>> login(String phone, String password) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .where('password', isEqualTo: password)
        .get();
    return result;
  }

  Future<List<Map<String, dynamic>>> fetchClientsByZone(String zoneName) async {
    try {
      final querySnapshot = await _firestore
          .collection('clients')
          .where('zone', isEqualTo: zoneName)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des clients : $e");
      return [];
    }
  }

  Future<void> fetchZones(List<String> zonesList) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Récupérer toutes les zones de la collection 'zones'
      QuerySnapshot querySnapshot = await firestore.collection('zones').get();

      // Extraire les noms des zones et les ajouter à la liste
      List<String> zones = querySnapshot.docs.map((doc) {
        return doc['name'] as String; // Assurez-vous que le champ 'name' existe
      }).toList();

      // Mettre à jour la liste passée en paramètre
      zonesList.clear();
      zonesList.addAll(zones);

      print("Zones récupérées avec succès : $zonesList");
    } catch (e) {
      print("Erreur lors de la récupération des zones : $e");
    }
  }

  Future<void> addTaxe(String taxType, String taxName, double taxAmount) async {
    try {
      await FirebaseFirestore.instance.collection('taxes').add({
        'type': taxType,
        'name': taxName,
        'amount': taxAmount,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("Taxe ajoutée :");
      print("Type : $taxType");
      print("Nom : $taxName");
      print("Montant : $taxAmount");
    } catch (e) {
      print("Erreu $e");
    }
  }

  Future<void> addZone(zoneName) async {
    await FirebaseFirestore.instance.collection('zones').add({
      'name': zoneName,
      'createdAt': FieldValue.serverTimestamp(), // Optionnel: pour le timestamp
    });

    print("Zone ajoutée : $zoneName");
  }
}
