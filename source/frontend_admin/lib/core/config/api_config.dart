class ApiConfig {
  // URL cơ sở của API backend
  // static const String baseUrl = 'http://localhost:8080';
  static const String baseUrl = 'https://hkt-backend-a2bb8a1df288.herokuapp.com';
  
  // URL cho WebSocket endpoint
  // static const String websocketUrl = 'ws://localhost:8080/ws';
  static const String websocketUrl = 'wss://hkt-backend-a2bb8a1df288.herokuapp.com/ws';
  
  // Các đường dẫn API khác
  static const String login = '/api/auth/login/local';
  static const String register = '/api/auth/register';
  static const String products = '/api/product/products';
  static const String users = '/api/user/users';
}