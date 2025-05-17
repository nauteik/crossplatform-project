# CHANGELOG: Tính năng Coupon

## Tổng quan

Tài liệu này ghi lại những thay đổi quan trọng trong việc triển khai tính năng Coupon cho hệ thống thương mại điện tử.

## Thay đổi trong Backend

### Model

- Thêm trường `couponCode` và `couponDiscount` vào class `Order`
- Thêm phương thức `applyCoupon()` và `getFinalAmount()` vào `Order`
- Tạo model `Coupon` mới với các trường:
  - id (String)
  - code (String)
  - value (double)
  - maxUses (int)
  - usedCount (int)
  - creationTime (LocalDateTime)
  - ordersApplied (List\<String\>)
  - valid (boolean)

### Service

#### CouponService
- Thêm các phương thức:
  - `createCoupon(Coupon coupon)` - Tạo coupon mới
  - `getAllCoupons()` - Lấy danh sách tất cả coupon
  - `getCouponById(String id)` - Lấy coupon theo id
  - `getCouponByCode(String code)` - Lấy coupon theo mã
  - `validateCoupon(String code)` - Kiểm tra coupon có hợp lệ không
  - `getCouponDetails(String code)` - Lấy thông tin chi tiết của coupon
  - `applyCouponToOrder(String couponCode, String orderId)` - Áp dụng coupon vào đơn hàng
  - `updateCoupon(Coupon coupon)` - Cập nhật thông tin coupon
  - `deleteCoupon(String id)` - Xóa coupon

#### OrderService
- Thêm phương thức `createOrderWithCoupon()` để tạo đơn hàng với mã giảm giá
- Thêm phương thức `applyCouponToOrder()` để áp dụng mã giảm giá vào đơn hàng đã tạo
- Cập nhật phương thức `createOrder()` để tạo đơn hàng trực tiếp từ selectedItemIds mà không cần kiểm tra/sử dụng cart
- Cập nhật phương thức `sendOrderConfirmationEmail()` để hiển thị thông tin giảm giá trong email

### Controller

#### CouponController
- Thêm endpoint `/api/coupons` (GET) để lấy tất cả coupon
- Thêm endpoint `/api/coupons` (POST) để tạo coupon mới
- Thêm endpoint `/api/coupons/check/{code}` để kiểm tra tính hợp lệ của coupon
- Thêm endpoint `/api/coupons/{id}` (PUT) để cập nhật coupon
- Thêm endpoint `/api/coupons/{id}` (DELETE) để xóa coupon

#### OrderController
- Cập nhật `createUserOrder()` và `createGuestOrder()` để hỗ trợ coupon
- Thêm endpoint `/api/orders/{orderId}/apply-coupon` để áp dụng mã giảm giá vào đơn hàng
- Loại bỏ việc tạo cart trong quá trình tạo đơn hàng cho khách không đăng nhập

### Repository

- Thêm `CouponRepository` để tương tác với collection Coupon trong database

## Thay đổi trong Frontend

### Model

- Thêm `CouponModel` với các trường:
  - id (String)
  - code (String)
  - value (double)
  - maxUses (int)
  - usedCount (int)
  - creationTime (DateTime)
  - ordersApplied (List\<String\>)
  - valid (bool)
  - formattedValue (getter để hiển thị giá trị đã định dạng)
  - formattedCreationTime (getter để hiển thị thời gian tạo coupon đã định dạng)

- Cập nhật `OrderModel` để có các trường:
  - couponCode (String?)
  - couponDiscount (double)
  - finalAmount (tính toán sau khi trừ giảm giá)

### Repository

- Thêm `CouponRepository` với các phương thức:
  - `fetchCoupons()` - Lấy danh sách coupon
  - `addCoupon(String code, double value, int maxUses)` - Thêm coupon mới
  - `deleteCoupon(String couponId)` - Xóa coupon

### Providers

#### CouponProvider
- Quản lý state của danh sách coupon
- Thêm các phương thức:
  - `loadCoupons()` - Tải danh sách coupon
  - `addCoupon()` - Thêm coupon mới
  - `deleteCoupon()` - Xóa coupon

#### PaymentProvider
- Thêm các trường và phương thức để quản lý mã giảm giá:
  - `_couponCode` (String)
  - `_isCouponValid` (bool)
  - `_couponDetails` (Map<String, dynamic>)
  - `_isCheckingCoupon` (bool)
  - `checkCoupon(String code)` - Kiểm tra tính hợp lệ của coupon
  - `setCouponCode(String code)` - Đặt mã coupon
- Cập nhật các phương thức tạo đơn hàng để gửi mã giảm giá

### Screens

#### Quản lý Admin

- Thêm màn hình `CouponsManagementScreen`:
  - Hiển thị danh sách coupon với thông tin mã, giá trị, số lần sử dụng
  - Chức năng thêm coupon mới với mã, giá trị và số lần sử dụng tối đa
  - Hiển thị chi tiết coupon bao gồm danh sách đơn hàng đã áp dụng
  - Chức năng xóa coupon

#### Giao diện người dùng

##### CheckoutScreen & GuestCheckoutScreen
- Thêm ô nhập mã giảm giá
- Thêm nút kiểm tra mã giảm giá
- Hiển thị thông tin giảm giá khi áp dụng mã thành công:
  - Mã giảm giá đã áp dụng
  - Giá trị giảm giá
  - Số lần sử dụng còn lại
  - Tổng tiền sau khi áp dụng giảm giá

##### OrderConfirmationScreen
- Hiển thị thông tin giảm giá và mã đã sử dụng
- Hiển thị tổng tiền sau khi giảm giá

##### OrderHistoryScreen
- Hiển thị mã giảm giá đã áp dụng
- Hiển thị số tiền giảm giá

## Cải tiến

- **27/07/2024**: Sửa việc hiển thị giảm giá trong OrderHistoryScreen
- **27/07/2024**: Sửa logic tạo đơn hàng để không phụ thuộc vào giỏ hàng (cart)
- **27/07/2024**: Loại bỏ việc khởi tạo giỏ hàng khi tạo đơn hàng cho khách không đăng nhập
- **28/07/2024**: Cải thiện giao diện hiển thị mã giảm giá trong màn hình thanh toán
- **28/07/2024**: Bổ sung hiển thị tổng tiền sau khi áp dụng giảm giá
- **28/07/2024**: Hoàn thiện tính năng quản lý coupon trong giao diện admin

## Sự cố đã được khắc phục

- **26/07/2024**: Sửa lỗi kiểu dữ liệu khi couponValue là một số nguyên thay vì số thực
- **27/07/2024**: Sửa lỗi không hiển thị thông tin giảm giá trong OrderHistoryScreen
- **28/07/2024**: Sửa lỗi khi parse giá trị coupon từ backend (xử lý cả trường hợp int và double)
- **28/07/2024**: Sửa lỗi hiển thị ngày tạo coupon không đúng định dạng
- **28/07/2024**: Sửa lỗi không cập nhật usedCount khi áp dụng coupon vào đơn hàng

## Các vấn đề đang tồn tại

Không có

## Kế hoạch phát triển trong tương lai

- Thêm tính năng giới hạn áp dụng coupon theo danh mục sản phẩm
- Thêm chức năng tạo coupon theo phần trăm giảm giá
- Thêm báo cáo thống kê về hiệu quả các chương trình coupon 
- Thêm tính năng coupon có thời hạn sử dụng (startDate và endDate)
- Phát triển tính năng thông báo coupon sắp hết hạn cho người dùng 