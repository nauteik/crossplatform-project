class ApiResponse<T> {
  final bool status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });
  
  @override
  String toString() {
    return 'ApiResponse{status: $status, message: $message, hasData: ${data != null}}';
  }
} 