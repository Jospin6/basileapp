class Formatdate {
  String formatCreatedAt(String createdAt) {
    try {
      // Parse la date depuis la chaîne au format 'YYYY-MM-DD HH:MM:SS'
      final dateTime = DateTime.parse(createdAt);

      // Crée un format lisible 'DD-MM-YYYY à HH:MM'
      final formattedDate = '${dateTime.day.toString().padLeft(2, '0')}-'
          '${dateTime.month.toString().padLeft(2, '0')}-'
          '${dateTime.year} à '
          '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';

      return formattedDate;
    } catch (e) {
      // En cas d'erreur, retourner une chaîne vide ou un message par défaut
      print('Erreur lors du formatage de la date : $e');
      return 'Date invalide';
    }
  }
}
