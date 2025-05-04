import 'package:flutter/material.dart';
import 'package:admin_interface/features/orders_management/widgets/order_status_badge.dart';
import 'package:admin_interface/features/orders_management/widgets/order_detail_dialog.dart';
import 'package:admin_interface/features/orders_management/models/order_model.dart';
import 'package:admin_interface/features/orders_management/controllers/order_controller.dart';
import 'package:intl/intl.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final OrderController _orderController = OrderController();
  List<Order> _orders = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _filterStatus = 'ALL';
  
  final List<String> _statusFilters = [
    'ALL', 'PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'FAILED'
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orders = await _orderController.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  List<Order> _getFilteredOrders() {
    if (_filterStatus == 'ALL') {
      return _orders;
    }
    return _orders.where((order) => order.status == _filterStatus).toList();
  }

  Future<void> _processOrder(Order order) async {
    try {
      setState(() => _isLoading = true);
      final success = await _orderController.processOrder(order.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${order.id} processed successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot process order in ${order.status} state')),
        );
      }
      
      // Reload orders to get updated status
      await _loadOrders();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      setState(() => _isLoading = true);
      final success = await _orderController.cancelOrder(order.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order ${order.id} cancelled successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cannot cancel order in ${order.status} state')),
        );
      }
      
      // Reload orders to get updated status
      await _loadOrders();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _viewOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Filter by Status:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _filterStatus,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _filterStatus = value;
                      });
                    }
                  },
                  items: _statusFilters.map((status) => 
                    DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    )
                  ).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _buildOrdersTable(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Orders',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Show instructions dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Connection Issues'),
                  content: const Text(
                    'Make sure your backend server is running on http://localhost:8080.\n\n'
                    'Check that the Spring Boot application is started and the database is connected properly.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('View Connection Help'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Order ID')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Total')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: orders.map((order) {
            return DataRow(
              cells: [
                DataCell(
                  Text(order.id.length > 8 ? order.id.substring(0, 8) + '...' : order.id), // Truncated ID for readability
                  onTap: () => _viewOrderDetails(order),
                ),
                DataCell(
                  Text(DateFormat('MM/dd/yyyy').format(order.createdAt)),
                ),
                DataCell(Text(order.userName)),
                DataCell(Text('\$${order.total.toStringAsFixed(2)}')),
                DataCell(OrderStatusBadge(status: order.status)),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _viewOrderDetails(order),
                        tooltip: 'View Details',
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _processOrder(order),
                        tooltip: 'Process Order',
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel),
                        onPressed: () => _cancelOrder(order),
                        tooltip: 'Cancel Order',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}