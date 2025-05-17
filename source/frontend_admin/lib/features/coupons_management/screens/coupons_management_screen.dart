import 'package:flutter/material.dart';
import 'package:frontend_admin/models/coupon_model.dart';
import 'package:frontend_admin/providers/coupon_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CouponsManagementScreen extends StatefulWidget {
  const CouponsManagementScreen({super.key});

  @override
  State<CouponsManagementScreen> createState() =>
      _CouponsManagementScreenState();
}

class _CouponsManagementScreenState extends State<CouponsManagementScreen> {
  final _codeController = TextEditingController();
  final _maxUsesController = TextEditingController();
  double _selectedDiscountValue = 10000.0;
  final List<double> _discountValues = [10000.0, 20000.0, 50000.0, 100000.0];

  @override
  void initState() {
    super.initState();
    // Load coupons when the widget is built and after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CouponProvider>(context, listen: false).loadCoupons();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _maxUsesController.dispose();
    super.dispose();
  }

  void _showAddCouponDialog(BuildContext context) {
    _codeController.clear();
    _maxUsesController.clear();
    _selectedDiscountValue = _discountValues.first;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
          return AlertDialog(
            title: const Text('Thêm mã giảm giá mới'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                        labelText: 'Mã giảm giá (5 ký tự chữ/số)',
                        counterText: ''),
                    maxLength: 5,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<double>(
                    value: _selectedDiscountValue,
                    decoration:
                        const InputDecoration(labelText: 'Giá trị giảm giá'),
                    items: _discountValues.map((double value) {
                      final formatter = NumberFormat('#,###', 'vi_VN');
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text('${formatter.format(value)} VND'),
                      );
                    }).toList(),
                    onChanged: (double? newValue) {
                      if (newValue != null) {
                        dialogSetState(() {
                          _selectedDiscountValue = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxUsesController,
                    decoration: const InputDecoration(
                        labelText:
                            'Số lượt dùng tối đa (1-10)'), // Label based on requirements
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Hủy'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              Consumer<CouponProvider>(
                  // Use Consumer to show loading state on button if needed
                  builder: (context, couponProvider, child) {
                // Optional: Disable button while adding
                final bool isAdding = couponProvider.isLoading &&
                    couponProvider.coupons.isEmpty; // Simple check

                return ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          // Disable if adding
                          final couponProvider = Provider.of<CouponProvider>(
                              dialogContext,
                              listen: false);

                          final String code = _codeController.text.trim();
                          final int? maxUses =
                              int.tryParse(_maxUsesController.text.trim());
                          final double value = _selectedDiscountValue;

                          if (maxUses == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Số lượt dùng tối đa không hợp lệ.')),
                            );
                            return;
                          }

                          try {
                            // Call the provider's method (which calls the repository)
                            await couponProvider.addCoupon(
                              code: code,
                              value: value,
                              maxUses: maxUses,
                            );
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Đã thêm mã giảm giá thành công.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Lỗi khi thêm mã giảm giá: ${e.toString()}')),
                            );
                            // Dialog stays open on error
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ))
                      : const Text('Thêm'), // Show loading on button
                );
              }),
            ],
          );
        });
      },
    );
  }

  void _showCouponDetailsDialog(BuildContext context, Coupon coupon) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chi tiết mã: ${coupon.code}'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID: ${coupon.id}',
                    style: const TextStyle(
                        fontSize: 14, color: Colors.grey)), // Show backend ID
                const SizedBox(height: 8),
                Text('Giá trị: ${coupon.formattedValue} VND',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Đã dùng: ${coupon.usedCount}/${coupon.maxUses} lượt',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                    'Trạng thái: ${coupon.valid ? "Còn hiệu lực" : "Hết hiệu lực"}',
                    style: TextStyle(
                        fontSize: 16,
                        color: coupon.valid
                            ? Colors.green
                            : Colors.red)), // Show valid status
                const SizedBox(height: 8),
                Text('Ngày tạo: ${coupon.formattedCreationTime}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                Text('Đơn hàng đã áp dụng (${coupon.ordersApplied.length}):',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (coupon.ordersApplied.isEmpty)
                  const Text('Chưa được áp dụng cho đơn hàng nào.')
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: coupon.ordersApplied
                        .map((orderId) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text('- $orderId'),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Confirmation dialog for deletion
  Future<bool> _confirmDelete(BuildContext context, Coupon coupon) async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Xác nhận xóa'),
              content: Text(
                  'Bạn có chắc chắn muốn xóa mã giảm giá "${coupon.code}" không?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // User cancels
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // User confirms
                  child: const Text('Xóa', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý mã giảm giá'),
      ),
      body: Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          if (couponProvider.isLoading &&
              couponProvider.coupons.isEmpty &&
              couponProvider.errorMessage == null) {
            // Show initial loading only if list is empty and no error yet
            return const Center(child: CircularProgressIndicator());
          }

          if (couponProvider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      couponProvider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => couponProvider.loadCoupons(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (couponProvider.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có mã giảm giá nào.'),
                  const SizedBox(height: 16),
                  // No need for retry button if list is just empty, unless it failed previously
                ],
              ),
            );
          }

          // If not loading and no error, show the list
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: couponProvider.coupons.length,
            itemBuilder: (context, index) {
              final coupon = couponProvider.coupons[index];
              // Use Dismissible for swipe-to-delete
              return Dismissible(
                key: Key(coupon.id), // Unique key for the item
                direction:
                    DismissDirection.endToStart, // Swipe from right to left
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  // Show confirmation dialog before actually dismissing
                  return await _confirmDelete(context, coupon);
                },
                onDismissed: (direction) {
                  // Call the provider to delete the coupon after confirmation
                  Provider.of<CouponProvider>(context, listen: false)
                      .deleteCoupon(coupon.id)
                      .catchError((error) {
                    // Handle errors specific to deletion if necessary
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Xóa mã "${coupon.code}" thất bại: ${error.toString()}')),
                    );
                    // Need to manually re-add the item if delete failed on backend
                    // This is complex, often better to rely on loadCoupons() after error or a more robust state management
                    // For simplicity here, we just show an error snackbar. The state might be temporarily inconsistent.
                  });
                  // Show a temporary message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đang xóa mã "${coupon.code}"...')),
                  );
                },
                child: Card(
                  elevation: 2.0,
                  margin:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                  child: ListTile(
                    leading: CircleAvatar(
                      // Show usage percentage or status
                      backgroundColor: coupon.valid
                          ? (coupon.usedCount >= coupon.maxUses
                              ? Colors.orangeAccent
                              : Colors.green)
                          : Colors.grey,
                      child: Text('${coupon.usedCount}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    title: Text(coupon.code,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Giá trị: ${coupon.formattedValue} VND'),
                        Text(
                            'Lượt dùng: ${coupon.usedCount}/${coupon.maxUses}'),
                        Text(coupon.valid ? "Còn hiệu lực" : "Hết hiệu lực",
                            style: TextStyle(
                                color: coupon.valid
                                    ? Colors.green.shade700
                                    : Colors.red.shade700)),
                      ],
                    ),
                    trailing: const Icon(Icons.visibility),
                    onTap: () => _showCouponDetailsDialog(context, coupon),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCouponDialog(context),
        tooltip: 'Thêm mã giảm giá',
        child: const Icon(Icons.add),
      ),
    );
  }
}
