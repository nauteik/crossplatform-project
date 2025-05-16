import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/address_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/repositories/address_provider.dart';
import 'address_form_screen.dart';

class AddressScreen extends StatefulWidget {
  final bool isSelecting;
  final Function(AddressModel)? onAddressSelected;

  const AddressScreen({
    Key? key,
    this.isSelecting = false,
    this.onAddressSelected,
  }) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await addressProvider.fetchUserAddresses(
        authProvider.userId!,
        authProvider.token ?? '',
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isSelecting ? 'Chọn địa chỉ giao hàng' : 'Địa chỉ của tôi'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AddressProvider>(
              builder: (context, addressProvider, child) {
                if (addressProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (addressProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đã xảy ra lỗi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(addressProvider.errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAddresses,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (addressProvider.addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa có địa chỉ nào',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Thêm địa chỉ để dễ dàng thanh toán',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddressForm(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm địa chỉ mới'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: addressProvider.addresses.length,
                      itemBuilder: (context, index) {
                        final address = addressProvider.addresses[index];
                        return _buildAddressCard(context, address);
                      },
                    ),
                    if (addressProvider.addresses.length < 2)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: FloatingActionButton(
                          onPressed: () => _navigateToAddressForm(context),
                          child: const Icon(Icons.add),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: address.isDefault ? Colors.blue : Colors.transparent,
          width: address.isDefault ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: widget.isSelecting
            ? () {
                if (widget.onAddressSelected != null) {
                  widget.onAddressSelected!(address);
                }
                Navigator.of(context).pop();
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      address.fullName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (address.isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mặc định',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(address.phoneNumber),
              const SizedBox(height: 4),
              Text(
                address.fullAddress,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              if (!widget.isSelecting)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!address.isDefault)
                      TextButton.icon(
                        onPressed: () async {
                          if (authProvider.userId != null) {
                            await addressProvider.setDefaultAddress(
                              authProvider.userId!,
                              address.id!,
                              authProvider.token ?? '',
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Đặt mặc định'),
                      ),
                    TextButton.icon(
                      onPressed: () => _navigateToAddressForm(
                        context,
                        address: address,
                      ),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Sửa'),
                    ),
                    TextButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, address),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Xóa',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddressForm(BuildContext context, {AddressModel? address}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(address: address),
      ),
    ).then((_) => _loadAddresses());
  }

  void _showDeleteConfirmation(BuildContext context, AddressModel address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);
              final addressProvider =
                  Provider.of<AddressProvider>(context, listen: false);

              if (authProvider.userId != null && address.id != null) {
                await addressProvider.deleteAddress(
                  authProvider.userId!,
                  address.id!,
                  authProvider.token ?? '',
                );
              }
            },
            child: const Text(
              'Xóa',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
} 