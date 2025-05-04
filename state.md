State Pattern  
1. Lý do sử dụng  

Trong hệ thống thương mại điện tử, quá trình xử lý đơn hàng (Order) thường trải qua nhiều trạng thái khác nhau như: chờ thanh toán (PENDING), đã thanh toán (PAID), đang giao hàng (SHIPPED), đã giao (DELIVERED), thất bại (FAILED), hoặc đã hủy (CANCELLED). Mỗi trạng thái này đều có các quy tắc nghiệp vụ và hành vi riêng biệt, ví dụ: chỉ đơn hàng đã thanh toán mới được chuyển sang trạng thái giao hàng, hoặc đơn hàng đã giao không thể hủy.  

Nếu xử lý trực tiếp logic chuyển đổi trạng thái trong Service hoặc Controller, mã nguồn sẽ trở nên phức tạp, khó bảo trì, và dễ phát sinh lỗi khi mở rộng thêm trạng thái mới hoặc thay đổi quy tắc nghiệp vụ. State Pattern giúp giải quyết vấn đề này bằng cách đóng gói từng trạng thái thành các lớp riêng biệt, mỗi lớp chịu trách nhiệm xử lý logic cho trạng thái tương ứng. Nhờ đó, hệ thống trở nên linh hoạt, dễ mở rộng, và tuân thủ nguyên lý Open/Closed trong SOLID.

2. Sơ đồ lớp  

State Pattern cho chức năng quản lý trạng thái đơn hàng gồm các thành phần chính:
- **OrderState**: Interface (hoặc abstract class) định nghĩa các hành vi chung cho mọi trạng thái đơn hàng, ví dụ: process(), cancel(), getStateName().
- **PendingState, PaidState, ShippedState, DeliveredState, CancelledState, FailedState**: Các lớp trạng thái cụ thể (Concrete State), mỗi lớp triển khai logic xử lý riêng cho từng trạng thái đơn hàng.
- **OrderStateManager**: Đóng vai trò là Context, chịu trách nhiệm lưu trữ trạng thái hiện tại của đơn hàng, điều phối việc chuyển đổi trạng thái bằng cách ủy quyền cho đối tượng trạng thái tương ứng.
- **Order**: Đối tượng nghiệp vụ đại diện cho đơn hàng, chứa thông tin trạng thái hiện tại (OrderStatus) và các thuộc tính khác.

3. Nhận xét  

**Ưu điểm:**  
- State Pattern giúp tách biệt logic xử lý của từng trạng thái, tránh tình trạng code “rẽ nhánh” phức tạp trong Service hoặc Controller.
- Dễ dàng mở rộng hoặc thay đổi quy tắc nghiệp vụ cho từng trạng thái mà không ảnh hưởng đến các phần còn lại của hệ thống.
- Tuân thủ nguyên lý Open/Closed và Single Responsibility trong SOLID.
- Dễ kiểm thử, bảo trì, và truy vết hành vi của từng trạng thái đơn hàng.

**Nhược điểm:**  
- Số lượng class có thể tăng lên đáng kể nếu hệ thống có nhiều trạng thái phức tạp.
- Nếu không tổ chức hợp lý, việc khởi tạo các đối tượng trạng thái có thể gây dư thừa bộ nhớ (có thể khắc phục bằng cách dùng Singleton hoặc chia sẻ instance nếu cần).

4. Kết luận  

Việc áp dụng State Pattern cho module quản lý trạng thái đơn hàng giúp hệ thống trở nên linh hoạt, dễ mở rộng, kiểm soát tốt quá trình chuyển đổi trạng thái phức tạp của đơn hàng. Mỗi trạng thái được đóng gói thành một lớp riêng biệt, dễ dàng bổ sung hoặc thay đổi logic mà không ảnh hưởng đến các phần khác. Nhờ đó, hệ thống đáp ứng tốt các yêu cầu nghiệp vụ thay đổi liên tục, giảm lỗi phát sinh do xử lý thủ công, và nâng cao khả năng bảo trì, kiểm thử cho module đơn hàng.