import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'basile.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Création des tables si elles n'existent pas déjà
        await db.execute('''
          CREATE TABLE IF NOT EXISTS clients (  
            id INTEGER PRIMARY KEY AUTOINCREMENT,   
            name TEXT,   
            postName TEXT,   
            commerce TEXT,   
            address TEXT,   
            phone TEXT,   
            zone TEXT,   
            agent TEXT,
            created_at TEXT 
          )  
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS taxes (  
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_collection TEXT,   
            type TEXT,   
            name TEXT,  
            amount REAL  
          )  
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS paiements (  
            id INTEGER PRIMARY KEY AUTOINCREMENT,  
            id_client INTEGER,  
            id_taxe INTEGER,  
            id_agent INTEGER,  
            amount_tot REAL,  
            amount_recu REAL,
            zone TEXT,  
            created_at TEXT,  
            FOREIGN KEY (id_client) REFERENCES clients(id),  
            FOREIGN KEY (id_taxe) REFERENCES taxes(id)  
          )  
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS paiements_history (  
            id INTEGER PRIMARY KEY AUTOINCREMENT,  
            id_client INTEGER,  
            id_taxe INTEGER,  
            id_agent INTEGER,  
            amount_recu REAL, 
            zone TEXT, 
            created_at TEXT,  
            FOREIGN KEY (id_client) REFERENCES clients(id),  
            FOREIGN KEY (id_taxe) REFERENCES taxes(id) 
          )  
        ''');
      },
    );
  }

  // Fonction pour insérer un client
  Future<void> insertClient(Map<String, dynamic> clientData) async {
    final db = await database;
    await db.insert(
      'clients',
      clientData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getClientCount() async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result =
          await db.rawQuery('SELECT COUNT(*) AS count FROM clients');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      print('Erreur lors de la récupération du nombre de clients : $e');
      return 0;
    }
  }

  // Fonction pour récupérer tous les clients
  Future<List<Map<String, dynamic>>> getAllClients() async {
    final db = await database;
    return await db.query('clients');
  }

  // Fonction pour récupérer un client
  Future<List<Map<String, dynamic>>> getClient(int id) async {
    final db = await database;
    return await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getClientById(int id) async {
    final db = await database;
    final result = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1, // On limite à un seul résultat
    );

    // Retourner le premier résultat ou null s'il n'y en a pas
    return result.isNotEmpty ? result.first : null;
  }

  // Fonction pour récupérer tous les clients d'une zone spécifique
  Future<List<Map<String, dynamic>>> getClientsByZone(String zone) async {
    final db = await database;
    return await db.query(
      'clients',
      where: 'zone = ?',
      whereArgs: [zone],
    );
  }

  // Fonction pour modifier un client
  Future<void> updateClient(int id, Map<String, dynamic> clientData) async {
    final db = await database;
    await db.update(
      'clients',
      clientData,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fonction pour supprimer un client
  Future<void> deleteClient(int id) async {
    final db = await database;
    await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getLastTenPaymentsByClient(
      int clientId) async {
    final db = await database;
    try {
      // Requête pour récupérer les 10 derniers paiements d'un client
      final result = await db.rawQuery('''
      SELECT * 
      FROM paiements_history 
      WHERE id_client = ? 
      ORDER BY created_at DESC 
      LIMIT 10
    ''', [clientId]);

      return result;
    } catch (e) {
      print('Erreur lors de la récupération des 10 derniers paiements : $e');
      return [];
    }
  }

  Future<double> getTotalPaidByClient(int clientId) async {
    final db = await database;
    try {
      // Exécuter la requête pour obtenir la somme des montants reçus pour un client
      final result = await db.rawQuery('''
      SELECT SUM(amount_recu) AS totalPaid 
      FROM paiements 
      WHERE id_client = ?
    ''', [clientId]);

      // Retourner la somme ou 0 si aucune donnée
      return result[0]['totalPaid'] != null
          ? (result[0]['totalPaid'] as double)
          : 0.0;
    } catch (e) {
      print(
          'Erreur lors de la récupération de la somme payée par le client : $e');
      return 0.0;
    }
  }

  Future<double> getClientDebt(int clientId) async {
    final db = await database;
    try {
      // Exécuter la requête pour obtenir la somme des dettes du client
      final result = await db.rawQuery('''
      SELECT SUM(amount_tot - amount_recu) AS clientDebt 
      FROM paiements 
      WHERE id_client = ? AND amount_tot > amount_recu
    ''', [clientId]);

      // Retourner la somme ou 0 si aucune dette pour ce client
      return result[0]['clientDebt'] != null
          ? (result[0]['clientDebt'] as double)
          : 0.0;
    } catch (e) {
      print('Erreur lors de la récupération de la dette du client : $e');
      return 0.0;
    }
  }

  // Fonction pour insérer une taxe
  Future<void> insertTax(Map<String, dynamic> taxData) async {
    final db = await database;
    await db.insert(
      'taxes',
      taxData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getTax(int id) async {
    final db = await database;
    return await db.query(
      'taxes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fonction pour récupérer toutes les taxes
  Future<List<Map<String, dynamic>>> getAllTaxes() async {
    final db = await database;
    final List<Map<String, dynamic>> taxes = await db.query('taxes');
    return taxes;
  }

  // Fonction pour récupérer les taxes par type
  Future<List<Map<String, dynamic>>> getTaxesByType(String type) async {
    final db = await database;

    // Exécution de la requête pour récupérer les taxes selon le type
    final List<Map<String, dynamic>> taxes =
        await db.query('taxes', where: 'type = ?', whereArgs: [type]);

    return taxes;
  }

  // Fonction pour insérer un paiement
  Future<void> insertPayment(Map<String, dynamic> paymentData) async {
    final db = await database;
    await db.insert(
      'paiements',
      paymentData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fonction pour récupérer tous les paiements avec les informations des clients et des taxes
  Future<List<Map<String, dynamic>>> getAllPayments() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements.*, clients.name AS client_name, clients.postName AS client_postName, taxes.amount AS tax_amount, taxes.name AS tax_name  
      FROM paiements  
      LEFT JOIN clients ON paiements.id_client = clients.id  
      LEFT JOIN taxes ON paiements.id_taxe = taxes.id  
    ''');
  }

  // Fonction pour récupérer les paiements d'un client
  Future<List<Map<String, dynamic>>> fetchClientPaiements(int clientId) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
    SELECT p.*, c.name AS client_name, t.name AS tax_name  
    FROM paiements p  
    INNER JOIN clients c ON p.id_client = c.id  
    INNER JOIN taxes t ON p.id_taxe = t.id  
    WHERE p.id_client = ?  
    ORDER BY p.created_at DESC  
  ''', [clientId]);

    // Retourne une liste de paiements
    return results;
  }

  Future<List<Map<String, dynamic>>> fetchLatestClientsPayments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
    SELECT p.id, p.id_client, p.id_taxe, p.id_agent,   
           p.amount_tot, p.amount_recu, p.created_at,   
           c.name AS client_name, t.name AS taxe_name  
    FROM paiements p  
    JOIN clients c ON p.id_client = c.id  
    JOIN taxes t ON p.id_taxe = t.id   
    ORDER BY p.created_at DESC  
    LIMIT 10  
  ''',
    );

    return maps;
  }

  Future<List<Map<String, dynamic>>> fetchLatestPayments(int clientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT p.id, p.id_client, p.id_taxe, p.id_agent,   
           p.amount_tot, p.amount_recu, p.created_at,   
           c.name AS client_name, t.name AS taxe_name  
    FROM paiements p  
    JOIN clients c ON p.id_client = c.id  
    JOIN taxes t ON p.id_taxe = t.id  
    WHERE p.id_client = ?  
    ORDER BY p.created_at DESC  
    LIMIT 10  
  ''', [clientId]);

    return maps;
  }

  // Fonction pour récupérer le dernier paiement d'un client spécifique
  Future<Map<String, dynamic>?> getLastPaymentForClient(int clientId) async {
    final db = await database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT p.*, c.name AS client_name, t.name AS tax_name  
      FROM paiements p  
      INNER JOIN clients c ON p.id_client = c.id  
      INNER JOIN taxes t ON p.id_taxe = t.id  
      WHERE p.id_client = ?  
      ORDER BY p.created_at DESC  
      LIMIT 1  
    ''', [clientId]);

    if (results.isNotEmpty) {
      return results
          .first; // Retourne le premier résultat qui est le dernier paiement
    }
    return null; // Retourne null s'il n'y a pas de paiement
  }

  // Fonction pour récupérer les paiements effectués par un agent spécifique
  Future<List<Map<String, dynamic>>> getPaymentsByAgent(int agentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements.*, clients.name AS client_name, taxes.amount AS tax_amount, agents.name AS agent_name  
      FROM paiements  
      LEFT JOIN clients ON paiements.id_client = clients.id  
      LEFT JOIN taxes ON paiements.id_taxe = taxes.id  
      LEFT JOIN agents ON paiements.id_agent = agents.id  
      WHERE paiements.id_agent = ?  
    ''', [agentId]);
  }

  // Fonction pour récupérer les paiements effectués par un agent où amount_recu est différent de amount_tot
  Future<List<Map<String, dynamic>>> getPaymentsByAgentWithDifferences(
      int agentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements.*, clients.name AS client_name, taxes.amount AS tax_amount, agents.name AS agent_name  
      FROM paiements  
      LEFT JOIN clients ON paiements.id_client = clients.id  
      LEFT JOIN taxes ON paiements.id_taxe = taxes.id  
      LEFT JOIN agents ON paiements.id_agent = agents.id  
      WHERE paiements.id_agent = ? AND amount_recu <> amount_tot  
    ''', [agentId]);
  }

  // Fonction pour modifier un paiement
  Future<void> updatePayment(int id, Map<String, dynamic> paymentData) async {
    final db = await database;
    await db.update(
      'paiements',
      paymentData,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fonction pour supprimer un paiement
  Future<void> deletePayment(int id) async {
    final db = await database;
    await db.delete(
      'paiements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalDebt() async {
    final db = await database;
    try {
      // Exécuter la requête pour obtenir la somme des dettes
      final result = await db.rawQuery('''
      SELECT SUM(amount_tot - amount_recu) AS totalDebt 
      FROM paiements 
      WHERE amount_tot > amount_recu
    ''');

      // Retourner la somme ou 0 si aucune dette
      return result[0]['totalDebt'] != null
          ? (result[0]['totalDebt'] as double)
          : 0.0;
    } catch (e) {
      print('Erreur lors de la récupération de la dette totale : $e');
      return 0.0;
    }
  }

  // Fonction pour insérer un paiement historique
  Future<void> insertPaymentHistory(
      Map<String, dynamic> paymentHistoryData) async {
    final db = await database;
    await db.insert(
      'paiements_history',
      paymentHistoryData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllPaymentsHistory() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements_history.*, clients.name AS client_name, clients.postName AS client_postName, taxes.amount AS tax_amount, taxes.name AS tax_name   
      FROM paiements_history  
      LEFT JOIN clients ON paiements_history.id_client = clients.id  
      LEFT JOIN taxes ON paiements_history.id_taxe = taxes.id  
    ''');
  }

  // Fonction pour récupérer tout l'historique des paiements d'un client
  Future<List<Map<String, dynamic>>> getPaymentHistoryByClient(
      int clientId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements_history.*, clients.name AS client_name, clients.postName AS client_postName, taxes.amount AS tax_amount, taxes.name AS tax_name   
      FROM paiements_history  
      LEFT JOIN clients ON paiements_history.id_client = clients.id  
      LEFT JOIN taxes ON paiements_history.id_taxe = taxes.id  
      WHERE paiements_history.id_client = ?  
    ''', [clientId]);
  }

  // Fonction pour récupérer tout l'historique des paiements d'un agent
  Future<List<Map<String, dynamic>>> getPaymentHistoryByAgent(
      String agentId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT paiements_history.*, clients.name AS client_name, taxes.amount AS tax_amount  
      FROM paiements_history  
      LEFT JOIN clients ON paiements_history.id_client = clients.id  
      LEFT JOIN taxes ON paiements_history.id_taxe = taxes.id 
      WHERE paiements_history.id_agent = ?  
    ''', [agentId]);
  }

  // Fonction pour modifier un paiement historique
  Future<void> updatePaymentHistory(
      int id, Map<String, dynamic> paymentHistoryData) async {
    final db = await database;
    await db.update(
      'paiements_history',
      paymentHistoryData,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fonction pour supprimer un paiement historique
  Future<void> deletePaymentHistory(int id) async {
    final db = await database;
    await db.delete(
      'paiements_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getDailyAmount() async {
    final db = await database;
    try {
      // Exécuter la requête SQL pour la somme
      final result = await db.rawQuery('''
      SELECT SUM(amount_recu) AS total 
      FROM paiements_history 
    ''');

      // Retourner la somme ou 0 si aucune donnée
      if (result.isNotEmpty && result[0]['total'] != null) {
        return double.parse(result[0]['total'].toString());
      }
      return 0.0;
    } catch (e) {
      print('Erreur lors de la récupération de la somme journalière : $e');
      return 0.0;
    }
  }

  Future<void> insertOrUpdateTaxes(List<Map<String, dynamic>> taxes) async {
    final db = await database;

    for (var tax in taxes) {
      await db.insert(
        'taxes',
        {
          'id': tax['id'],
          'type': tax['type'],
          'name': tax['name'],
          'amount': tax['amount'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
