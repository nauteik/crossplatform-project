class ApiConfig {
  // URL cơ sở của API backend
  static const String baseUrl = 'http://localhost:8080';
  
  // URL cho WebSocket endpoint
  static const String websocketUrl = 'ws://localhost:8080/ws';
  
  // Các đường dẫn API khác
  static const String login = '/api/auth/login/local';
  static const String register = '/api/auth/register';
  static const String products = '/api/product/products';
  static const String users = '/api/user/users';
}