import 'package:basileapp/services/firebaseServices.dart';
import 'package:flutter/material.dart';

class ClientsZonePage extends StatefulWidget {
  final String zoneName;
  const ClientsZonePage({super.key, required this.zoneName});

  @override
  State<ClientsZonePage> createState() => _ClientsZonePageState();
}

class _ClientsZonePageState extends State<ClientsZonePage> {
  FirebaseServices firebaseServices = FirebaseServices();
  
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
        title: Text("Clients de la zone : ${widget.zoneName}", style: const TextStyle(color: Colors.white),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: firebaseServices.fetchClientsByZone(widget.zoneName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement des clients"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("⚠️ Aucun client trouvé"));
          }

          final clients = snapshot.data!;
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              final clientName = client['name'] ?? "Nom inconnu";
              final clientSurName = client['postName'] ?? "Nom inconnu";
              // final clientId = client['id'] ?? "";
              final phone = client['phone'] ?? "phone";
              final commerce = client['commerce'] ?? "commerce";

              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text("$clientName $clientSurName"),
                  subtitle: Text("$commerce \n $phone"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
