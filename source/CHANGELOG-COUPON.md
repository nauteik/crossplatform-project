# CHANGELOG: Tính năng Coupon (Frontend)

## Tổng quan

Tài liệu này ghi lại những thay đổi quan trọng trong việc triển khai tính năng Coupon cho phía frontend của ứng dụng thương mại điện tử.

## Thay đổi trong Model

- Cập nhật `OrderModel` để có các trường:
  - couponCode (String?)
  - couponDiscount (double)
  - finalAmount (getter để tính toán sau khi trừ giảm giá)
  - hasCoupon (getter để kiểm tra nếu có coupon)

## Thay đổi trong UI

### Screens

#### OrderHistoryScreen
- Hiển thị mã giảm giá đã áp dụng với icon `discount_outlined`
- Hiển thị số tiền giảm giá với màu xanh lá
- Định dạng lại UI để hiển thị giảm giá bên dưới tổng tiền

#### CheckoutScreen
- Thêm ô nhập mã giảm giá 
- Thêm nút "Áp dụng" để kiểm tra mã giảm giá
- Hiển thị thông báo khi mã giảm giá hợp lệ hoặc không hợp lệ
- Cập nhật phần hiển thị tổng tiền để hiển thị:
  - Tổng tiền
  - Giảm giá (nếu có)
  - Thành tiền

#### GuestCheckoutScreen
- Thêm các tính năng tương tự như CheckoutScreen cho khách không đăng nhập
- Hiển thị thông tin giảm giá trong quá trình thanh toán

#### OrderConfirmationScreen
- Hiển thị thông tin mã giảm giá đã sử dụng
- Hiển thị số tiền giảm giá
- Hiển thị tổng tiền sau khi trừ giảm giá

## Thay đổi trong Business Logic

### Providers

#### PaymentProvider
- Thêm các biến trạng thái:
  - _couponCode: String (lưu mã giảm giá nhập vào)
  - _isCouponValid: bool (trạng thái hợp lệ của mã)
  - _couponDiscount: double (số tiền giảm giá)
- Thêm các phương thức:
  - validateCoupon(): kiểm tra mã giảm giá
  - applyCoupon(): áp dụng mã giảm giá
  - clearCoupon(): xóa mã giảm giá
- Cập nhật các phương thức tạo đơn hàng để gửi thông tin mã giảm giá trong request

## Cải tiến

- **27/07/2024**: Sửa hiển thị giảm giá trong OrderHistoryScreen
- **27/07/2024**: Tối ưu UX khi nhập và áp dụng mã giảm giá

## Sự cố đã được khắc phục

- **27/07/2024**: Sửa lỗi không hiển thị thông tin giảm giá trong lịch sử đơn hàng
- **26/07/2024**: Sửa lỗi hiển thị không đúng định dạng tiền tệ cho giá trị giảm giá

## Các vấn đề đang tồn tại

Không có

## Kế hoạch phát triển trong tương lai

- Thêm gợi ý mã giảm giá có sẵn
- Thêm hiển thị thời hạn sử dụng của mã giảm giá
- Tự động áp dụng mã giảm giá tối ưu
- Thêm danh sách mã giảm giá trong hồ sơ người dùng 