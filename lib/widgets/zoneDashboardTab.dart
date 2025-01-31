import 'package:basileapp/outils/formatDate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Zonedashboardtab extends StatefulWidget {
  final String zoneName;
  const Zonedashboardtab({super.key, required this.zoneName});

  @override
  State<Zonedashboardtab> createState() => _ZonedashboardtabState();
}

class _ZonedashboardtabState extends State<Zonedashboardtab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Formatdate formatDate = Formatdate();

  List<Map<String, dynamic>> recentPayments = [];
  double totPaid = 0.0;
  double totDebt = 0.0;
  int totUsers = 0;
  int totClients = 0;

  @override
  void initState() {
    super.initState();
    _fetchClientsCount();
    _fetchUsersCount();
    _fetchPaymentsSummary();
    fetchRecentPayments();
  }

  // 🔹 Récupère le nombre de clients dans la zone
  Future<void> _fetchClientsCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('clients')
          .where('zone', isEqualTo: widget.zoneName)
          .get();
      setState(() {
        totClients = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Erreur lors de la récupération des clients : $e");
    }
  }

  // 🔹 Récupère le nombre d'utilisateurs dans la zone
  Future<void> _fetchUsersCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('zone', isEqualTo: widget.zoneName)
          .get();
      setState(() {
        totUsers = querySnapshot.docs.length;
      });
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs : $e");
    }
  }

  // 🔹 Calcule le total des paiements reçus et de la dette
  Future<void> _fetchPaymentsSummary() async {
    try {
      final querySnapshot = await _firestore
          .collection('paiements')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      double totalPaid = 0;
      double totalDebt = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        double amountRecu =
            double.tryParse(data['amount_recu'].toString()) ?? 0.0;
        double amountTot =
            double.tryParse(data['amount_tot'].toString()) ?? 0.0;

        totalPaid += amountRecu;
        if (amountRecu < amountTot) {
          totalDebt += (amountTot - amountRecu);
        }
      }

      setState(() {
        totPaid = totalPaid;
        totDebt = totalDebt;
      });
    } catch (e) {
      print("Erreur lors de la récupération des paiements : $e");
    }
  }

  // 🔹 Récupère les 10 derniers paiements
  Future<void> fetchRecentPayments() async {
    try {
      QuerySnapshot paymentHistorySnapshot = await _firestore
          .collection('paiements_history')
          .where('zone', isEqualTo: widget.zoneName)
          .limit(10)
          .get();

      List<Map<String, dynamic>> allRecentPayments =
          paymentHistorySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {
        recentPayments = allRecentPayments;
      });
    } catch (e) {
      print("Erreur lors de la récupération des paiements récents : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 📌 Affichage des statistiques
          Container(
            margin: const EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("📍 Zone : ${widget.zoneName}",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text("👤 Nombre d'utilisateurs : $totUsers",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("🏠 Nombre de clients : $totClients",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                        "💰 Montant total reçu : \$${totPaid.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("📉 Dette totale : \$${totDebt.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
    
          const SizedBox(height: 20),
    
          // 📌 Affichage des 10 derniers paiements
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10),
            child: Text(
              "📜 10 derniers paiements :",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
    
          recentPayments.isEmpty
              ? const Center(
                  child: Text("⚠️ Aucun paiement récent trouvé",
                      style: TextStyle(fontSize: 16)))
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
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("👤 ${payment['id_client']} | taxe: ${payment['id_taxe'] ?? ''}"),
                        subtitle: Text(
                          "💰 Montant: \$${payment['amount_recu']}\n📅 ${formatDate.formatCreatedAt(payment['created_at'])}",
                        ),
                        trailing: Text("🆔 Agent : ${payment['agent_name'] ?? ''}"),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
