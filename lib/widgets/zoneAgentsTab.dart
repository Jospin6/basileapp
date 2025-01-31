import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Zoneagentstab extends StatefulWidget {
  final String zoneName;
  const Zoneagentstab({super.key, required this.zoneName});

  @override
  State<Zoneagentstab> createState() => _ZoneagentstabState();
}

class _ZoneagentstabState extends State<Zoneagentstab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> agents = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAgentsByZone();
  }

  // 🔹 Récupère tous les agents de la zone
  Future<void> fetchAgentsByZone() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      List<Map<String, dynamic>> fetchedAgents = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        agents = fetchedAgents;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Erreur lors de la récupération des agents : $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isLoading
              ? const Center(
                  child:
                      CircularProgressIndicator()) // 🔄 Loader en attendant la réponse
              : agents.isEmpty
                  ? const Center(
                      child: Text(
                        "⚠️ Aucun agent trouvé",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: agents.length,
                        itemBuilder: (context, index) {
                          final agent = agents[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                  "👤 ${agent['name'] ?? 'Inconnu'} ${agent['surname'] ?? 'Inconnu'}"),
                              subtitle: Text(
                                "📞 ${agent['phone'] ?? 'N/A'}\n📌 Rôle : ${agent['role'] ?? 'Non défini'}",
                              ),
                              trailing: Text("🆔 ID : ${agent['zone'] ?? 'N/A'}"),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
