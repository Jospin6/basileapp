class Payment {  
  final int id;  
  final int idClient;  
  final int idTaxe;  
  final int idAgent;  
  final double amountTot;  
  final double amountRecu;  
  final String createdAt;  
  final String clientName; // Ajout du nom du client pour l'affichage  
  final String taxeName; // Ajout du nom de la taxe pour l'affichage  

  Payment({  
    required this.id,  
    required this.idClient,  
    required this.idTaxe,  
    required this.idAgent,  
    required this.amountTot,  
    required this.amountRecu,  
    required this.createdAt,  
    required this.clientName,  
    required this.taxeName,  
  });  
}