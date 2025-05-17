import 'package:flutter/material.dart';
import 'package:frontend_admin/models/brand_model.dart';
import 'package:frontend_admin/providers/brand_provider.dart';
import 'package:provider/provider.dart';

class BrandsTab extends StatefulWidget {
  const BrandsTab({super.key});

  @override
  State<BrandsTab> createState() => _BrandsTabState();
}

class _BrandsTabState extends State<BrandsTab> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Brand? _selectedBrand;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBrands();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadBrands() {
    setState(() => _isLoading = true);
    Provider.of<BrandProvider>(context, listen: false)
        .fetchBrands()
        .then((_) {
      setState(() => _isLoading = false);
    }).catchError((error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Không thể tải thương hiệu: $error');
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addBrand() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newBrand = Brand(
        id: '', // ID sẽ được tạo tự động bởi MongoDB
        name: _nameController.text.trim(),
      );
      
      Provider.of<BrandProvider>(context, listen: false)
          .createBrand(newBrand)
          .then((_) {
        setState(() {
          _isLoading = false;
          _nameController.clear();
        });
        _showSuccessSnackBar('Thêm thương hiệu thành công');
        _loadBrands();
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Không thể thêm thương hiệu: $error');
      });
    }
  }

  void _updateBrand() {
    if (_formKey.currentState!.validate() && _selectedBrand != null) {
      setState(() => _isLoading = true);
      
      final updatedBrand = Brand(
        id: _selectedBrand!.id,
        name: _nameController.text.trim(),
      );
      
      Provider.of<BrandProvider>(context, listen: false)
          .updateBrand(updatedBrand)
          .then((_) {
        setState(() {
          _isLoading = false;
          _nameController.clear();
          _selectedBrand = null;
        });
        _showSuccessSnackBar('Cập nhật thương hiệu thành công');
        _loadBrands();
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Không thể cập nhật thương hiệu: $error');
      });
    }
  }

  void _deleteBrand(Brand brand) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade500),
              const SizedBox(width: 10),
              const Text('Xác nhận xóa'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bạn có chắc chắn muốn xóa thương hiệu:'),
              const SizedBox(height: 8),
              Text(
                brand.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Lưu ý: Hành động này có thể ảnh hưởng đến các sản phẩm đang thuộc thương hiệu này.',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                
                Provider.of<BrandProvider>(context, listen: false)
                    .deleteBrand(brand.id)
                    .then((_) {
                  setState(() => _isLoading = false);
                  _showSuccessSnackBar('Xóa thương hiệu thành công');
                  
                  // Nếu đang chọn item này, reset form
                  if (_selectedBrand?.id == brand.id) {
                    setState(() {
                      _selectedBrand = null;
                      _nameController.clear();
                    });
                  }
                  
                  _loadBrands();
                }).catchError((error) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Không thể xóa thương hiệu: $error');
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _selectBrand(Brand brand) {
    setState(() {
      _selectedBrand = brand;
      _nameController.text = brand.name;
    });
  }

  void _cancelEdit() {
    setState(() {
      _selectedBrand = null;
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề và mô tả
          Text(
            'Quản lý thương hiệu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm, sửa, xóa các thương hiệu trong hệ thống',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bố cục ngang với danh sách bên trái, form bên phải
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Danh sách thương hiệu - bên trái
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Danh sách thương hiệu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Làm mới',
                              onPressed: _isLoading ? null : _loadBrands,
                              color: Colors.indigo.shade600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        Expanded(
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Consumer<BrandProvider>(
                                  builder: (context, provider, child) {
                                    final brands = provider.brands;
                                    
                                    if (brands.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.branding_watermark_outlined,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Chưa có thương hiệu nào',
                                              style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    
                                    return ListView.builder(
                                      itemCount: brands.length,
                                      itemBuilder: (context, index) {
                                        final brand = brands[index];
                                        final isSelected = _selectedBrand?.id == brand.id;
                                        
                                        return Card(
                                          elevation: isSelected ? 2 : 0,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: isSelected
                                                  ? Colors.blue.shade400
                                                  : Colors.grey.shade200,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            selected: isSelected,
                                            selectedTileColor: Colors.blue.shade50,
                                            onTap: () => _selectBrand(brand),
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue.shade100,
                                              child: Icon(
                                                Icons.business,
                                                color: Colors.blue.shade700,
                                              ),
                                            ),
                                            title: Text(
                                              brand.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                  onPressed: () => _selectBrand(brand),
                                                  tooltip: 'Sửa',
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red.shade600,
                                                  ),
                                                  onPressed: () => _deleteBrand(brand),
                                                  tooltip: 'Xóa',
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Form thêm/sửa thương hiệu - bên phải
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          offset: const Offset(0, 2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBrand == null ? 'Thêm thương hiệu mới' : 'Cập nhật thương hiệu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedBrand == null
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên thương hiệu',
                              hintText: 'Nhập tên thương hiệu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.branding_watermark),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên thương hiệu';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_selectedBrand != null)
                                TextButton.icon(
                                  onPressed: _isLoading ? null : _cancelEdit,
                                  icon: const Icon(Icons.cancel),
                                  label: const Text('Hủy'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade700,
                                  ),
                                ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : (_selectedBrand == null
                                        ? _addBrand
                                        : _updateBrand),
                                icon: Icon(_selectedBrand == null
                                    ? Icons.add
                                    : Icons.save),
                                label: Text(_selectedBrand == null
                                    ? 'Thêm thương hiệu'
                                    : 'Lưu thay đổi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedBrand == null
                                      ? Colors.green.shade600
                                      : Colors.blue.shade600,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                          if (_isLoading)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 