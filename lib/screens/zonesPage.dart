import 'package:basileapp/screens/singleZonePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ZonesPage extends StatefulWidget {
  const ZonesPage({super.key});

  @override
  State<ZonesPage> createState() => _ZonesPageState();
}

class _ZonesPageState extends State<ZonesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchZones() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('zones').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des zones : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zones"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchZones(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Erreur lors du chargement des zones"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune zone trouvée"));
          } else {
            final zones = snapshot.data!;
            return ListView.builder(
              itemCount: zones.length,
              itemBuilder: (context, index) {
                final zone = zones[index];
                final zoneName = zone['name'] ?? "Nom inconnu";

                return ListTile(
                  title: Text(zoneName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SingleZonePage(zoneName: zoneName),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
