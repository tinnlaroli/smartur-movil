class ApiConstants {
  // IP de tu computadora (asegúrate de que el Samsung A35 esté en el mismo Wi-Fi)
  static const String baseUrl = 'http://192.168.1.139:3000/api/v2';

  // Endpoints
  static const String register = '/users/register';
  static const String login = '/login';
  static const String twoFactor = '/two-factor';
}