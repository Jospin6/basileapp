import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Zoneclienttab extends StatefulWidget {
  final String zoneName;
  const Zoneclienttab({super.key, required this.zoneName});

  @override
  State<Zoneclienttab> createState() => _ZoneclienttabState();
}

class _ZoneclienttabState extends State<Zoneclienttab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> clients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchClientsByZone();
  }

  // 🔹 Récupère tous les clients de la zone
  Future<void> fetchClientsByZone() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('clients')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      List<Map<String, dynamic>> fetchedClients = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        clients = fetchedClients;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Erreur lors de la récupération des clients : $e");
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
                  child: CircularProgressIndicator()) // 🔄 Affiche un loader
              : clients.isEmpty
                  ? const Center(
                      child: Text(
                        "⚠️ Aucun client trouvé",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                  "👤 ${client['name'] ?? 'Inconnu'}"),
                              subtitle: Text(
                                "📞 ${client['phone'] ?? 'N/A'}\n🏠 ${client['address'] ?? 'Non renseignée'}",
                              ),
                              trailing:
                                  Text("🆔 ${client['id'] ?? 'N/A'}"),
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
