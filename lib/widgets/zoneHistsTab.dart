import 'package:basileapp/outils/formatDate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Zonehiststab extends StatefulWidget {
  final String zoneName;
  const Zonehiststab({super.key, required this.zoneName});

  @override
  State<Zonehiststab> createState() => _ZonehiststabState();
}

class _ZonehiststabState extends State<Zonehiststab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Formatdate formatDate = Formatdate();

  @override
  void initState() {
    super.initState();
    fetchRecentPayments();
  }

  // 🔹 Récupère les 10 derniers paiements
  Future<void> fetchRecentPayments() async {
    try {
      QuerySnapshot paymentHistorySnapshot = await _firestore
          .collection('paiements_history')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      List<Map<String, dynamic>> allRecentPayments =
          paymentHistorySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        recentPayments = allRecentPayments;
      });
    } catch (e) {
      print(" ⚠️ Erreur lors de la récupération des paiements récents : $e");
    }
  }

  List<Map<String, dynamic>> recentPayments = [];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: recentPayments.isEmpty
          ? const Center(
              child: CircularProgressIndicator())
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPayments.length,
              itemBuilder: (context, index) {
                final payment = recentPayments[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text("${payment['id_client']}"),
                    subtitle: Text(
                      "💰 Montant: \$${payment['amount_recu']}\n📅 ${formatDate.formatCreatedAt(payment['created_at'])}",
                    ),
                    trailing: Text("🆔 Agent : ${payment['id_agent']}"),
                  ),
                );
              },
            ),
    );
  }
}
