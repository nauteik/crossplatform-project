import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:frontend_admin/core/utils/image_helper.dart';
import 'package:frontend_admin/models/product_type_model.dart';
import 'package:frontend_admin/providers/product_type_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';
import 'dart:typed_data';

class ProductTypesTab extends StatefulWidget {
  const ProductTypesTab({super.key});

  @override
  State<ProductTypesTab> createState() => _ProductTypesTabState();
}

class _ProductTypesTabState extends State<ProductTypesTab> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  ProductType? _selectedProductType;
  XFile? _imageFile;
  Uint8List? _webImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductTypes();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
        
        if (kIsWeb) {
          // Cho nền tảng web, đọc bytes để hiển thị
          try {
            final imageBytes = await pickedFile.readAsBytes();
            setState(() {
              _webImage = imageBytes;
            });
          } catch (e) {
            _showErrorSnackBar('Không thể đọc hình ảnh: $e');
          }
        }
      }
    } catch (e) {
      _showErrorSnackBar('Không thể chọn hình ảnh: $e');
    }
  }

  void _loadProductTypes() {
    setState(() => _isLoading = true);
    Provider.of<ProductTypeProvider>(context, listen: false)
        .fetchProductTypes()
        .then((_) {
      setState(() => _isLoading = false);
    }).catchError((error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Không thể tải danh mục sản phẩm: $error');
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _addProductType() {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra xem đã chọn hình ảnh chưa
      if (!_hasNewImageSelected()) {
        _showErrorSnackBar('Vui lòng chọn hình ảnh cho danh mục');
        return;
      }
      
      setState(() => _isLoading = true);
      
      final name = _nameController.text.trim();
      
      Provider.of<ProductTypeProvider>(context, listen: false)
          .createProductTypeWithImage(name, _imageFile)
          .then((_) {
        setState(() {
          _isLoading = false;
          _nameController.clear();
          _imageFile = null;
          _webImage = null;
        });
        _showSuccessSnackBar('Thêm danh mục thành công');
        _loadProductTypes();
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Không thể thêm danh mục: $error');
      });
    }
  }
  
  // Kiểm tra xem đã có hình ảnh mới được chọn chưa
  bool _hasNewImageSelected() {
    return _imageFile != null;
  }

  // Kiểm tra xem một danh mục đã có hình ảnh hợp lệ chưa
  bool _hasValidImage(ProductType? productType) {
    if (productType == null) return false;
    return productType.image.isNotEmpty;
  }

  // Kiểm tra xem đã có hình ảnh mới hoặc đã có hình ảnh cũ
  bool _hasValidImageSelection() {
    return _imageFile != null || (_selectedProductType != null && _hasValidImage(_selectedProductType));
  }

  void _updateProductType() {
    if (_formKey.currentState!.validate() && _selectedProductType != null) {
      // Kiểm tra xem có ảnh mới hoặc đã có ảnh cũ
      if (!_hasValidImageSelection()) {
        _showErrorSnackBar('Vui lòng chọn hình ảnh cho danh mục');
        return;
      }
      
      setState(() => _isLoading = true);
      
      final name = _nameController.text.trim();
      
      // Xử lý dựa vào trạng thái hình ảnh
      if (_imageFile != null) {
        // Cập nhật với hình ảnh mới
        Provider.of<ProductTypeProvider>(context, listen: false)
            .updateProductTypeWithImage(_selectedProductType!.id, name, _imageFile)
            .then((_) {
          _handleUpdateSuccess();
        }).catchError((error) {
          _handleUpdateError(error);
        });
      } else if (_hasValidImage(_selectedProductType)) {
        // Giữ nguyên hình ảnh cũ
        Provider.of<ProductTypeProvider>(context, listen: false)
            .updateProductTypeWithImageUrl(_selectedProductType!.id, name, _selectedProductType!.image)
            .then((_) {
          _handleUpdateSuccess();
        }).catchError((error) {
          _handleUpdateError(error);
        });
      }
    }
  }
  
  void _handleUpdateSuccess() {
    setState(() {
      _isLoading = false;
      _nameController.clear();
      _selectedProductType = null;
      _imageFile = null;
      _webImage = null;
    });
    _showSuccessSnackBar('Cập nhật danh mục thành công');
    _loadProductTypes();
  }
  
  void _handleUpdateError(dynamic error) {
    setState(() => _isLoading = false);
    _showErrorSnackBar('Không thể cập nhật danh mục: $error');
  }

  void _deleteProductType(ProductType productType) {
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
              Text('Bạn có chắc chắn muốn xóa danh mục:'),
              const SizedBox(height: 8),
              Text(
                productType.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Lưu ý: Hành động này có thể ảnh hưởng đến các sản phẩm đang thuộc danh mục này.',
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
                
                Provider.of<ProductTypeProvider>(context, listen: false)
                    .deleteProductType(productType.id)
                    .then((_) {
                  setState(() => _isLoading = false);
                  _showSuccessSnackBar('Xóa danh mục thành công');
                  
                  // Nếu đang chọn item này, reset form
                  if (_selectedProductType?.id == productType.id) {
                    setState(() {
                      _selectedProductType = null;
                      _nameController.clear();
                      _imageFile = null;
                      _webImage = null;
                    });
                  }
                  
                  _loadProductTypes();
                }).catchError((error) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Không thể xóa danh mục: $error');
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

  void _selectProductType(ProductType productType) {
    setState(() {
      _selectedProductType = productType;
      _nameController.text = productType.name;
      _imageFile = null; // Reset hình ảnh đã chọn
      _webImage = null;
    });
  }

  void _cancelEdit() {
    setState(() {
      _selectedProductType = null;
      _nameController.clear();
      _imageFile = null;
      _webImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề và mô tả
              Text(
                'Quản lý danh mục sản phẩm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Thêm, sửa, xóa các danh mục sản phẩm trong hệ thống',
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
                    // Danh sách danh mục - bên trái
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
                                  'Danh sách danh mục',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade800,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: 'Làm mới',
                                  onPressed: _isLoading ? null : _loadProductTypes,
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
                                  : Consumer<ProductTypeProvider>(
                                      builder: (context, provider, child) {
                                        final productTypes = provider.productTypes;
                                        
                                        if (productTypes.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.category_outlined,
                                                  size: 60,
                                                  color: Colors.grey.shade400,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Chưa có danh mục nào',
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
                                          itemCount: productTypes.length,
                                          itemBuilder: (context, index) {
                                            final productType = productTypes[index];
                                            final isSelected = _selectedProductType?.id == productType.id;
                                            
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
                                                onTap: () => _selectProductType(productType),
                                                leading: productType.image.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(8),
                                                      child: Image.network(
                                                        ImageHelper.getProductImage(productType.image),
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration: BoxDecoration(
                                                              color: Colors.indigo.shade100,
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                Icons.category,
                                                                color: Colors.indigo.shade700,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  : Container(
                                                      width: 50,
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.indigo.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Center(
                                                        child: Icon(
                                                          Icons.category,
                                                          color: Colors.indigo.shade700,
                                                        ),
                                                      ),
                                                    ),
                                                title: Text(
                                                  productType.name,
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
                                                      onPressed: () => _selectProductType(productType),
                                                      tooltip: 'Sửa',
                                                    ),
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.delete,
                                                        color: Colors.red.shade600,
                                                      ),
                                                      onPressed: () => _deleteProductType(productType),
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
                    
                    // Form thêm/sửa danh mục - bên phải
                    Expanded(
                      flex: 4,
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
                                _selectedProductType == null ? 'Thêm danh mục mới' : 'Cập nhật danh mục',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedProductType == null
                                      ? Colors.green.shade700
                                      : Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Trường nhập tên
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Tên danh mục',
                                  hintText: 'Nhập tên danh mục',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  prefixIcon: const Icon(Icons.category),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Vui lòng nhập tên danh mục';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Phần chọn hình ảnh
                              Text(
                                'Hình ảnh danh mục',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _pickImage,
                                child: Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: _buildImagePreview(),
                                ),
                              ),
                              if (_imageFile != null || (_selectedProductType != null && _selectedProductType!.image.isNotEmpty))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _imageFile = null;
                                        _webImage = null;
                                      });
                                    },
                                    icon: Icon(Icons.delete_outline, color: Colors.red.shade600, size: 18),
                                    label: Text(
                                      'Xóa ảnh',
                                      style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      backgroundColor: Colors.red.shade50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              
                              const Spacer(),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_selectedProductType != null)
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
                                        : (_selectedProductType == null
                                            ? _addProductType
                                            : _updateProductType),
                                    icon: Icon(_selectedProductType == null
                                        ? Icons.add
                                        : Icons.save),
                                    label: Text(_selectedProductType == null
                                        ? 'Thêm danh mục'
                                        : 'Lưu thay đổi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _selectedProductType == null
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
        ),
        // Hiển thị overlay khi đang tải
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  // Phương thức cải tiến để xử lý hiển thị hình ảnh tương thích với cả web và mobile
  Widget _buildImagePreview() {
    if (_imageFile != null) {
      if (kIsWeb) {
        // Xử lý hiển thị hình ảnh trên web
        return _webImage != null 
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  _webImage!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              )
            : const Center(child: CircularProgressIndicator());
      } else {
        // Xử lý hiển thị hình ảnh trên mobile sử dụng universal_io
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(_imageFile!.path),
            width: double.infinity,
            height: 150,
            fit: BoxFit.cover,
          ),
        );
      }
    } else if (_selectedProductType != null && _selectedProductType!.image.isNotEmpty) {
      // Hiển thị hình ảnh hiện tại từ server
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          ImageHelper.getProductImage(_selectedProductType!.image),
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Không thể tải ảnh',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else {
      // Hiển thị placeholder khi không có hình ảnh
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm hình ảnh',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
} 