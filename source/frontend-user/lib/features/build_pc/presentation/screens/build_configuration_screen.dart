import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:frontend_user/core/utils/format_currency.dart';
import 'package:frontend_user/core/utils/navigation_helper.dart';
import 'package:frontend_user/data/model/product_model.dart';
import 'package:frontend_user/data/respository/product_repository.dart';
import 'package:frontend_user/features/build_pc/presentation/widgets/component_card.dart';
import 'package:frontend_user/features/build_pc/presentation/screens/component_selection_screen.dart';
import 'package:frontend_user/features/build_pc/presentation/screens/saved_builds_screen.dart';
import 'package:frontend_user/features/build_pc/providers/pc_provider.dart';
import 'package:frontend_user/features/auth/providers/auth_provider.dart';

class BuildConfigurationScreen extends StatefulWidget {
  const BuildConfigurationScreen({super.key});

  @override
  State<BuildConfigurationScreen> createState() => _BuildConfigurationScreenState();
}

class _BuildConfigurationScreenState extends State<BuildConfigurationScreen> {
  final ProductRepository _productRepository = ProductRepository();
  final TextEditingController _buildNameController = TextEditingController();
  PCBuildType _selectedBuildType = PCBuildType.custom;
  bool _isLoading = false;
  bool _isLoadingProducts = false;
  List<ProductModel> _availableProducts = [];

  @override
  void initState() {
    super.initState();
    _buildNameController.text = 'PC của tôi';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  @override
  void dispose() {
    _buildNameController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final result = await _productRepository.getProducts();
      if (!mounted) return;
      
      if (result.status == 200) {
        setState(() {
          _availableProducts = result.data ?? [];
        });

        // Update suggested components in provider
        final pcProvider = Provider.of<PCProvider>(context, listen: false);
        pcProvider.updateSuggestions(_availableProducts);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  void _showComponentSelectionScreen(
    BuildContext context,
    String componentType,
    List<ProductModel> availableComponents,
    Function(ProductModel) onComponentSelected,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComponentSelectionScreen(
          componentType: componentType,
          availableComponents: availableComponents,
          onComponentSelected: onComponentSelected,
        ),
      ),
    );
  }

  Future<void> _buildPC() async {
    // Validate build name
    if (_buildNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên cho PC của bạn')),
      );
      return;
    }

    // Check if user is authenticated
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      // Use NavigationHelper to redirect to login instead of showing a snackbar
      NavigationHelper.navigateToLogin(context);
      return;
    }

    final pcProvider = Provider.of<PCProvider>(context, listen: false);
    
    // Additional validation based on build type
    if (_selectedBuildType == PCBuildType.custom) {
      // For custom builds, require at least CPU, motherboard, and RAM
      if (pcProvider.selectedCpu == null || 
          pcProvider.selectedMotherboard == null || 
          pcProvider.selectedRam == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tối thiểu, CPU, Mainboard và RAM là bắt buộc cho việc tạo PC tùy chỉnh')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await pcProvider.createPCBuild(_buildNameController.text, _selectedBuildType);
      
      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PC đã được tạo thành công!')),
        );
        
        // Reset form and selections after successful creation
        pcProvider.resetSelection();
        _buildNameController.text = 'PC của tôi';
        setState(() {
          _selectedBuildType = PCBuildType.custom;
        });

        // Optionally, navigate to saved builds screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SavedBuildsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${pcProvider.errorMessage}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating PC: ${e.toString()}')),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pcProvider = Provider.of<PCProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo PC của bạn'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Xem PC đã lưu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SavedBuildsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoadingProducts 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Build Name Input
                    TextField(
                      controller: _buildNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên PC',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Build Type Selection
                    const Text(
                      'Chọn loại PC:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Build Type Buttons
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildTypeButton(
                            context: context,
                            type: PCBuildType.custom,
                            icon: Icons.computer,
                            label: 'PC tùy chỉnh',
                            description: 'Chọn tất cả các thành phần',
                          ),
                          _buildTypeButton(
                            context: context,
                            type: PCBuildType.gaming,
                            icon: Icons.gamepad,
                            label: 'Gaming PC',
                            description: 'Tối ưu cho game',
                          ),
                          _buildTypeButton(
                            context: context,
                            type: PCBuildType.workstation,
                            icon: Icons.work,
                            label: 'Workstation PC',
                            description: 'Dành cho công việc chuyên nghiệp',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    
                    // Components Selection
                    const Text(
                      'Chọn các thành phần:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // CPU
                    ComponentCard(
                      componentType: 'CPU',
                      selectedComponent: pcProvider.selectedCpu,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'CPU', 
                        pcProvider.suggestedCpus.isNotEmpty ? pcProvider.suggestedCpus : _availableProducts.where((p) => p.productType['name'] == 'CPU').toList(), 
                        pcProvider.selectCpu,
                      ),
                      onRemovePressed: pcProvider.selectedCpu != null 
                          ? () => pcProvider.selectCpu(null)
                          : null,
                      icon: Icons.memory,
                    ),
                    
                    // Motherboard
                    ComponentCard(
                      componentType: 'Bo mạch chủ',
                      selectedComponent: pcProvider.selectedMotherboard,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Bo mạch chủ', 
                        pcProvider.suggestedMotherboards.isNotEmpty ? pcProvider.suggestedMotherboards : _availableProducts.where((p) => p.productType['name'] == 'Mainboard').toList(),
                        pcProvider.selectMotherboard,
                      ),
                      onRemovePressed: pcProvider.selectedMotherboard != null 
                          ? () => pcProvider.selectMotherboard(null) 
                          : null,
                      icon: Icons.dashboard,
                    ),
                    
                    // GPU
                    ComponentCard(
                      componentType: 'Card đồ họa',
                      selectedComponent: pcProvider.selectedGpu,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Card đồ họa', 
                        pcProvider.suggestedGpus.isNotEmpty ? pcProvider.suggestedGpus : _availableProducts.where((p) => p.productType['name'] == 'GPU').toList(),
                        pcProvider.selectGpu,
                      ),
                      onRemovePressed: pcProvider.selectedGpu != null 
                          ? () => pcProvider.selectGpu(null) 
                          : null,
                      icon: Icons.videogame_asset,
                    ),
                    
                    // RAM
                    ComponentCard(
                      componentType: 'RAM',
                      selectedComponent: pcProvider.selectedRam,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'RAM', 
                        pcProvider.suggestedRams.isNotEmpty ? pcProvider.suggestedRams : _availableProducts.where((p) => p.productType['name'] == 'RAM').toList(),
                        pcProvider.selectRam,
                      ),
                      onRemovePressed: pcProvider.selectedRam != null 
                          ? () => pcProvider.selectRam(null) 
                          : null,
                      icon: Icons.memory_outlined,
                    ),
                    
                    // Storage
                    ComponentCard(
                      componentType: 'Ổ cứng',
                      selectedComponent: pcProvider.selectedStorage,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Ổ cứng', 
                        pcProvider.suggestedStorages.isNotEmpty ? pcProvider.suggestedStorages : _availableProducts.where((p) => (p.productType['name'] == 'SSD' || p.productType['name'] == 'HDD')).toList(),
                        pcProvider.selectStorage,
                      ),
                      onRemovePressed: pcProvider.selectedStorage != null 
                          ? () => pcProvider.selectStorage(null) 
                          : null,
                      icon: Icons.storage,
                    ),
                    
                    // Power Supply
                    ComponentCard(
                      componentType: 'Nguồn',
                      selectedComponent: pcProvider.selectedPowerSupply,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Nguồn', 
                        pcProvider.suggestedPowerSupplies.isNotEmpty ? pcProvider.suggestedPowerSupplies : _availableProducts.where((p) => p.productType['name'] == 'PSU').toList(),
                        pcProvider.selectPowerSupply,
                      ),
                      onRemovePressed: pcProvider.selectedPowerSupply != null 
                          ? () => pcProvider.selectPowerSupply(null) 
                          : null,
                      icon: Icons.electrical_services,
                    ),
                    
                    // Case
                    ComponentCard(
                      componentType: 'Case PC',
                      selectedComponent: pcProvider.selectedCase,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Case PC', 
                        pcProvider.suggestedCases.isNotEmpty ? pcProvider.suggestedCases : _availableProducts.where((p) => p.productType['name'] == 'Case').toList(),
                        pcProvider.selectCase,
                      ),
                      onRemovePressed: pcProvider.selectedCase != null 
                          ? () => pcProvider.selectCase(null) 
                          : null,
                      icon: Icons.cases,
                    ),
                    
                    // Cooling
                    ComponentCard(
                      componentType: 'Bộ làm mát',
                      selectedComponent: pcProvider.selectedCooling,
                      onSelectPressed: () => _showComponentSelectionScreen(
                        context, 
                        'Bộ làm mát', 
                        pcProvider.suggestedCoolings.isNotEmpty ? pcProvider.suggestedCoolings : _availableProducts.where((p) => p.productType['name'] == 'Cooling').toList(),
                        pcProvider.selectCooling,
                      ),
                      onRemovePressed: pcProvider.selectedCooling != null 
                          ? () => pcProvider.selectCooling(null) 
                          : null,
                      icon: Icons.ac_unit,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Socket Compatibility Check
                    if (pcProvider.selectedCpu != null && pcProvider.selectedMotherboard != null)
                      _buildSocketCompatibilityInfo(context, pcProvider),
                    
                    const SizedBox(height: 16),
                    
                    // Total Price
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng tiền:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            formatCurrency(pcProvider.totalPrice),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Build Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _buildPC,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'TẠO PC',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildTypeButton({
    required BuildContext context,
    required PCBuildType type,
    required IconData icon,
    required String label,
    required String description,
  }) {
    bool isSelected = _selectedBuildType == type;
    
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedBuildType = type;
          });
          
          // Update component suggestions based on build type if needed
          final pcProvider = Provider.of<PCProvider>(context, listen: false);
          pcProvider.updateRecommendationsForBuildType(type, _availableProducts);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          width: 180,
          height: 200, // Increased height to avoid overflow
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white
                : Colors.white,
            border: Border.all(
              color: isSelected 
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2.5 : 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected 
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.2)
                      : Colors.grey.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 48,
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: isSelected
                      ? Theme.of(context).primaryColor.withOpacity(0.8)
                      : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildSocketCompatibilityInfo(BuildContext context, PCProvider pcProvider) {
    final isCompatible = pcProvider.checkSocketCompatibility();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompatible ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompatible ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isCompatible
                ? 'CPU and Motherboard are compatible.'
                : 'Warning: CPU and Motherboard are not compatible!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isCompatible ? Colors.green.shade700 : Colors.red.shade700,
            ),
          ),
          Icon(
            isCompatible ? Icons.check_circle : Icons.error,
            color: isCompatible ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}