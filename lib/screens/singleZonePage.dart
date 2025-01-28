import 'package:basileapp/screens/singleAgentPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SingleZonePage extends StatefulWidget {
  final String zoneName;
  const SingleZonePage({super.key, required this.zoneName});

  @override
  State<SingleZonePage> createState() => _SingleZonePageState();
}

class _SingleZonePageState extends State<SingleZonePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> _fetchClientsCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('clients')
          .where('zone', isEqualTo: widget.zoneName)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print("Erreur lors de la récupération des clients : $e");
      return 0;
    }
  }

  Future<int> _fetchUsersCount() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('zone', isEqualTo: widget.zoneName)
          .get();
      return querySnapshot.docs.length;
    } catch (e) {
      print("Erreur lors de la récupération des utilisateurs : $e");
      return 0;
    }
  }

  Future<Map<String, double>> _fetchPaymentsSummary() async {
    try {
      final querySnapshot = await _firestore
          .collection('paiements')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      double totalPaid = 0;
      double totalDebt = 0;

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalPaid += (data['amount_recu'] ?? 0).toDouble();
        totalDebt += ((data['amount_tot'] ?? 0).toDouble() -
            (data['amount_recu'] ?? 0).toDouble());
      }

      return {"totalPaid": totalPaid, "totalDebt": totalDebt};
    } catch (e) {
      print("Erreur lors de la récupération des paiements : $e");
      return {"totalPaid": 0, "totalDebt": 0};
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAgents() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('zone', isEqualTo: widget.zoneName)
          .where('role', isEqualTo: 'agent') // Filtrer uniquement les agents
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des agents : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: const Color.fromRGBO(173, 104, 0, 1),
        title: Text(
          "Zone : ${widget.zoneName}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                  onPressed: () {}, child: const Text("Clients de la zone"))
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder(
              future: Future.wait([
                _fetchClientsCount(),
                _fetchUsersCount(),
                _fetchPaymentsSummary(),
                _fetchAgents()
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Erreur lors du chargement"));
                } else {
                  final data = snapshot.data as List<dynamic>;
                  final clientsCount = data[0] as int;
                  final usersCount = data[1] as int;
                  final paymentsSummary = data[2] as Map<String, double>;
                  final agents = data[3] as List<Map<String, dynamic>>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nombre de clients : $clientsCount",
                          style: const TextStyle(fontSize: 18)),
                      Text("Nombre d'utilisateurs : $usersCount",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          "Montant total payé : ${paymentsSummary['totalPaid']} \$",
                          style: const TextStyle(fontSize: 18)),
                      Text(
                          "Total des dettes : ${paymentsSummary['totalDebt']} \$",
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 20),
                      const Text("Agents :", style: TextStyle(fontSize: 20)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: agents.length,
                          itemBuilder: (context, index) {
                            final agent = agents[index];
                            final agentName = agent['name'] ?? "Nom inconnu";
                            final agentID = agent['id'] ?? "";

                            return ListTile(
                              title: Text(agentName),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleAgentPage(
                                      agentID: agentID,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
