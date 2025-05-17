# CHANGELOG

## [1.0.0] - 2023-05-17

### Thêm tính năng Loyalty Points

#### Backend
- Thêm trường `loyaltyPoints` vào model `User` để lưu trữ điểm thưởng của người dùng
- Thêm trường `loyaltyPointsUsed` và `loyaltyPointsDiscount` vào model `Order` để theo dõi điểm thưởng sử dụng trong đơn hàng
- Cập nhật phương thức `addLoyaltyPoints` trong `UserService` để tính toán điểm thưởng đúng (10% giá trị đơn hàng / 1000)
- Thêm phương thức `useLoyaltyPoints` trong `UserService` để sử dụng điểm thưởng khi thanh toán
- Thêm phương thức `getLoyaltyPoints` trong `UserService` để truy vấn số điểm hiện có
- Cập nhật phương thức `calculateLoyaltyPointsEarned` trong `Order` model để tính toán điểm thưởng (10% giá trị / 1000 đồng)
- Cập nhật `OrderService` để hỗ trợ tạo đơn hàng với loyalty points và tính điểm thưởng tự động
- Thêm API endpoints mới trong `OrderController` để quản lý loyalty points

#### Frontend (User)
- Cập nhật model `OrderModel` để hỗ trợ thông tin về loyalty points
- Cập nhật `PaymentProvider` để xử lý loyalty points trong quá trình thanh toán
- Thêm chức năng hiển thị và sử dụng loyalty points trong màn hình thanh toán
- Hiển thị thông tin về loyalty points trong màn hình lịch sử đơn hàng
- Hiển thị thông tin về loyalty points trong màn hình chi tiết đơn hàng
- Cập nhật cách tính và hiển thị số điểm sẽ nhận được khi hoàn thành đơn hàng (10% giá trị / 1000)

#### Frontend (Admin)
- Cập nhật model `Order` để hỗ trợ thông tin về loyalty points
- Thêm hiển thị thông tin về loyalty points trong dialog chi tiết đơn hàng
- Thêm hiển thị thông tin về loyalty points trong bảng quản lý đơn hàng

### Cải thiện UI/UX
- Thêm ScrollView cho dialog chi tiết đơn hàng để người dùng có thể xem đầy đủ thông tin khi có quá nhiều dữ liệu
- Cải thiện cách hiển thị thông tin giảm giá trong bảng quản lý đơn hàng, gộp coupon và loyalty points vào cùng một hàng
- Hiển thị tổng giảm giá dễ dàng theo dõi

### Quy định
- Mỗi 1,000 VND trong giá trị đơn hàng tương đương với 1 điểm thưởng (tính theo 10% giá trị đơn hàng)
- Mỗi điểm thưởng khi sử dụng có giá trị quy đổi là 1,000 VND 