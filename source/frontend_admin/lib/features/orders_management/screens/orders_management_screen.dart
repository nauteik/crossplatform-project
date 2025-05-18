import 'package:flutter/material.dart';
import 'package:frontend_admin/features/orders_management/controllers/order_controller.dart';
import 'package:frontend_admin/features/orders_management/models/order_model.dart';
import 'package:frontend_admin/features/orders_management/widgets/order_detail_dialog.dart';
import 'package:frontend_admin/features/orders_management/widgets/order_status_badge.dart';
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
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  // Thêm biến cho chức năng sắp xếp
  String _sortBy = 'createdAt';
  bool _sortAscending = false; // false = giảm dần (mới nhất trước), true = tăng dần
  
  // Phân trang
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalItems = 0;
  int _pageSize = 20;
  
  // Lọc theo thời gian
  DateFilter _dateFilter = DateFilter.all;
  DateTime? _startDate;
  DateTime? _endDate;
  
  final List<String> _statusFilters = [
    'ALL', 'PENDING', 'PAID', 'SHIPPING', 'DELIVERED', 'CANCELLED', 'FAILED'
  ];
  
  // Danh sách các trường có thể sắp xếp
  final List<Map<String, dynamic>> _sortOptions = [
    {'value': 'createdAt', 'label': 'Ngày đặt hàng'},
    {'value': 'total', 'label': 'Tổng tiền'},
    {'value': 'status', 'label': 'Trạng thái'},
    {'value': 'userName', 'label': 'Tên khách hàng'},
  ];

  // Màu sắc cho trạng thái
  final Map<String, Color> _statusColors = {
    'PENDING': Colors.orange,
    'PAID': Colors.blue,
    'SHIPPING': Colors.purple,
    'DELIVERED': Colors.green,
    'CANCELLED': Colors.red,
    'FAILED': Colors.grey,
  };
  
  // Các tùy chọn bộ lọc thời gian
  final List<Map<String, dynamic>> _dateFilterOptions = [
    {'value': DateFilter.all, 'label': 'Tất cả thời gian'},
    {'value': DateFilter.today, 'label': 'Hôm nay'},
    {'value': DateFilter.yesterday, 'label': 'Hôm qua'},
    {'value': DateFilter.thisWeek, 'label': 'Tuần này'},
    {'value': DateFilter.thisMonth, 'label': 'Tháng này'},
    {'value': DateFilter.lastMonth, 'label': 'Tháng trước'},
    {'value': DateFilter.custom, 'label': 'Tùy chỉnh...'},
  ];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _orderController.getAllOrders(
        page: _currentPage,
        size: _pageSize,
        status: _filterStatus == 'ALL' ? null : _filterStatus,
        dateFilter: _dateFilter,
        startDate: _startDate,
        endDate: _endDate,
      );
      
      setState(() {
        _orders = result['orders'] as List<Order>;
        _currentPage = result['currentPage'] as int;
        _totalPages = result['totalPages'] as int;
        _totalItems = result['totalItems'] as int;
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
    List<Order> filteredOrders = _orders;
    
    // Lọc theo từ khóa tìm kiếm
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) => 
        order.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        order.userName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Sắp xếp theo trường được chọn
    _sortOrders(filteredOrders);
    
    return filteredOrders;
  }
  
  // Sắp xếp đơn hàng theo trường và thứ tự đã chọn
  void _sortOrders(List<Order> orders) {
    switch (_sortBy) {
      case 'createdAt':
        if (_sortAscending) {
          orders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        } else {
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
        break;
      case 'total':
        if (_sortAscending) {
          orders.sort((a, b) => a.total.compareTo(b.total));
        } else {
          orders.sort((a, b) => b.total.compareTo(a.total));
        }
        break;
      case 'status':
        if (_sortAscending) {
          orders.sort((a, b) => a.status.compareTo(b.status));
        } else {
          orders.sort((a, b) => b.status.compareTo(a.status));
        }
        break;
      case 'userName':
        if (_sortAscending) {
          orders.sort((a, b) => a.userName.compareTo(b.userName));
        } else {
          orders.sort((a, b) => b.userName.compareTo(a.userName));
        }
        break;
      default:
        // Mặc định sắp xếp theo ngày tạo
        orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }
  
  // Chuyển đến trang khác
  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    
    setState(() {
      _currentPage = page;
    });
    
    _loadOrders();
  }
  
  // Thay đổi trạng thái lọc
  void _changeStatusFilter(String status) {
    setState(() {
      _filterStatus = status;
      _currentPage = 0; // Reset về trang đầu tiên
    });
    
    _loadOrders();
  }
  
  // Thay đổi bộ lọc thời gian
  void _changeDateFilter(DateFilter filter) {
    if (filter == DateFilter.custom) {
      _showDateRangePicker();
    } else {
      setState(() {
        _dateFilter = filter;
        _currentPage = 0; // Reset về trang đầu tiên
      });
      
      _loadOrders();
    }
  }
  
  // Hiển thị date range picker dạng dialog
  Future<void> _showDateRangePicker() async {
    final initialDateRange = DateTimeRange(
      start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: _endDate ?? DateTime.now(),
    );
    
    final pickedDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo.shade700,
              onPrimary: Colors.white,
              surface: Colors.indigo.shade100,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDateRange != null) {
      setState(() {
        _dateFilter = DateFilter.custom;
        _startDate = pickedDateRange.start;
        _endDate = pickedDateRange.end;
        _currentPage = 0; // Reset về trang đầu tiên
      });
      
      _loadOrders();
    }
  }

  // Hiển thị dialog lựa chọn bộ lọc thời gian
  void _showDateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.filter_alt, color: Colors.indigo[700]),
              const SizedBox(width: 8),
              const Text('Lọc theo thời gian', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _dateFilterOptions.map((option) {
                final DateFilter filter = option['value'] as DateFilter;
                return ListTile(
                  leading: Icon(
                    _getDateFilterIcon(filter),
                    color: _dateFilter == filter ? Colors.indigo : Colors.grey,
                  ),
                  title: Text(option['label'] as String),
                  subtitle: _getDateFilterSubtitle(filter),
                  selected: _dateFilter == filter,
                  selectedTileColor: Colors.indigo.shade50,
                  onTap: () {
                    Navigator.of(context).pop();
                    if (filter == DateFilter.custom) {
                      _showDateRangePicker();
                    } else {
                      _changeDateFilter(filter);
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  dense: false,
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      },
    );
  }

  // Lấy subtitle cho từng loại date filter
  Widget? _getDateFilterSubtitle(DateFilter filter) {
    final now = DateTime.now();
    
    switch (filter) {
      case DateFilter.today:
        return Text('${DateFormat('dd/MM/yyyy').format(now)}');
      case DateFilter.yesterday:
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        return Text('${DateFormat('dd/MM/yyyy').format(yesterday)}');
      case DateFilter.thisWeek:
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return Text('${DateFormat('dd/MM').format(firstDayOfWeek)} - ${DateFormat('dd/MM').format(now)}');
      case DateFilter.thisMonth:
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        return Text('${DateFormat('dd/MM').format(firstDayOfMonth)} - ${DateFormat('dd/MM').format(now)}');
      case DateFilter.lastMonth:
        final firstDayOfLastMonth = DateTime(now.year, now.month - 1, 1);
        final lastDayOfLastMonth = DateTime(now.year, now.month, 0);
        return Text('${DateFormat('dd/MM').format(firstDayOfLastMonth)} - ${DateFormat('dd/MM').format(lastDayOfLastMonth)}');
      case DateFilter.custom:
        if (_startDate != null && _endDate != null) {
          return Text('${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}');
        }
        return const Text('Chọn khoảng thời gian tùy chỉnh');
      default:
        return null;
    }
  }

  Future<void> _processOrder(Order order) async {
    try {
      setState(() => _isLoading = true);
      final success = await _orderController.processOrder(order.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hàng ${order.id} đã được xử lý thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xử lý đơn hàng trong trạng thái ${order.status}'),
            backgroundColor: Colors.orange,
          ),
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
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      setState(() => _isLoading = true);
      final success = await _orderController.cancelOrder(order.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đơn hàng ${order.id} đã được hủy thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể hủy đơn hàng trong trạng thái ${order.status}'),
            backgroundColor: Colors.orange,
          ),
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
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
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
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.indigo[800],
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Text(
                  '${filteredOrders.length} đơn hàng',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            _buildFilterBar(),
            _buildSortBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Đang tải dữ liệu đơn hàng...',
                            style: TextStyle(
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? _buildErrorWidget()
                      : _buildOrdersContent(filteredOrders),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo mã đơn hoặc tên khách hàng',
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.indigo),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[50],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _filterStatus,
                    hint: const Text('Trạng thái'),
                    icon: const Icon(Icons.filter_list, color: Colors.indigo),
                    style: const TextStyle(color: Colors.black87, fontSize: 15),
                    onChanged: (value) {
                      if (value != null) {
                        _changeStatusFilter(value);
                      }
                    },
                    items: _statusFilters.map((status) => 
                      DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            if (status != 'ALL')
                              Container(
                                width: 12,
                                height: 12,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _statusColors[status] ?? Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(status == 'ALL' ? 'Tất cả trạng thái' : Order.getStatusDescription(status)),
                          ],
                        ),
                      )
                    ).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Nút lọc thời gian thay thế dropdown
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showDateFilterDialog,
                  icon: Icon(_getDateFilterIcon(_dateFilter), size: 20),
                  label: Row(
                    children: [
                      Text(
                        _dateFilterOptions.firstWhere((option) => option['value'] == _dateFilter)['label'] as String,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (_dateFilter == DateFilter.custom && _startDate != null && _endDate != null) ...[
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '(${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)})',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade700,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  IconData _getDateFilterIcon(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return Icons.today;
      case DateFilter.yesterday:
        return Icons.history;
      case DateFilter.thisWeek:
        return Icons.view_week;
      case DateFilter.thisMonth:
        return Icons.calendar_month;
      case DateFilter.lastMonth:
        return Icons.calendar_view_month;
      case DateFilter.custom:
        return Icons.date_range;
      case DateFilter.all:
      default:
        return Icons.all_inclusive;
    }
  }
  
  // Widget mới để hiển thị các tùy chọn sắp xếp
  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.sort, size: 18, color: Colors.indigo[700]),
          const SizedBox(width: 8),
          Text(
            'Sắp xếp theo:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 16),
          
          // Dropdown cho các tùy chọn sắp xếp
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _sortBy,
                isDense: true,
                style: TextStyle(
                  color: Colors.indigo[800],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                icon: Icon(Icons.arrow_drop_down, color: Colors.indigo[700]),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _sortBy = value;
                    });
                  }
                },
                items: _sortOptions.map((option) {
                  return DropdownMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Toggle button để chuyển đổi thứ tự sắp xếp
          InkWell(
            onTap: () {
              setState(() {
                _sortAscending = !_sortAscending;
              });
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[300]!),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                    color: Colors.indigo[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sortAscending ? 'Tăng dần' : 'Giảm dần',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.indigo[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Hiển thị thông tin về trường sắp xếp hiện tại
          Text(
            'Đang sắp xếp theo ${_sortOptions.firstWhere((option) => option['value'] == _sortBy)['label']} (${_sortAscending ? 'A→Z' : 'Z→A'})',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String formatCurrency(
    double amount, {
    String symbol = '₫',
    int decimalDigits = 0,
  }) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(amount);
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 70,
            ),
            const SizedBox(height: 20),
            Text(
              'Lỗi tải đơn hàng',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                // Show instructions dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Vấn đề kết nối'),
                    content: const Text(
                      'Đảm bảo máy chủ backend của bạn đang chạy trên http://localhost:8080.\n\n'
                      'Kiểm tra xem ứng dụng Spring Boot đã được khởi chạy và cơ sở dữ liệu đã được kết nối chính xác.'
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
              icon: const Icon(Icons.help_outline),
              label: const Text('Xem hướng dẫn kết nối'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.indigo[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersContent(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Không có đơn hàng nào',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _filterStatus != 'ALL' || _dateFilter != DateFilter.all
                  ? 'Thử chọn bộ lọc khác hoặc làm mới dữ liệu' 
                  : 'Chưa có đơn hàng nào trong hệ thống',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Làm mới dữ liệu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh sách đơn hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.indigo[700]),
                    const SizedBox(width: 4),
                    Text(
                      '${orders.length} đơn hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Card(
              elevation: 2,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: _buildOrdersTable(orders),
            ),
          ),
        ),
        // Pagination
        _buildPagination(),
      ],
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    return SizedBox(
      width: double.infinity,
      height: MediaQuery.of(context).size.height - 180,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.grey[200],
          dataTableTheme: DataTableThemeData(
            headingTextStyle: TextStyle(
              color: Colors.indigo[800],
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            dataTextStyle: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
            ),
            headingRowHeight: 56,
            dataRowHeight: 70,
            dividerThickness: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: DataTable(
            showCheckboxColumn: false,
            columnSpacing: 16,
            horizontalMargin: 16,
            headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(label: Text('Mã Đơn hàng')),
              DataColumn(label: Text('Ngày Đặt hàng')),
              DataColumn(label: Text('Khách hàng')),
              DataColumn(label: Text('Tổng cộng')),
              DataColumn(label: Text('Giảm giá')),
              DataColumn(label: Text('Trạng thái')),
              DataColumn(label: Text('Hành động')),
            ],
            rows: orders.map((order) {
              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.indigo.withOpacity(0.08);
                    }
                    if (states.contains(MaterialState.hovered)) {
                      return Colors.grey.withOpacity(0.05);
                    }
                    return null;
                  },
                ),
                cells: [
                  DataCell(
                    Tooltip(
                      message: order.id,
                      child: Text(
                        order.id.length > 8 ? order.id.substring(0, 8) + '...' : order.id,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    onTap: () => _viewOrderDetails(order),
                  ),
                  DataCell(
                    Text(DateFormat('dd/MM/yyyy').format(order.createdAt)),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.indigo[100],
                          child: Text(
                            order.userName.isNotEmpty ? order.userName[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: Colors.indigo[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                order.username,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                order.userEmail.isNotEmpty 
                                    ? order.userEmail
                                    : '${order.userName.toLowerCase().replaceAll(' ', '.')}@example.com',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  DataCell(
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatCurrency(order.total),
                          style: TextStyle(
                            fontWeight: (order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0)
                                ? FontWeight.normal 
                                : FontWeight.bold,
                            decoration: (order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0)
                                ? TextDecoration.lineThrough 
                                : TextDecoration.none,
                            decorationColor: Colors.grey[600],
                            fontSize: (order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0) ? 13 : 15,
                          ),
                        ),
                        if (order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0)
                          Text(
                            formatCurrency(order.finalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                      ],
                    ),
                  ),
                  DataCell(
                    order.couponDiscount > 0 || order.loyaltyPointsDiscount > 0
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hiển thị tất cả thông tin giảm giá trên cùng một hàng
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (order.couponDiscount > 0) ...[
                                    Icon(Icons.discount_outlined, 
                                      size: 14, 
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${order.couponCode ?? ''}: -${formatCurrency(order.couponDiscount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                  if (order.couponDiscount > 0 && order.loyaltyPointsUsed > 0)
                                    const SizedBox(width: 8),
                                  if (order.loyaltyPointsUsed > 0) ...[
                                    Icon(Icons.stars, 
                                      size: 14, 
                                      color: Colors.amber[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${order.loyaltyPointsUsed} điểm: -${formatCurrency(order.loyaltyPointsDiscount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              // Hiển thị tổng giảm giá
                              const SizedBox(height: 4),
                              Text(
                                'Tổng giảm: -${formatCurrency(order.couponDiscount + order.loyaltyPointsDiscount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          )
                        : const Text('Không áp dụng'),
                  ),
                  DataCell(OrderStatusBadge(status: order.status)),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () => _viewOrderDetails(order),
                          tooltip: 'Xem chi tiết',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward, color: Colors.green),
                          onPressed: () => _processOrder(order),
                          tooltip: 'Xử lý đơn hàng',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _cancelOrder(order),
                          tooltip: 'Hủy đơn hàng',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildPagination() {
    if (_totalPages <= 1) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous page button
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 
                ? () => _goToPage(_currentPage - 1) 
                : null,
            color: Colors.indigo,
            disabledColor: Colors.grey.shade400,
          ),
          
          // Page information
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang ${_currentPage + 1} / $_totalPages (${_totalItems} đơn hàng)',
              style: TextStyle(
                color: Colors.indigo.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // Next page button
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _totalPages - 1 
                ? () => _goToPage(_currentPage + 1) 
                : null,
            color: Colors.indigo,
            disabledColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}