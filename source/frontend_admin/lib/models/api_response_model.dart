class ApiResponse<T> {
  final int status;
  final String message;
  final T? data;

  ApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  // Factory constructor để tạo ApiResponse từ JSON
  // fromJsonT là hàm để parse phần 'data' thành kiểu T
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    // Xử lý trường hợp data có thể là null hoặc không tồn tại
    final dynamic dataJson = json['data'];
    return ApiResponse(
      status: json['status'] ?? 0,
      message: json['message'] ?? '',
      data: dataJson != null ? fromJsonT(dataJson) : null,
    );
  }

  // Helper để kiểm tra xem request có thành công theo logic backend không (ví dụ: status 200)
  bool get isSuccess => status == 200; // Giả định status 200 là thành công
}