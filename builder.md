Builder Pattern  
1. Lý do sử dụng  
Trong hệ thống xây dựng cấu hình PC, việc tạo ra các đối tượng PC với nhiều thành phần (CPU, RAM, GPU, Mainboard, PSU, Case, v.v.) là một quy trình phức tạp, đòi hỏi kiểm tra tính tương thích giữa các linh kiện và có thể có nhiều kiểu cấu hình khác nhau như: PC tiêu chuẩn, PC gaming, PC workstation, hoặc PC tiết kiệm chi phí. Nếu khởi tạo đối tượng PC trực tiếp bằng constructor hoặc setter, code sẽ trở nên rối rắm, khó kiểm soát, dễ xảy ra lỗi thiếu/thừa thành phần, và khó mở rộng khi cần thêm các loại cấu hình mới.

Builder Pattern giúp giải quyết vấn đề này bằng cách đóng gói quy trình xây dựng đối tượng phức tạp thành các bước nhỏ, có thể tùy biến, kiểm soát tốt hơn quá trình khởi tạo, đồng thời dễ dàng mở rộng cho các loại PC khác nhau mà không ảnh hưởng đến các phần còn lại của hệ thống.

2. Sơ đồ lớp  
Hình sơ đồ lớp Builder Pattern cho chức năng xây dựng PC

2.1 Mô tả sơ đồ lớp  
- PCBuilder: Interface định nghĩa các bước xây dựng từng thành phần của PC (setCpu, setRam, setMotherboard, ...), các phương thức kiểm tra tính tương thích, và các phương thức gợi ý cấu hình (suggestGamingComponents, suggestWorkstationComponents).
- StandardPCBuilder: Cài đặt mặc định của PCBuilder, chịu trách nhiệm xây dựng PC tiêu chuẩn, kiểm tra tính tương thích giữa các linh kiện, tính tổng giá, trạng thái build.
- GamingPCBuilder, WorkstationPCBuilder: Các builder cụ thể kế thừa từ PCBuilder, triển khai logic gợi ý linh kiện phù hợp cho từng mục đích sử dụng (gaming, workstation), có thể override các bước xây dựng hoặc gợi ý linh kiện đặc thù.
- PCDirector: Đóng vai trò điều phối, sử dụng các builder để xây dựng các loại PC khác nhau dựa trên yêu cầu đầu vào (custom, gaming, workstation, budget).
- PC: Đối tượng sản phẩm cuối cùng, chứa thông tin cấu hình, giá, trạng thái, ghi chú tương thích, v.v.

2.2 Nhận xét  
Ưu điểm:  
- Builder Pattern giúp tách biệt quá trình xây dựng đối tượng PC phức tạp thành các bước nhỏ, dễ kiểm soát, dễ mở rộng.
- Dễ dàng bổ sung các loại builder mới (ví dụ: OfficePCBuilder, ServerPCBuilder) mà không ảnh hưởng đến các builder hiện tại.
- Kiểm tra tính tương thích giữa các linh kiện được đóng gói tập trung, tránh lặp code và giảm lỗi.
- Hỗ trợ xây dựng các cấu hình PC khác nhau (custom, gaming, workstation, budget) một cách linh hoạt, có thể tùy biến từng thành phần hoặc sử dụng gợi ý tự động.
- Đảm bảo đối tượng PC luôn ở trạng thái hợp lệ trước khi sử dụng.

Nhược điểm:  
- Nếu số lượng thành phần hoặc loại builder quá nhiều, số lượng class có thể tăng lên đáng kể.
- Việc kiểm tra tương thích phức tạp có thể làm builder trở nên cồng kềnh nếu không tách nhỏ hợp lý.

3. Code  
3.1 Interface PCBuilder

Hình interface PCBuilder  
PCBuilder định nghĩa các phương thức:  
- reset(): Khởi tạo lại builder về trạng thái ban đầu.  
- setName, setUserId, setCpu, setMotherboard, setGpu, setRam, setStorage, setPowerSupply, setPcCase, setCooling: Thiết lập từng thành phần của PC.  
- validateCompatibility(): Kiểm tra tính tương thích giữa các linh kiện, cập nhật trạng thái build và ghi chú.  
- suggestGamingComponents(), suggestWorkstationComponents(): Gợi ý cấu hình phù hợp cho từng mục đích sử dụng.  
- build(): Trả về đối tượng PC hoàn chỉnh.

3.2 Lớp StandardPCBuilder

Hình lớp StandardPCBuilder  
- Cài đặt các bước xây dựng từng thành phần PC.
- validateCompatibility() kiểm tra socket CPU/Mainboard, RAM/Mainboard, form factor Case/Mainboard, tính toán tổng giá, cập nhật trạng thái build (compatible, incompatible, incomplete).
- Đảm bảo PC luôn hợp lệ trước khi build.

3.3 Lớp GamingPCBuilder, WorkstationPCBuilder

Hình lớp GamingPCBuilder, WorkstationPCBuilder  
- Kế thừa từ PCBuilder, sử dụng StandardPCBuilder để thực hiện các bước cơ bản.
- suggestGamingComponents(): Gợi ý các linh kiện tối ưu cho gaming (CPU/GPU mạnh, RAM lớn, SSD, PSU công suất cao).
- suggestWorkstationComponents(): Gợi ý linh kiện tối ưu cho workstation (CPU nhiều nhân, RAM lớn, SSD dung lượng cao, GPU chuyên dụng).
- Có thể override các bước xây dựng nếu cần logic đặc thù.

3.4 Lớp PCDirector

Hình lớp PCDirector  
- Nhận yêu cầu từ service/controller, lựa chọn builder phù hợp (standard, gaming, workstation).
- buildCustomPC(): Xây dựng PC theo linh kiện người dùng chọn.
- buildGamingPC(), buildWorkstationPC(): Xây dựng PC theo gợi ý builder, cho phép override từng linh kiện nếu người dùng tùy chỉnh.
- buildBudgetPC(): Xây dựng PC tiết kiệm chi phí (logic chọn linh kiện giá rẻ nhất).

4. Kết luận  
Việc áp dụng Builder Pattern cho module xây dựng cấu hình PC giúp hệ thống trở nên linh hoạt, dễ mở rộng, kiểm soát tốt quá trình khởi tạo đối tượng phức tạp, đảm bảo tính hợp lệ và tương thích của sản phẩm cuối cùng. Mỗi loại builder đóng gói logic xây dựng riêng biệt, dễ dàng bổ sung hoặc thay đổi mà không ảnh hưởng đến các phần khác. Nhờ đó, hệ thống đáp ứng tốt các yêu cầu mở rộng trong tương lai, giảm lỗi phát sinh do khởi tạo đối tượng thủ công, và nâng cao trải nghiệm người dùng khi xây dựng cấu hình PC.