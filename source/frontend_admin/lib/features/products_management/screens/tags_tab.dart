import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend_admin/models/tag_model.dart';
import 'package:frontend_admin/providers/tag_provider.dart';
import 'package:provider/provider.dart';

class TagsTab extends StatefulWidget {
  const TagsTab({super.key});

  @override
  State<TagsTab> createState() => _TagsTabState();
}

class _TagsTabState extends State<TagsTab> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Tag? _selectedTag;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTags();
    });
    _colorController.text = '#3F51B5'; // Mặc định màu indigo
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTags() {
    setState(() => _isLoading = true);
    Provider.of<TagProvider>(context, listen: false)
        .fetchTags()
        .then((_) {
      setState(() => _isLoading = false);
    }).catchError((error) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Không thể tải tags: $error');
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

  void _addTag() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final newTag = Tag(
        id: '', // ID sẽ được tạo bởi backend
        name: _nameController.text.trim(),
        color: _colorController.text.trim(),
        description: _descriptionController.text.trim(),
        active: _isActive,
        createdAt: DateTime.now().toIso8601String(), // Thêm trường createdAt
      );
      
      Provider.of<TagProvider>(context, listen: false)
          .createTag(newTag)
          .then((_) {
        setState(() {
          _isLoading = false;
          _resetForm();
        });
        _showSuccessSnackBar('Thêm nhãn thành công');
        _loadTags();
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Không thể thêm nhãn: $error');
      });
    }
  }

  void _updateTag() {
    if (_formKey.currentState!.validate() && _selectedTag != null) {
      setState(() => _isLoading = true);
      
      final updatedTag = Tag(
        id: _selectedTag!.id,
        name: _nameController.text.trim(),
        color: _colorController.text.trim(),
        description: _descriptionController.text.trim(),
        active: _isActive,
        createdAt: _selectedTag!.createdAt, // Sử dụng createdAt từ tag hiện tại
      );
      
      Provider.of<TagProvider>(context, listen: false)
          .updateTag(updatedTag)
          .then((_) {
        setState(() {
          _isLoading = false;
          _resetForm();
        });
        _showSuccessSnackBar('Cập nhật nhãn thành công');
        _loadTags();
      }).catchError((error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Không thể cập nhật nhãn: $error');
      });
    }
  }

  void _deleteTag(Tag tag) {
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
              Text('Bạn có chắc chắn muốn xóa nhãn:'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _hexToColor(tag.color),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tag.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Lưu ý: Hành động này có thể ảnh hưởng đến các sản phẩm đang có nhãn này.',
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
                
                Provider.of<TagProvider>(context, listen: false)
                    .deleteTag(tag.id)
                    .then((_) {
                  setState(() => _isLoading = false);
                  _showSuccessSnackBar('Xóa nhãn thành công');
                  
                  // Nếu đang chọn item này, reset form
                  if (_selectedTag?.id == tag.id) {
                    _resetForm();
                  }
                  
                  _loadTags();
                }).catchError((error) {
                  setState(() => _isLoading = false);
                  _showErrorSnackBar('Không thể xóa nhãn: $error');
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

  void _selectTag(Tag tag) {
    setState(() {
      _selectedTag = tag;
      _nameController.text = tag.name;
      _colorController.text = tag.color;
      _descriptionController.text = tag.description;
      _isActive = tag.active;
    });
  }

  void _resetForm() {
    setState(() {
      _selectedTag = null;
      _nameController.clear();
      _colorController.text = '#3F51B5'; // Reset về màu mặc định
      _descriptionController.clear();
      _isActive = true;
    });
  }

  Color _hexToColor(String hexString) {
    final hexColor = hexString.replaceAll('#', '');
    if (hexColor.length == 6) {
      return Color(int.parse('FF$hexColor', radix: 16));
    }
    return Colors.black;
  }

  // Kiểm tra định dạng mã màu hex
  bool _isValidHexColor(String color) {
    final RegExp hexColorRegex = RegExp(r'^#(?:[0-9a-fA-F]{3}){1,2}$');
    return hexColorRegex.hasMatch(color);
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
            'Quản lý nhãn sản phẩm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm, sửa, xóa các nhãn cho sản phẩm (VD: Khuyến mãi, Mới, Bán chạy)',
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
                // Danh sách nhãn - bên trái
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
                              'Danh sách nhãn',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade800,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Làm mới',
                              onPressed: _isLoading ? null : _loadTags,
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
                              : Consumer<TagProvider>(
                                  builder: (context, provider, child) {
                                    final tags = provider.tags;
                                    
                                    if (tags.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.label_off_outlined,
                                              size: 60,
                                              color: Colors.grey.shade400,
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Chưa có nhãn nào',
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
                                      itemCount: tags.length,
                                      itemBuilder: (context, index) {
                                        final tag = tags[index];
                                        final isSelected = _selectedTag?.id == tag.id;
                                        final tagColor = _hexToColor(tag.color);
                                        
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
                                            onTap: () => _selectTag(tag),
                                            leading: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: tagColor.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: tagColor,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.label,
                                                  color: tagColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Text(
                                                  tag.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: tagColor.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: tagColor.withOpacity(0.5),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    tag.color,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: tagColor,
                                                    ),
                                                  ),
                                                ),
                                                if (!tag.active)
                                                  Container(
                                                    margin: const EdgeInsets.only(left: 8),
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey.shade100,
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      'Vô hiệu hóa',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade700,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            subtitle: tag.description.isNotEmpty
                                                ? Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: Text(
                                                      tag.description,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade700,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                  onPressed: () => _selectTag(tag),
                                                  tooltip: 'Sửa',
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red.shade600,
                                                  ),
                                                  onPressed: () => _deleteTag(tag),
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
                
                // Form thêm/sửa nhãn - bên phải
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
                            _selectedTag == null ? 'Thêm nhãn mới' : 'Cập nhật nhãn',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedTag == null
                                  ? Colors.green.shade700
                                  : Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Tên nhãn
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Tên nhãn',
                              hintText: 'Ví dụ: Khuyến mãi, Mới, Bán chạy',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.label),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập tên nhãn';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Màu sắc
                          TextFormField(
                            controller: _colorController,
                            decoration: InputDecoration(
                              labelText: 'Mã màu (HEX)',
                              hintText: '#RRGGBB',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.color_lens),
                              suffixIcon: Container(
                                margin: const EdgeInsets.all(8),
                                width: 24,
                                decoration: BoxDecoration(
                                  color: _isValidHexColor(_colorController.text)
                                      ? _hexToColor(_colorController.text)
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F#]')),
                              LengthLimitingTextInputFormatter(7),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập mã màu';
                              }
                              if (!_isValidHexColor(value)) {
                                return 'Định dạng màu không hợp lệ';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Tự động thêm # nếu chưa có
                              if (value.isNotEmpty && !value.startsWith('#')) {
                                _colorController.text = '#$value';
                                _colorController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: _colorController.text.length),
                                );
                              }
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              '#3F51B5', '#F44336', '#4CAF50', '#FFC107',
                              '#9C27B0', '#2196F3', '#FF9800', '#607D8B',
                            ].map((color) => InkWell(
                              onTap: () {
                                setState(() {
                                  _colorController.text = color;
                                });
                              },
                              child: Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: _hexToColor(color),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: _colorController.text == color ? 2 : 1,
                                  ),
                                ),
                              ),
                            )).toList(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Mô tả
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'Mô tả (không bắt buộc)',
                              hintText: 'Mô tả chi tiết về nhãn này',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              prefixIcon: const Icon(Icons.description),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),
                          
                          // Trạng thái kích hoạt
                          Row(
                            children: [
                              Switch(
                                value: _isActive,
                                onChanged: (value) {
                                  setState(() {
                                    _isActive = value;
                                  });
                                },
                                activeColor: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Trạng thái: ${_isActive ? 'Đang kích hoạt' : 'Đã vô hiệu hóa'}',
                                style: TextStyle(
                                  color: _isActive ? Colors.green.shade700 : Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Nút bấm
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_selectedTag != null)
                                TextButton.icon(
                                  onPressed: _isLoading ? null : _resetForm,
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
                                    : (_selectedTag == null
                                        ? _addTag
                                        : _updateTag),
                                icon: Icon(_selectedTag == null
                                    ? Icons.add
                                    : Icons.save),
                                label: Text(_selectedTag == null
                                    ? 'Thêm nhãn'
                                    : 'Lưu thay đổi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedTag == null
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