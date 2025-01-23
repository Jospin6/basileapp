import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ClientsZonePage extends StatefulWidget {
  final String zoneName;
  const ClientsZonePage({super.key, required this.zoneName});

  @override
  State<ClientsZonePage> createState() => _ClientsZonePageState();
}

class _ClientsZonePageState extends State<ClientsZonePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchClientsByZone() async {
    try {
      final querySnapshot = await _firestore
          .collection('clients')
          .where('zone', isEqualTo: widget.zoneName)
          .get();

      return querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des clients : $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clients de la zone : ${widget.zoneName}"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchClientsByZone(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des clients"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun client trouvé"));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              final clientName = client['name'] ?? "Nom inconnu";
              final clientId = client['id'] ?? "";

              return ListTile(
                title: Text(clientName),
                subtitle: Text("ID : $clientId"),
              );
            },
          );
        },
      ),
    );
  }
}
