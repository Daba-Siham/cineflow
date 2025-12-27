
// Création de la classe ApiConstants qui regroupe les constantes liées à L'API
class ApiConstants {
  // Clé qui autorise à l'application d'accéder aux données OMDb.
  static const String omdbApiKey = '36c433eb';

  // URL de base de l’API OMDb
  static const String omdbBaseUrl = 'https://www.omdbapi.com/';
  
  static const String baseUrl = 'http://192.168.1.10:5000/api';
  // static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String authBase = '$baseUrl/auth';
  static const String favoritesBase = '$baseUrl/favorites';
  static const String historyBase = '$baseUrl/history';
}