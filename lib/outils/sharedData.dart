import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  late SharedPreferences _prefs;

  // Singleton instance
  static final SharedData _instance = SharedData._internal();

  SharedData._internal();

  factory SharedData() {
    return _instance;
  }

  // Asynchronous initialization
  static Future<void> initialize() async {
    _instance._prefs = await SharedPreferences.getInstance();
  }

  // Synchronous getters
  String getAgentId() => _prefs.getString("id") ?? '';
  String getAgentName() => _prefs.getString("name") ?? '';
  String getAgentSurname() => _prefs.getString("surname") ?? '';
  String getAgentZone() => _prefs.getString("zone") ?? '';
  String getAgentRole() => _prefs.getString("role") ?? '';
  String getNumTeleAdmin() => _prefs.getString("numTeleAdmin") ?? '';
  String getIsAgent() => _prefs.getString("isAgent") ?? '';

  // Method to set shared preferences
  Future<void> setSharedPreferences(
    String id,
    String name,
    String surname,
    String zone,
    String role,
    String numTeleAdmin,
  ) async {
    await _prefs.setString('id', id);
    await _prefs.setString('name', name);
    await _prefs.setString('surname', surname);
    await _prefs.setString('zone', zone);
    await _prefs.setString('role', role);
    await _prefs.setString('numTeleAdmin', numTeleAdmin);
  }

  Future<void> setName(String name) {
    return _prefs.setString('name', name);
  }

  Future<void> setId(String id) {
    return _prefs.setString('id', id);
  }

  Future<void> setSurename(String surname) {
    return _prefs.setString('surname', surname);
  }

  Future<void> setZone(String zone) {
    return _prefs.setString('zone', zone);
  }

  Future<void> setRole(String role) {
    return _prefs.setString('role', role);
  }

  Future<void> setNumTeleAdmin(String numTeleAdmin) {
    return _prefs.setString('numTeleAdmin', numTeleAdmin);
  }

  Future<void> setIsAgent(String isAgent) {
    return _prefs.setString('isAgent', isAgent);
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
