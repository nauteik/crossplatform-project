import 'package:flutter/material.dart';
import 'package:frontend_user/core/utils/format_currency.dart';
import 'package:frontend_user/data/model/product_model.dart';
import 'package:frontend_user/data/respository/product_repository.dart';

class ComponentSelectionScreen extends StatefulWidget {
  final String componentType;
  final List<ProductModel> availableComponents;
  final Function(ProductModel) onComponentSelected;

  const ComponentSelectionScreen({
    super.key,
    required this.componentType,
    required this.availableComponents,
    required this.onComponentSelected,
  });

  @override
  State<ComponentSelectionScreen> createState() => _ComponentSelectionScreenState();
}

class _ComponentSelectionScreenState extends State<ComponentSelectionScreen> {
  late List<ProductModel> _filteredComponents;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  final ProductRepository _productRepository = ProductRepository();

  @override
  void initState() {
    super.initState();
    _filteredComponents = widget.availableComponents;
    if (_filteredComponents.isEmpty) {
      _loadProductsByType();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProductsByType() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      String productTypeName = '';
      switch (widget.componentType.toLowerCase()) {
        case 'cpu':
          productTypeName = 'CPU';
          break;
        case 'motherboard':
          productTypeName = 'Mainboard';
          break;
        case 'graphics card':
          productTypeName = 'GPU';
          break;
        case 'ram':
          productTypeName = 'RAM';
          break;
        case 'storage':
          // Could be either SSD or HDD
          productTypeName = 'SSD';
          break;
        case 'power supply':
          productTypeName = 'PSU';
          break;
        case 'case':
          productTypeName = 'Case';
          break;
        case 'cooling':
          productTypeName = 'Cooling';
          break;
      }

      if (productTypeName.isNotEmpty) {
        final result = await _productRepository.getProductsByType(productTypeName);
        if (!mounted) {
          return;
        }
        
        if (result.status == 200) {
          setState(() {
            _filteredComponents = result.data ?? [];
          });
        }
      }
    } catch (e) {
      if (!mounted) {
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading components: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterComponents(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredComponents = widget.availableComponents;
      } else {
        _filteredComponents = widget.availableComponents
            .where((component) =>
                component.name.toLowerCase().contains(query.toLowerCase()) ||
                component.description.toLowerCase().contains(query.toLowerCase()) ||
                (component.brand['name']?.toString().toLowerCase() ?? '').contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select ${widget.componentType}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${widget.componentType}',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterComponents,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComponents.isEmpty
                    ? Center(
                        child: Text('No ${widget.componentType} components found'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredComponents.length,
                        itemBuilder: (context, index) {
                          final component = _filteredComponents[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                widget.onComponentSelected(component);
                                Navigator.pop(context);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: component.primaryImageUrl.isNotEmpty
                                          ? Image.network(
                                              "http://localhost:8080/api/images/${component.primaryImageUrl}",
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.image_not_supported),
                                            )
                                          : const Icon(Icons.computer, size: 40),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            component.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Brand: ${component.brand['name'] ?? ''}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            component.description,
                                            style: const TextStyle(fontSize: 14),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                formatCurrency(component.price),
                                                style: TextStyle(
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              if (component.quantity > 0)
                                                Text(
                                                  'In Stock: ${component.quantity}',
                                                  style: TextStyle(
                                                    color: Colors.green.shade700,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  'Out of Stock',
                                                  style: TextStyle(
                                                    color: Colors.red.shade700,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}