Hướng dẫn setup Project:
Backend Setup:
* Yêu cầu:
    + Java 21 SDK
    + Maven
    + MongoDB

* Config:
    + Cần cấu hình đường dẫn database trong file application.properties (BE\ecommerceproject\ecommerceproject\src\main\resources\application.properties)
    + Nếu cấu hình đúng đường dẫn database để backend kết nối, khi chạy ứng dụng project sẽ tự động tạo bảng và tự thêm dữ liệu nếu chưa có (bằng file DataLoader.java được inject trong project)

* Chạy project backend:
- Chạy bằng CLI
    + Mở CLI ở thư mục BE/ecommerceproject
    + Chạy lệnh "mvn clean install"
    + Chạy lệnh "mvn spring-boot:run"
- Chạy bằng IDE (Khuyên dùng IntelliJ):
    + Sử dụng IntelliJ mở project backend
    + Nhấn nút Start và chạy project, IntelliJ hỗ trợ tốt các package và dependencies để chạy project

Frontend Setup:
- Có hai project frontend cho user và admin, và cả hai đều có cách setup chung
* Yêu cầu:
    + Flutter SDK (v3.6.1 trở lên)
    + Dart SDK (Thường được cài tự động khi cái Flutter SDK)
    + Android Studio (Để tạo thiết bị điện thoại ảo)

* Config:
    + 2 Project frontend đã được clean và xóa package khi nộp
    + Cần phải mở CLI ở trong 2 thư mục frontend-user, frontend-admin sau đó chạy lệnh "flutter pub get" để tải package

* Chạy project
- Đảm bảo backend được chạy thành công để frontend có thể fetch dữ liệu.
- Nếu muốn chạy trên thiết bị ảo cần khởi động thiết bị ảo trước (bằng Android Studio, hoặc mở thiết bị ảo đã tạo trên Android Studio qua VSCode).
- Chạy bằng CLI:
    + Mở CLI ở thư mục project muốn chạy
    + Chạy lệnh "flutter run"
    + Chọn nền tảng hoạt động để chạy (Edge, Chrome, Thiết bị ảo,...)
- Chạy bằng IDE (VSCode, Android Studio,...):
    + Mở Project bẳng IDE
    + Nhấn nút Start để chạy project và chọn nền tảng hoạt động cho project (Edge, Chrome, Thiết bị ảo,...)
    
Thông tin tài khoản trong hệ thống:
Tài khoản admin: admin, mật khẩu: admin123
Tài khoản user: user, mật khẩu: user123


