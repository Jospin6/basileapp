import 'package:shared_preferences/shared_preferences.dart';  

class SharedData {  
  late SharedPreferences prefs;  

  // Constructor to initialize SharedPreferences  
  SharedData({required this.prefs});  

  // Get agentID, agentName, agentSurname, agentZone, agentRole  
  Future<String?> getAgentId() async {  
    return prefs.getString("id");  
  }  

  Future<String?> getAgentName() async {  
    return prefs.getString("name");  
  }  

  Future<String?> getAgentSurname() async {  
    return prefs.getString("surname");  
  }  

  Future<String?> getAgentZone() async {  
    return prefs.getString("zone");  
  }  

  Future<String?> getAgentRole() async {  
    return prefs.getString("role");  
  } 

  Future<String?> getNumTeleAdmin() async {  
    return prefs.getString("numTeleAdmin");  
  }  

  Future<void> setSharedPreferences(String id, String name, String surname,  
      String zone, String role, String numTeleAdmin) async {  
    prefs.setString('id', id);  
    prefs.setString('name', name);  
    prefs.setString('surname', surname);  
    prefs.setString('zone', zone);  
    prefs.setString('role', role);  
    prefs.setString('numTeleAdmin', numTeleAdmin);  
  }  
}