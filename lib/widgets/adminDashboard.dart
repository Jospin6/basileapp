import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int userCount = 0;
  int clientCount = 0;
  double totalReceived = 0.0;
  double totalDebt = 0.0;
  List<Map<String, dynamic>> recentPayments = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch the number of users
      QuerySnapshot usersSnapshot = await firestore.collection('users').get();
      userCount = usersSnapshot.size;

      // Fetch the number of clients
      QuerySnapshot clientsSnapshot = await firestore.collection('clients').get();
      clientCount = clientsSnapshot.size;

      // Fetch the payments data to calculate total received and total debt
      QuerySnapshot paymentsSnapshot = await firestore.collection('paiements').get();
      double received = 0.0;
      double debt = 0.0;

      for (var doc in paymentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        received += data['amount_recu'] ?? 0.0;
        debt += (data['amount_tot'] ?? 0.0) - (data['amount_recu'] ?? 0.0);
      }

      totalReceived = received;
      totalDebt = debt;

      // Fetch the 10 most recent payment history entries
      QuerySnapshot paymentHistorySnapshot = await firestore
          .collection('paiements_history')
          .orderBy('created_at', descending: true)
          .limit(10)
          .get();

      recentPayments = paymentHistorySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      setState(() {});
    } catch (e) {
      print("Erreur lors de la récupération des données : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tableau de Bord Administrateur"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display stats
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
                      Text("Montant total reçu : \$${totalReceived.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text("Dette totale : \$${totalDebt.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Display recent payment history
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
      ),
    );
  }
}
