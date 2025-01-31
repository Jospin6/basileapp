import 'package:basileapp/screens/zonesPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int userCount = 0;
  int clientCount = 0;
  double totalReceived = 0.0;
  double totalDebt = 0.0;
  List<Map<String, dynamic>> recentPayments = [];

  @override
  void initState() {
    super.initState();
    fetchUserCount();
    fetchClientCount();
    fetchPaymentsData();
    fetchRecentPayments();
  }

  // 🔹 Récupérer le nombre d'utilisateurs
  Future<void> fetchUserCount() async {
    QuerySnapshot usersSnapshot = await firestore.collection('users').get();
    setState(() {
      userCount = usersSnapshot.size;
    });
    print("👤 Nombre d'utilisateurs : $userCount");
  }

  // 🔹 Récupérer le nombre de clients
  Future<void> fetchClientCount() async {
    QuerySnapshot clientsSnapshot = await firestore.collection('clients').get();
    setState(() {
      clientCount = clientsSnapshot.size;
    });
    print("👥 Nombre de clients : $clientCount");
  }

  // 🔹 Récupérer les paiements et calculer les totaux
  Future<void> fetchPaymentsData() async {
    QuerySnapshot paymentsSnapshot =
        await firestore.collection('paiements').get();

    double received = 0.0;
    double debt = 0.0;

    for (var doc in paymentsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      double amountRecu =
          double.tryParse(data['amount_recu'].toString()) ?? 0.0;
      double amountTot = double.tryParse(data['amount_tot'].toString()) ?? 0.0;

      received += amountRecu;

      // 🔹 Ajouter à la dette uniquement si le montant reçu est inférieur au montant total
      if (amountRecu < amountTot) {
        debt += (amountTot - amountRecu);
      }
    }

    setState(() {
      totalReceived = received;
      totalDebt = debt;
    });

    print("💰 Montant total reçu : $totalReceived, Dette totale : $totalDebt");
  }

  // 🔹 Récupérer les 10 derniers paiements
  Future<void> fetchRecentPayments() async {
    List<Map<String, dynamic>> allrecentPayments = [];
    QuerySnapshot paymentHistorySnapshot =
        await firestore.collection('paiements_history').limit(10).get();

    allrecentPayments = paymentHistorySnapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();

    setState(() {
      recentPayments = allrecentPayments;
    });

    print("📜 Derniers paiements récupérés : ${recentPayments.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ZonesPage(),
                    ),
                  ),
                  child: const Text("Zones"),
                ),
              ],
            ),

            // 🔹 Affichage des statistiques
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Nombre d'utilisateurs : $userCount",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Nombre de clients : $clientCount",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                        "Montant total reçu : \$${totalReceived.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text("Dette totale : \$${totalDebt.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Affichage des paiements récents
            const Text(
              "10 dernières entrées de paiements :",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentPayments.length,
              itemBuilder: (context, index) {
                final payment = recentPayments[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text("Client ID : ${payment['id_client']}"),
                    subtitle: Text(
                        "Montant reçu : \$${payment['amount_recu']}\nDate : ${payment['created_at']}"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
