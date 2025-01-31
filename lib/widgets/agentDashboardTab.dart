import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/outils/formatDate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentDashboardTab extends StatefulWidget {
  final String agentID;
  final String agentName;
  final String agentSurname;
  final String agentZone;
  final String agentRole;
  const AgentDashboardTab(
      {super.key,
      required this.agentID,
      required this.agentName,
      required this.agentSurname,
      required this.agentZone,
      required this.agentRole});

  @override
  State<AgentDashboardTab> createState() => _AgentDashboardTabState();
}

class _AgentDashboardTabState extends State<AgentDashboardTab> {
  DatabaseHelper dbHelper = DatabaseHelper();
  Formatdate formatDate = Formatdate();

  Future<List<Map<String, dynamic>>> fetchPaymentHistoryByAgent(
      String idAgent) async {
    try {
      QuerySnapshot historySnapshot = await FirebaseFirestore.instance
          .collection('paiements_history')
          .where('id_agent', isEqualTo: idAgent)
          .get();

      List<Map<String, dynamic>> history = historySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return history;
    } catch (e) {
      print(
          "❌ Erreur lors de la récupération de l'historique des paiements : $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchUserById(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      } else {
        print("⚠️ Aucun utilisateur trouvé avec l'ID : $userId");
        return null;
      }
    } catch (e) {
      print("❌ Erreur lors de la récupération de l'utilisateur : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.agentRole == "Admin")
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchUserById(widget.agentID),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("❌ Erreur : ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text("⚠️ Aucun utilisateur trouvé"));
              } else {
                final userData = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  child: Card(
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 Nom : ${userData['name']}",
                            style: const TextStyle(fontSize: 18)),
                        Text("📧 Email : ${userData['surname']}",
                            style: const TextStyle(fontSize: 18)),
                        Text("📞 Téléphone : ${userData['phone']}",
                            style: const TextStyle(fontSize: 18)),
                        Text("📅 Zone : ${userData['zone']}",
                            style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        if (widget.agentRole != "Admin")
          Card(
            elevation: 4,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width,
              height: 100,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.agentName} ${widget.agentSurname}",
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Zone de ${widget.agentZone}",
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        "Rôle ${widget.agentRole}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(
          height: 10,
        ),
        if (widget.agentRole == "Admin")
          Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchPaymentHistoryByAgent(
                widget.agentID), // Remplace par l'ID réel de l'agent
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("❌ Erreur : ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text("⚠️ Aucun historique trouvé"));
              } else {
                List<Map<String, dynamic>> history = snapshot.data!;
                return ListView.builder(
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final payment = history[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text("${payment['id_client']}"),
                        subtitle: Text(
                          "Montant : \$${payment['amount_recu']}\n ${formatDate.formatCreatedAt(payment['created_at'])}",
                        ),
                        trailing: Text("Agent : ${payment['id_agent']}"),
                      ),
                    );
                  },
                );
              }
            },
          )),
        if (widget.agentRole != "Admin")
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: dbHelper.fetchLatestClientsPayments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucun paiement trouvé.'));
                }

                final payments = snapshot.data!;

                return ListView.builder(
                  itemCount: payments.length,
                  itemBuilder: (context, index) {
                    final payment = payments[index];

                    return ListTile(
                      title: Text(
                          'Montant: ${payment['amount_recu']} \$ | Taxe: ${payment['taxe_name']}'),
                      subtitle: Text(
                          'Client: ${payment['client_name']}\nDate: ${formatDate.formatCreatedAt(payment['created_at'])}'),
                      trailing: payment['amount_recu'] < payment['amount_tot']
                          ? const Icon(Icons.warning,
                              color: Colors
                                  .red) // Icône d'avertissement si paiement incomplet
                          : const Icon(Icons.check,
                              color: Colors
                                  .green), // Icône de validation si paiement complet
                    );
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
