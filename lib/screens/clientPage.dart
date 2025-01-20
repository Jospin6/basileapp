import 'package:basileapp/db/database_helper.dart';
import 'package:basileapp/screens/newClientPage.dart';  
import 'package:basileapp/screens/singleClientPage.dart'; // Ajoutez cette importation pour SingleClientPage  
import 'package:flutter/material.dart';  

class ClientPage extends StatefulWidget {  
  const ClientPage({super.key});  

  @override  
  State<ClientPage> createState() => _ClientPageState();  
}  

class _ClientPageState extends State<ClientPage> {  
  List<Map<String, dynamic>> _clients = []; // Liste pour stocker les clients  
  final String _selectedZone = "VotreZone"; // Remplacez cela par la zone que vous souhaitez utiliser  

  @override  
  void initState() {  
    super.initState();  
    _fetchClients(); // Récupération des clients lors de l'initialisation de l'état  
  }  

  Future<void> _fetchClients() async {  
    DatabaseHelper dbHelper = DatabaseHelper();  
    List<Map<String, dynamic>> clients = await dbHelper.getClientsByZone(_selectedZone);  
    setState(() {  
      _clients = clients; // Met à jour l'état avec la liste des clients  
    });  
  }  

  @override  
  void dispose() {  
    super.dispose();  
  }  

  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      appBar: AppBar(title: const Text("Client Page")),  
      body: Column(  
        children: [  
          Row(  
            mainAxisAlignment: MainAxisAlignment.end,  
            children: [  
              TextButton(  
                onPressed: () {  
                  Navigator.push(  
                    context,  
                    MaterialPageRoute(  
                      builder: (context) => const NewClientPage(),  
                    ),  
                  );  
                },  
                child: const Text("Add Client"),  
              ),  
            ],  
          ),  
          const SizedBox(height: 10), // Ajoute un espacement entre le bouton et la liste  
          Expanded(  
            child: ListView.builder(  
              itemCount: _clients.length,  
              itemBuilder: (context, index) {  
                final client = _clients[index];  
                return ListTile(  
                  title: Text(client['name'] ?? 'Nom non disponible'),  
                  subtitle: Text(client['postName'] ?? 'Post-nom non disponible'),  
                  onTap: () {  
                    // Naviguer vers SingleClientPage avec l'ID du client  
                    Navigator.push(  
                      context,  
                      MaterialPageRoute(  
                        builder: (context) => SingleClientPage(clientID: client['id']),  
                      ),  
                    );  
                  },  
                );  
              },  
            ),  
          ),  
        ],  
      ),  
    );  
  }  
}
