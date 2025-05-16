import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/address_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/repositories/address_provider.dart';

class AddressFormScreen extends StatefulWidget {
  final AddressModel? address;

  const AddressFormScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _wardController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.address != null) {
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phoneNumber;
      _addressLineController.text = widget.address!.addressLine;
      _wardController.text = widget.address!.ward;
      _districtController.text = widget.address!.district;
      _cityController.text = widget.address!.city;
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _wardController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    if (!authProvider.isAuthenticated || authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để lưu địa chỉ')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final address = AddressModel(
      id: widget.address?.id,
      fullName: _fullNameController.text,
      phoneNumber: _phoneController.text,
      addressLine: _addressLineController.text,
      ward: _wardController.text,
      district: _districtController.text,
      city: _cityController.text,
      isDefault: _isDefault,
    );

    bool success = false;
    try {
      if (widget.address == null) {
        // Thêm địa chỉ mới
        success = await addressProvider.addAddress(
          authProvider.userId!,
          address,
          authProvider.token ?? '',
        );
      } else {
        // Cập nhật địa chỉ
        success = await addressProvider.updateAddress(
          authProvider.userId!,
          widget.address!.id!,
          address,
          authProvider.token ?? '',
        );
      }

      if (success) {
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                addressProvider.errorMessage ?? 'Có lỗi xảy ra, vui lòng thử lại',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'Họ tên',
              hint: 'Nhập họ tên người nhận',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập họ tên';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Số điện thoại',
              hint: 'Nhập số điện thoại',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số điện thoại';
                }
                if (value.length < 10) {
                  return 'Số điện thoại không hợp lệ';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressLineController,
              label: 'Địa chỉ cụ thể',
              hint: 'Số nhà, tên đường',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập địa chỉ cụ thể';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _wardController,
              label: 'Phường/Xã',
              hint: 'Nhập phường/xã',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập phường/xã';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _districtController,
              label: 'Quận/Huyện',
              hint: 'Nhập quận/huyện',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập quận/huyện';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cityController,
              label: 'Tỉnh/Thành phố',
              hint: 'Nhập tỉnh/thành phố',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tỉnh/thành phố';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Đặt làm địa chỉ mặc định'),
              subtitle: const Text('Địa chỉ này sẽ được sử dụng mặc định khi thanh toán'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
              activeColor: Colors.blue,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAddress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      widget.address == null ? 'Thêm địa chỉ' : 'Lưu thay đổi',
                      style: const TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }
} 