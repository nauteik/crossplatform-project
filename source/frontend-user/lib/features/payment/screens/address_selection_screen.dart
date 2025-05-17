import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/address_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/profile/data/repositories/address_provider.dart';
import '../../../features/profile/presentation/screens/address_form_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  final String userId;

  const AddressSelectionScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (authProvider.token != null) {
      await addressProvider.fetchUserAddresses(
        widget.userId,
        authProvider.token!,
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
        title: const Text('Chọn địa chỉ giao hàng'),
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
                          'Hãy thêm địa chỉ mới',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                            const SizedBox(width: 16),
                            OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Quay lại'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
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
        onTap: () {
          Navigator.of(context).pop(address);
        },
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
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddressForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddressFormScreen(),
      ),
    ).then((_) => _loadAddresses());
  }
} 