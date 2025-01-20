import 'package:basileapp/screens/agentsPage.dart';
import 'package:basileapp/screens/clientPage.dart';
import 'package:basileapp/screens/connexionPage.dart';
import 'package:basileapp/screens/singleAgentPage.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basile'),
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.menu), // Icône pour ouvrir le Drawer
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Ouvre le Drawer
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CircleAvatar(
                  //   radius: 40,
                  //   backgroundImage: AssetImage('assets/profile_picture.png'), // Ajoutez une image dans vos assets
                  // ),
                  SizedBox(height: 10),
                  Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'johndoe@example.com',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Homepage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Clients'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ClientPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Agents'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AgentsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                // Ajoutez une action ici
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon compte'),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SingleAgentPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context); // Ferme la Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConnexionPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Welcome to the Homepage!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
