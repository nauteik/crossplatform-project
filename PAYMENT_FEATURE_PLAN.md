# Payment Feature Implementation Plan (Strategy Pattern)

This plan outlines the steps to implement a payment feature using the Strategy design pattern, initially supporting simulated Credit Card and Cash on Delivery (COD) payments.

**Phase 1: Backend Implementation (Java/Spring Boot)**

1.  **Define Order Entity (`Order.java`, `OrderItem.java`):**
    *   Create a new package `com.example.ecommerceproject.model`.
    *   Define `Order.java` with fields:
        *   `@Id String id`
        *   `String userId`
        *   `List<OrderItem> items`
        *   `double totalAmount`
        *   `OrderStatus status` (Create an enum `OrderStatus`: `PENDING`, `PAID`, `FAILED`, `SHIPPED`, `DELIVERED`, `CANCELLED`)
        *   `String paymentMethod` (e.g., "CREDIT_CARD", "COD")
        *   `String shippingAddress`
        *   `LocalDateTime createdAt`
        *   `LocalDateTime updatedAt`
    *   Define `OrderItem.java` (can be a nested class or separate) with fields:
        *   `String productId`
        *   `String productName`
        *   `int quantity`
        *   `double price` (price per item at the time of order)
        *   `String imageUrl`

2.  **Create Order Repository (`OrderRepository.java`):**
    *   Create a new package `com.example.ecommerceproject.repository`.
    *   Define `OrderRepository` interface extending `MongoRepository<Order, String>`.
    *   Add custom query methods if needed (e.g., `findByUserId`).

3.  **Define Payment Strategy (`PaymentStrategy.java`):**
    *   Create a new package `com.example.ecommerceproject.strategy` (or within `service.payment`).
    *   Define `PaymentStrategy` interface:
        ```java
        public interface PaymentStrategy {
            /**
             * Processes the payment for the given order.
             * @param order The order to process payment for.
             * @param paymentDetails Additional details required for payment (e.g., dummy card info).
             * @return true if payment is successful (simulated), false otherwise.
             */
            boolean pay(Order order, Map<String, Object> paymentDetails);
        }
        ```

4.  **Implement Concrete Strategies (`CreditCardPaymentStrategy.java`, `CodPaymentStrategy.java`):**
    *   In the `strategy` package:
    *   `CreditCardPaymentStrategy`: Implements `PaymentStrategy`. The `pay` method will simulate success (e.g., log details, always return `true`). Mark with `@Component`.
    *   `CodPaymentStrategy`: Implements `PaymentStrategy`. The `pay` method will simulate success (e.g., log, always return `true`). Mark with `@Component`.

5.  **Create Payment Service (`PaymentService.java`):**
    *   Create a new package `com.example.ecommerceproject.service.payment` (or keep in `service`).
    *   Define `PaymentService`:
        *   Inject the concrete strategies using `@Autowired`. Store them in a `Map<String, PaymentStrategy>`.
        *   Method `boolean processPayment(Order order, Map<String, Object> paymentDetails)`:
            *   Retrieves `paymentMethod` from the `order`.
            *   Selects the appropriate strategy from the map based on `paymentMethod`.
            *   Calls the `pay` method of the selected strategy.
            *   Returns the result.

6.  **Create Order Service (`OrderService.java`):**
    *   In the `com.example.ecommerceproject.service` package:
    *   Define `OrderService`:
        *   Inject `OrderRepository`, `CartService`, `PaymentService`, `ProductService`.
        *   Method `Order createOrder(String userId, String shippingAddress, String paymentMethod)`:
            *   Fetch user's cart using `CartService`.
            *   Check product availability/quantity using `ProductService`. Throw exception if not enough stock.
            *   Create `Order` object, map `CartItem`s to `OrderItem`s, set total, status to `PENDING`, etc.
            *   Decrease product quantity via `ProductService`.
            *   Save order using `OrderRepository`.
            *   Return the saved (pending) order.
        *   Method `Order processOrderPayment(String orderId, Map<String, Object> paymentDetails)`:
            *   Find order by `orderId`. Throw exception if not found or not `PENDING`.
            *   Call `PaymentService.processPayment(order, paymentDetails)`.
            *   If `true`:
                *   Update order status to `PAID`.
                *   Call `CartService.clearCart(order.getUserId())`.
            *   If `false`:
                *   Update order status to `FAILED`.
                *   *(Consider adding logic to revert product quantity if needed)*
            *   Save the updated order.
            *   Return the updated order.
        *   Helper method `Order updateOrderStatus(String orderId, OrderStatus newStatus)`.
        *   Methods `getOrderById(String orderId)`, `getOrdersByUserId(String userId)`.

7.  **Create Order Controller (`OrderController.java`):**
    *   In the `com.example.ecommerceproject.controller` package:
    *   Define `OrderController` with `@RestController`, `@RequestMapping("/api/orders")`, `@CrossOrigin("*")`.
    *   Inject `OrderService`.
    *   Endpoint `POST /create`: Takes request body with `userId`, `shippingAddress`, `paymentMethod`. Calls `OrderService.createOrder`. Returns `ResponseEntity<ApiResponse<Order>>`.
    *   Endpoint `POST /{orderId}/pay`: Takes `@PathVariable String orderId`, `@RequestBody Map<String, Object> paymentDetails`. Calls `OrderService.processOrderPayment`. Returns `ResponseEntity<ApiResponse<Order>>`.
    *   Endpoint `GET /user/{userId}`: Calls `OrderService.getOrdersByUserId`. Returns `ResponseEntity<ApiResponse<List<Order>>>`.
    *   Endpoint `GET /{orderId}`: Calls `OrderService.getOrderById`. Returns `ResponseEntity<ApiResponse<Order>>`.

8.  **Update Existing Services:**
    *   Ensure `CartService` has a reliable `clearCart(String userId)` method.
    *   Ensure `ProductService` has a reliable `decreaseQuantity(String productId, int quantity)` method.

**Phase 2: Frontend Implementation (Flutter - User App)**

1.  **Models (`order_model.dart`, `order_item_model.dart`):**
    *   Create models in `lib/data/model` mirroring the backend `Order` and `OrderItem` entities, including the `OrderStatus` enum. Add `fromJson` factories.

2.  **Repository/Service (`order_repository.dart`):**
    *   Create `OrderRepository` in `lib/data/repository` (or similar).
    *   Implement methods to interact with the new backend `/api/orders` endpoints:
        *   `Future<ApiResponse<OrderModel>> createOrder(...)`
        *   `Future<ApiResponse<OrderModel>> processPayment(String orderId, Map<String, dynamic> paymentDetails)`
        *   `Future<ApiResponse<List<OrderModel>>> getUserOrders(String userId)`
        *   `Future<ApiResponse<OrderModel>> getOrderDetails(String orderId)`

3.  **State Management (Provider/Bloc/GetX):**
    *   Create providers/blocs/controllers for managing checkout state and order history.

4.  **UI Implementation:**
    *   **Checkout Screen:**
        *   Display cart summary.
        *   Input for Shipping Address.
        *   Selection for Payment Method (Radio buttons: Credit Card, COD).
        *   Conditional display of dummy Credit Card input fields.
        *   "Place Order" button:
            *   Calls `createOrder` repository method.
            *   On success, gets the `orderId` and calls `processPayment`.
            *   Handles API responses, showing loading indicators, success messages (clearing navigation stack or navigating to order confirmation), or error messages.
    *   **Order History Screen:**
        *   Fetch orders using `getUserOrders`.
        *   Display a list of orders (summary: ID, date, total, status).
        *   Allow tapping to view order details.
    *   **Order Details Screen:**
        *   Fetch details using `getOrderDetails`.
        *   Display full order information (items, address, status, etc.).

**Phase 3: Testing & Refinement**

1.  **Backend:** Write unit/integration tests for services and strategies. Test API endpoints using tools like Postman.
2.  **Frontend:** Test the UI flow thoroughly, including error handling.
3.  **Refine:** Address any bugs or usability issues.

**Diagrams:**

*   **Strategy Pattern:**
    ```mermaid
    classDiagram
        class PaymentService {
            -Map~String, PaymentStrategy~ strategies
            +processPayment(Order order, Map~String, Object~ paymentDetails) boolean
        }
        class PaymentStrategy {
            <<interface>>
            +pay(Order order, Map~String, Object~ paymentDetails) boolean
        }
        class CreditCardPaymentStrategy {
            +pay(Order order, Map~String, Object~ paymentDetails) boolean
        }
        class CodPaymentStrategy {
            +pay(Order order, Map~String, Object~ paymentDetails) boolean
        }
        PaymentService --> PaymentStrategy : uses
        PaymentStrategy <|.. CreditCardPaymentStrategy : implements
        PaymentStrategy <|.. CodPaymentStrategy : implements
    ```

*   **Checkout Flow:**
    ```mermaid
    sequenceDiagram
        participant UserApp
        participant OrderController
        participant OrderService
        participant PaymentService
        participant CartService
        participant OrderRepository
        participant ProductService

        UserApp->>+OrderController: POST /api/orders/create (userId, address, paymentMethod)
        OrderController->>+OrderService: createOrder(userId, address, paymentMethod)
        OrderService->>+CartService: getCartByUserId(userId)
        CartService-->>-OrderService: Cart data
        OrderService->>+ProductService: Check/Decrease Quantity (Loop)
        ProductService-->>-OrderService: OK/Fail
        OrderService->>+OrderRepository: save(new Order(status=PENDING))
        OrderRepository-->>-OrderService: Saved Order (with ID)
        OrderService-->>-OrderController: Pending Order
        OrderController-->>-UserApp: Pending Order details (orderId)

        UserApp->>+OrderController: POST /api/orders/{orderId}/pay (paymentDetails)
        OrderController->>+OrderService: processOrderPayment(orderId, paymentDetails)
        OrderService->>+OrderRepository: findById(orderId)
        OrderRepository-->>-OrderService: Order (PENDING)
        OrderService->>+PaymentService: processPayment(order, paymentDetails)
        PaymentService->>PaymentStrategy: pay(order, paymentDetails) # Selects strategy
        PaymentStrategy-->>PaymentService: boolean paymentSuccess
        PaymentService-->>-OrderService: paymentSuccess
        alt Payment Successful
            OrderService->>OrderService: updateOrderStatus(orderId, PAID)
            OrderService->>OrderRepository: save(order with status=PAID)
            OrderRepository-->>OrderService: Updated Order
            OrderService->>CartService: clearCart(userId)
            CartService-->>OrderService: void
        else Payment Failed
            OrderService->>OrderService: updateOrderStatus(orderId, FAILED)
            OrderService->>OrderRepository: save(order with status=FAILED)
            OrderRepository-->>OrderService: Updated Order
        end
        OrderService-->>-OrderController: Updated Order
        OrderController-->>-UserApp: Final Order Status