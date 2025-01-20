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
            agent INTEGER,
            created_at TEXT,  
          )  
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS taxes (  
            id INTEGER PRIMARY KEY AUTOINCREMENT,   
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

  // Fonction pour récupérer tous les clients  
  Future<List<Map<String, dynamic>>> getAllClients() async {  
    final db = await database;  
    return await db.query('clients');  
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

  // Fonction pour insérer une taxe  
  Future<void> insertTax(Map<String, dynamic> taxData) async {  
    final db = await database;  
    await db.insert(  
      'taxes',  
      taxData,  
      conflictAlgorithm: ConflictAlgorithm.replace,  
    );  
  } 

  // Fonction pour récupérer toutes les taxes  
  Future<List<Map<String, dynamic>>> getAllTaxes() async {  
    final db = await database;  
    return await db.query('taxes');  
  }  

  // Fonction pour récupérer les taxes par type  
  Future<List<Map<String, dynamic>>> getTaxesByType(String type) async {  
    final db = await database;  
    
    // Exécution de la requête pour récupérer les taxes selon le type  
    final List<Map<String, dynamic>> taxes = await db.query(  
      'taxes',   
      where: 'type = ?',   
      whereArgs: [type]  
    );  
    
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
      SELECT paiements.*, clients.name AS client_name, taxes.amount AS tax_amount, agents.name AS agent_name  
      FROM paiements  
      LEFT JOIN clients ON paiements.id_client = clients.id  
      LEFT JOIN taxes ON paiements.id_taxe = taxes.id  
      LEFT JOIN agents ON paiements.id_agent = agents.id  
    ''');  
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
  Future<List<Map<String, dynamic>>> getPaymentsByAgentWithDifferences(int agentId) async {  
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

  // Fonction pour insérer un paiement historique  
  Future<void> insertPaymentHistory(Map<String, dynamic> paymentHistoryData) async {  
    final db = await database;  
    await db.insert(  
      'paiements_history',  
      paymentHistoryData,  
      conflictAlgorithm: ConflictAlgorithm.replace,  
    );  
  }  

  // Fonction pour récupérer tout l'historique des paiements d'un client  
  Future<List<Map<String, dynamic>>> getPaymentHistoryByClient(int clientId) async {  
    final db = await database;  
    return await db.rawQuery('''  
      SELECT paiements_history.*, clients.name AS client_name, taxes.amount AS tax_amount, agents.name AS agent_name  
      FROM paiements_history  
      LEFT JOIN clients ON paiements_history.id_client = clients.id  
      LEFT JOIN taxes ON paiements_history.id_taxe = taxes.id  
      LEFT JOIN agents ON paiements_history.id_agent = agents.id  
      WHERE paiements_history.id_client = ?  
    ''', [clientId]);  
  }

  // Fonction pour récupérer tout l'historique des paiements d'un agent  
  Future<List<Map<String, dynamic>>> getPaymentHistoryByAgent(int agentId) async {  
    final db = await database;  
    return await db.rawQuery('''  
      SELECT paiements_history.*, clients.name AS client_name, taxes.amount AS tax_amount, agents.name AS agent_name  
      FROM paiements_history  
      LEFT JOIN clients ON paiements_history.id_client = clients.id  
      LEFT JOIN taxes ON paiements_history.id_taxe = taxes.id  
      LEFT JOIN agents ON paiements_history.id_agent = agents.id  
      WHERE paiements_history.id_agent = ?  
    ''', [agentId]);  
  } 

  // Fonction pour modifier un paiement historique  
  Future<void> updatePaymentHistory(int id, Map<String, dynamic> paymentHistoryData) async {  
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
}
