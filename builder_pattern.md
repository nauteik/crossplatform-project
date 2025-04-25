Facade Pattern
1. Lý do sử dụng
Trong hệ thống thương mại điện tử, các nghiệp vụ phức tạp thường đòi hỏi sự tương tác và phối hợp của nhiều thành phần khác nhau. Ví dụ điển hình là các nghiệp vụ: "Thêm sản phẩm vào giỏ hàng", "Xóa sản phẩm khỏi giỏ hàng", “Thanh toán sản phẩm”,... Các nghiệp vụ này không chỉ đơn thuần là thao tác với giỏ hàng mà còn liên quan đến việc kiểm tra thông tin người dùng, kiểm tra và cập nhật số lượng tồn kho của sản phẩm, tính tiền, thanh toán cho sản phẩm.
Hệ thống được xây dựng theo mô hình 3 lớp (Controller, Service, Repository). Nếu xử lý trực tiếp các nghiệp vụ phức tạp này trong lớp Controller, Service hoặc một lớp client khác, lớp đó sẽ phải phụ thuộc trực tiếp vào nhiều service khác nhau. Điều này dẫn đến các nhược điểm sau:
Tăng độ phức tạp cho client: Lớp client (lớp Controller, lớp Service) trở nên cồng kềnh, khó đọc, khó hiểu và khó bảo trì vì phải điều phối nhiều lệnh gọi đến các service khác nhau.
Tăng sự phụ thuộc (Coupling): Lớp client bị gắn chặt với các chi tiết triển khai của nhiều lớp service trong subsystem. Khi có sự thay đổi trong một trong các service này, lớp client có thể bị ảnh hưởng.
Giảm khả năng tái sử dụng: Logic xử lý nghiệp vụ phức tạp bị phân tán hoặc tập trung ở client, khó có thể tái sử dụng ở nơi khác.
Mẫu thiết kế Facade được áp dụng để giải quyết các vấn đề này. Bằng cách tạo ra một lớp duy nhất (lớp facade), hoạt động như một mặt tiền đơn giản hóa cho một tập hợp phức tạp các lớp con. Mặt tiền này giúp:
Đơn giản hóa giao diện: Cung cấp một giao diện gọn gàng, dễ sử dụng cho các nghiệp vụ phức tạp, che giấu đi sự phức tạp của các tương tác bên dưới.
Giảm sự phụ thuộc: Lớp client chỉ cần tương tác với lớp facade, loại bỏ sự phụ thuộc trực tiếp vào các lớp service riêng lẻ của subsystem.
Tăng tính đóng gói: Che giấu cấu trúc và hoạt động nội bộ của subsystem, giúp dễ dàng thay đổi subsystem mà không ảnh hưởng đến client.
Nâng cao khả năng bảo trì và đọc hiểu: Code của client trở nên rõ ràng hơn, và các nghiệp vụ phức tạp được tập trung tại một nơi duy nhất (lớp facade).
2. Sơ đồ lớp
2.1 Mô tả sơ đồ lớp
Sơ đồ lớp của Facade Pattern khi áp dụng vào hệ thống có dạng như sau:
CartController: 
Đại diện cho lớp client. Lớp này không trực tiếp gọi đến các service như UserService, ProductService, CartService. Thay vào đó, nó chỉ tương tác với lớp FacadeService để thực hiện các nghiệp vụ liên quan đến giỏ hàng (thêm/xóa sản phẩm). 
Trong CartController có một thuộc tính tham chiếu đến một đối tượng thuộc lớp FacadeService. Mũi tên từ CartController đến FacadeService là mũi tên đen một chiều. Điều này có nghĩa là CartController chỉ phụ thuộc vào FacadeService và sử dụng các phương thức có trong đó mà không cần biết về các lớp Service khác.
Thay vì tự định nghĩa các bước của một quy trình phức tạp thì CartController chỉ cần ủy quyền cho FacadeService thực hiện.
FacadeService: 
Đây là lớp facade. Nó chứa các tham chiếu đến các lớp service khác (CartService, ProductService, UserService) thông qua composition (thể hiện bằng các biến thành viên private cartService, productService, userService).
Lớp FacadeService cung cấp các phương thức đơn giản hóa như addToCart và removeFromCart. Các phương thức này sẽ định nghĩa, xây dựng và cung cấp các quy trình phức tạp cho lớp client sử dụng thông qua lời gọi phương thức.
Khi các phương thức này được gọi, lớp facade sẽ điều phối và ủy quyền các yêu cầu đến các service tương ứng trong subsystem để hoàn thành nghiệp vụ.
CartService, ProductService, UserService: 
Đây là các lớp service cốt lõi, tạo nên subsystem phức tạp. Mỗi lớp chịu trách nhiệm về một khía cạnh cụ thể của hệ thống.
CartService là lớp làm việc với giỏ hàng, cung cấp các chức năng quản lý giỏ hàng (thêm, xóa, sửa,... sản phẩm trong giỏ hàng). Lớp này đảm nhận vai trò chính của quy trình trong FacadeService là thao tác với giỏ hàng.
ProductService cung cấp các chức năng quản lý danh sách sản phẩm (thêm, xóa, sửa,... sản phẩm trong kho hàng). Trong FacadeService, lớp này đảm nhận vai trò kiểm tra, tăng, giảm số lượng của sản phẩm khi sản phẩm đó được thêm hoặc xóa khỏi giỏ hàng.
UserService cung cấp chức năng quản lý danh sách người dùng (thêm, xóa, cập nhật thông tin,... người dùng). Lớp này giúp thực hiện công việc xác thực danh tính người dùng, kiểm tra người dùng đã đăng nhập hay chưa, giỏ hàng của người dùng đã tồn tại hay chưa.
Các mũi tên từ FacadeService đến các lớp service này cho thấy FacadeService phụ thuộc và sử dụng các service này.
2.2 Nhận xét
Ưu điểm:
Sơ đồ lớp cho ta các nhìn tổng quan về Facade Pattern khi áp dụng vào hệ thống. Từ đó việc triển khai, áp dụng, mở rộng và bảo trì hệ thống sẽ trở nên đơn giản hơn.
Hệ thống có thể dễ dàng thay thế hoặc mở rộng các lớp service bên dưới (CartService, ProductService, UserService) mà không làm thay đổi lớp client (CartController). Ví dụ, nếu cần thay thế CartService hiện tại bằng một phiên bản mới tích hợp với cache để tối ưu hiệu suất, ta chỉ cần điều chỉnh bên trong FacadeService mà không cần sửa đổi bất kỳ logic nào trong CartController.
Điều này giúp tăng tính module hóa (modularity) và khả năng bảo trì (maintainability) của hệ thống, đồng thời giảm sự phụ thuộc chặt chẽ giữa các lớp, tuân thủ nguyên lý "Dependency Inversion" và "Open/Closed Principle" trong SOLID.
Nhược điểm:
Mặc dù facade giúp đơn giản hóa tương tác với hệ thống con và giảm sự phụ thuộc giữa các lớp, nhưng nếu FacadeService đảm nhận quá nhiều logic nghiệp vụ phức tạp hoặc điều phối quá nhiều lớp con sẽ biến nó trở thành một “God Object” (một lớp quá lớn và quá phức tạp), khó kiểm soát làm ảnh hướng đến khả năng mở rộng và bảo trì hệ thống.
Ngoài ra, việc gom nhiều luồng logic nghiệp vụ lại một chỗ có thể khiến lớp facade vi phạm nguyên lý Single Responsibility Principle.
Vì vậy để lớp facade phát triển thêm nhiều chức năng, ta có thể thêm vào các lớp “addition facade” (lớp mở rộng, định nghĩa các nghiệp vụ khác với nghiệp vụ trong lớp facade gốc).
