Strategy Pattern
1. Lý do sử dụng
Nghiệp vụ thanh toán là một quy trình phức tạp, cần hỗ trợ nhiều phương thức khác nhau như: thanh toán qua thẻ tín dụng, qua chuyển khoản ngân hàng, qua ví điện tử MoMo, hoặc thanh toán khi nhận hàng (COD).

Nếu xử lý trực tiếp logic thanh toán cho từng phương thức trong lớp Service hoặc Controller, code sẽ trở nên cồng kềnh, khó mở rộng, và khó bảo trì, đặc biệt khi lớp Service còn xử lý nhiều nghiệp vụ khác thì việc tích hợp toàn bộ logic thanh toán vào lớp Service sẽ khiến lớp này trở nên phức tạp và dài hơn.

Mỗi phương thức thanh toán có quy trình xác thực, kiểm tra, và xử lý riêng biệt. Nếu không tách biệt, việc thêm mới hoặc thay đổi một phương thức sẽ ảnh hưởng đến toàn bộ Service hoặc cả hệ thống. Strategy Pattern có thể giúp cải thiện và giải quyết bài toán trên, áp dung Strategy Pattern vào nghiệp vụ thanh toán sẽ hỗ trợ:
Đóng gói từng thuật toán thanh toán thành các lớp riêng biệt gọi.
Dễ dàng mở rộng, cập nhật hoặc thêm phương thức thanh toán mà không ảnh hướng đến phần còn lại.
Giảm sự phụ thuộc giữa các thành phần, tăng tính module hóa và khả năng bảo trì.
Ngoài ra Template Method Pattern cũng là một mẫu thiết kế cùng loại (Behavior Design Patterns), nhưng nó chỉ phù hợp khi các phương thức thanh toán có chung khung xử lý và chỉ khác biệt ở một vài bước nhỏ, còn Strategy Pattern phù hợp nhất với nghiệp vụ thanh toán vì mỗi phương thức thanh toán là một thuật toán độc lập, có thể thay đổi nên cần sự linh hoạt trong việc chỉnh sửa.

Hình sơ đồ lớp mẫu của Strategy Pattern
2. Sơ đồ lớp
Hình sơ đồ lớp Strategy Pattern của chức năng thanh toán
2.1 Mô tả sơ đồ lớp
Sơ đồ lớp của Strategy Pattern khi áp dụng vào hệ thống có dạng như sau:
PaymentService: Đóng vai trò là context, điều phối việc chọn strategy phù hợp dựa trên phương thức thanh toán của đơn hàng.
PaymentStrategy: Interface định nghĩa phương thức phải có của các phương thức thanh toán.
CreditCardPaymentStrategy, CodPaymentStrategy, BankTransferPaymentStrategy, MomoPaymentStrategy: Các strategy cụ thể (ConcreteStrategy),, mỗi lớp xử lý logic thanh toán riêng biệt cho từng phương thức.
OrderController: Đóng vai trò là Client, khi khách hàng vừa tạo Order thì OrderController sẽ sử dụng PaymentService để tiến hành thanh toán cho Order vừa tạo.
2.2 Nhận xét
Ưu điểm:
Sơ đồ lớp cho thấy Strategy Pattern giúp hệ thống thanh toán dễ mở rộng và bảo trì, việc triển khai, thay thế hoặc bổ sung các phương thức thanh toán mới chỉ cần tạo thêm class strategy mới mà không ảnh hưởng đến các thành phần khác.  
Hệ thống tuân thủ nguyên lý "Open/Closed" và "Dependency Inversion" trong SOLID, giảm sự phụ thuộc giữa các lớp, tăng tính module hóa.  
Việc chọn thuật toán thanh toán được thực hiện động (runtime), giúp linh hoạt khi tích hợp các phương thức mới hoặc thay đổi logic xử lý.
Nhược điểm:
Nếu số lượng strategy quá nhiều, việc quản lý các class strategy có thể trở nên phức tạp.  
Ngoài ra, nếu các strategy có nhiều điểm chung, có thể dẫn đến trùng lặp code giữa các class strategy. 
3. Code
3.1 Lớp Context - PaymentService

Hình phương thức khởi tạo và thuộc tính lớp PaymentService
Phương thức khởi tạo PaymentService():
Biến ‘paymentStrategies’ chứa Map lưu trữ các strategy cụ thể bằng interface tổng quá  
Khởi tạo Map ‘paymentStrategies’ bằng cách duyệt qua từng strategy và lưu vào map với key là tên phương thức thanh toán.

Hình phương thức processPayment() của PaymentService
Phương thức processPayment(Order order, Map<String, Object>):
Lấy phương thức thanh toán từ ‘order’.
Tìm strategy phù hợp trong Map ‘paymentStrategies’ đã khởi tạo.
Giao tiếp với strategy cụ thể qua interface PaymentStrategy, gọi strategy.pay(order, paymentDetails) để thực hiện thanh toán.
Trả về true nếu thanh toán thành công, false nếu thất bại hoặc có exception.

Hình phương thức getSupportedPaymentMethods()
Phương thức getSupportedPaymentMethod():
Trả về danh sách các phương thức thanh toán mà hệ thống hỗ trợ (dựa trên key của map paymentStrategies).
3.2 Lớp Strategy - PaymentStrategy

Hình lớp PaymentStrategy
Lớp PaymentStrategy là interface định nghĩa phương thức pay() và getPaymentMethodName() để các lớp strategy cụ thể (ConcreteStrategy) triển khai
3.2 Các lớp ConcreteStrategy
Mỗi ConcreteStrategy (CreditCard, COD, BankTransfer, Momo) triển khai interface PaymentStrategy và định nghĩa các phương thức xử lý logic thanh toán riêng biệt dựa vào dữ liệu truyền vào, và mỗi lớp sẽ có thuộc tính PAYMENT_METHOD là tên của phương thức thanh toán.
3.2.1 Lớp CodPaymentStrategy

Hình lớp CodPaymentStrategy
Tự động trả về true vì số tiền thanh toán thực tế sẽ được trả khi khách hàng nhận hàng
3.2.2 Lớp BankTransferPaymentStrategy

Hình phương thức pay() của BankTransferPaymentStrategy
Phương thức pay(Order order, Map<String, Object> paymentDetails):
Lấy thông tin chuyển khoản từ paymentDetails (accountNumber, bankName, transferCode).
Kiểm tra hợp lệ thông tin chuyển khoản bằng hàm isValidTransfer().
Nếu hợp lệ, trả về true; ngược lại trả về false.

Hình phương thức isValidTransfer
Phương thức isValidTransfer(String accountNumber, String bankName, String transferCode):
Kiểm tra accountNumber và bankName không rỗng.
Mô phỏng xác thực với xác suất thành công 95%.



3.2.3 Lớp CreditCardPaymentStrategy

Hình phương thức pay() của CreditCardPaymentStrategy
Phương thức pay(Order order, Map<String, Object> paymentDetails):
Lấy thông tin thẻ từ paymentDetails (cardNumber, cardName, expiryDate, cvv).
Kiểm tra hợp lệ thông tin thẻ bằng hàm isValidCardDetails().
Nếu hợp lệ, trả về true (thanh toán thành công); ngược lại trả về false.

Hình phương thức isValidCardDetails của CreditCardPaymentStrategy
Phương thức isValidCardDetails(String cardNumber, String expiryDate, String cvv):
Kiểm tra các trường không rỗng.
Mô phỏng xác thực với xác suất thành công 90%.
3.2.4 Lớp MomoPaymentStrategy

Hình phương thức pay() của MomoPaymentStrategy
Phương thức pay(Order order, Map<String, Object> paymentDetails):
Lấy thông tin ví MoMo từ paymentDetails (phoneNumber, transactionId).
Kiểm tra hợp lệ thông tin MoMo bằng hàm isValidMomoPayment().
Nếu hợp lệ, trả về true; ngược lại trả về false.

Hình phương thức isValidMomoPayment của MomoPaymentStrategy
Phương thức isValidMomoPayment(String phoneNumber, String transactionId):
Kiểm tra phoneNumber không rỗng và có độ dài hợp lệ.
Mô phỏng xác thực với xác suất thành công 98%.
4. Kết luận
Việc áp dụng mẫu thiết kế Strategy cho module thanh toán đã giúp đơn giản hóa đáng kể quá trình xử lý các phương thức thanh toán khác nhau trong hệ thống. Thay vì phải xử lý logic cho từng phương thức thanh toán trực tiếp trong service hoặc controller, toàn bộ các thuật toán thanh toán được đóng gói thành các lớp strategy riêng biệt. Điều này giúp code trở nên rõ ràng, dễ bảo trì, và dễ dàng mở rộng khi cần bổ sung thêm các phương thức thanh toán mới mà không ảnh hưởng đến các thành phần khác.

Bên cạnh đó, Strategy Pattern còn giúp giảm sự phụ thuộc giữa các lớp, tăng tính module hóa và tuân thủ tốt các nguyên lý thiết kế hướng đối tượng như Open/Closed Principle và Dependency Inversion Principle. Nhờ đó, hệ thống thanh toán trở nên linh hoạt, dễ kiểm thử và đáp ứng tốt các yêu cầu mở rộng trong tương lai.



