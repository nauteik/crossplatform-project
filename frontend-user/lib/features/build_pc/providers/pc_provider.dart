import 'package:flutter/foundation.dart';
import 'package:frontend_user/data/model/product_model.dart';
import 'package:frontend_user/features/build_pc/models/pc_model.dart';
import 'package:frontend_user/features/build_pc/repositories/pc_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PCBuildType {
  custom,
  gaming,
  workstation,
  budget
}

class PCProvider extends ChangeNotifier {
  final PCRepository _repository = PCRepository();
  
  PCModel? _currentBuild;
  List<PCModel> _userBuilds = [];
  bool _isLoading = false;
  String _errorMessage = '';
  
  // Selected components for custom build
  ProductModel? _selectedCpu;
  ProductModel? _selectedMotherboard;
  ProductModel? _selectedGpu;
  ProductModel? _selectedRam;
  ProductModel? _selectedStorage;
  ProductModel? _selectedPowerSupply;
  ProductModel? _selectedCase;
  ProductModel? _selectedCooling;
  
  // Component suggestions based on selected build type
  List<ProductModel> _suggestedCpus = [];
  List<ProductModel> _suggestedMotherboards = [];
  List<ProductModel> _suggestedGpus = [];
  List<ProductModel> _suggestedRams = [];
  List<ProductModel> _suggestedStorages = [];
  List<ProductModel> _suggestedPowerSupplies = [];
  List<ProductModel> _suggestedCases = [];
  List<ProductModel> _suggestedCoolings = [];
  
  // Getters
  PCModel? get currentBuild => _currentBuild;
  List<PCModel> get userBuilds => _userBuilds;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  ProductModel? get selectedCpu => _selectedCpu;
  ProductModel? get selectedMotherboard => _selectedMotherboard;
  ProductModel? get selectedGpu => _selectedGpu;
  ProductModel? get selectedRam => _selectedRam;
  ProductModel? get selectedStorage => _selectedStorage;
  ProductModel? get selectedPowerSupply => _selectedPowerSupply;
  ProductModel? get selectedCase => _selectedCase;
  ProductModel? get selectedCooling => _selectedCooling;
  
  List<ProductModel> get suggestedCpus => _suggestedCpus;
  List<ProductModel> get suggestedMotherboards => _suggestedMotherboards;
  List<ProductModel> get suggestedGpus => _suggestedGpus;
  List<ProductModel> get suggestedRams => _suggestedRams;
  List<ProductModel> get suggestedStorages => _suggestedStorages;
  List<ProductModel> get suggestedPowerSupplies => _suggestedPowerSupplies;
  List<ProductModel> get suggestedCases => _suggestedCases;
  List<ProductModel> get suggestedCoolings => _suggestedCoolings;
  
  // Calculate total price of selected components
  double get totalPrice {
    double total = 0;
    if (_selectedCpu != null) total += _selectedCpu!.price;
    if (_selectedMotherboard != null) total += _selectedMotherboard!.price;
    if (_selectedGpu != null) total += _selectedGpu!.price;
    if (_selectedRam != null) total += _selectedRam!.price;
    if (_selectedStorage != null) total += _selectedStorage!.price;
    if (_selectedPowerSupply != null) total += _selectedPowerSupply!.price;
    if (_selectedCase != null) total += _selectedCase!.price;
    if (_selectedCooling != null) total += _selectedCooling!.price;
    return total;
  }
  
  // Reset all selected components
  void resetSelection() {
    _selectedCpu = null;
    _selectedMotherboard = null;
    _selectedGpu = null;
    _selectedRam = null;
    _selectedStorage = null;
    _selectedPowerSupply = null;
    _selectedCase = null;
    _selectedCooling = null;
    _currentBuild = null;
    notifyListeners();
  }
  
  // Component selection methods
  void selectCpu(ProductModel? cpu) {
    _selectedCpu = cpu;
    notifyListeners();
  }
  
  void selectMotherboard(ProductModel? motherboard) {
    _selectedMotherboard = motherboard;
    notifyListeners();
  }
  
  void selectGpu(ProductModel? gpu) {
    _selectedGpu = gpu;
    notifyListeners();
  }
  
  void selectRam(ProductModel? ram) {
    _selectedRam = ram;
    notifyListeners();
  }
  
  void selectStorage(ProductModel? storage) {
    _selectedStorage = storage;
    notifyListeners();
  }
  
  void selectPowerSupply(ProductModel? powerSupply) {
    _selectedPowerSupply = powerSupply;
    notifyListeners();
  }
  
  void selectCase(ProductModel? pcCase) {
    _selectedCase = pcCase;
    notifyListeners();
  }
  
  void selectCooling(ProductModel? cooling) {
    _selectedCooling = cooling;
    notifyListeners();
  }
  
  // Load user PC builds
  Future<void> loadUserBuilds() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      
      if (userId == null) {
        _errorMessage = 'User not authenticated';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final result = await _repository.getPCsByUser(userId);
      _userBuilds = result.data ?? [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Create a new PC build based on type
  Future<bool> createPCBuild(String name, PCBuildType buildType) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'unknown';
      
      Map<String, String> componentMap = {};
      
      if (buildType == PCBuildType.custom) {
        if (_selectedCpu != null) componentMap['cpu'] = _selectedCpu!.id;
        if (_selectedMotherboard != null) componentMap['motherboard'] = _selectedMotherboard!.id;
        if (_selectedGpu != null) componentMap['gpu'] = _selectedGpu!.id;
        if (_selectedRam != null) componentMap['ram'] = _selectedRam!.id;
        if (_selectedStorage != null) componentMap['storage'] = _selectedStorage!.id;
        if (_selectedPowerSupply != null) componentMap['powerSupply'] = _selectedPowerSupply!.id;
        if (_selectedCase != null) componentMap['pcCase'] = _selectedCase!.id;
        if (_selectedCooling != null) componentMap['cooling'] = _selectedCooling!.id;
        
        final result = await _repository.buildCustomPC(name, userId, componentMap);
        _currentBuild = result.data;
      } 
      else if (buildType == PCBuildType.gaming) {
        // Optional custom components for gaming build
        if (_selectedCpu != null || _selectedGpu != null) {
          if (_selectedCpu != null) componentMap['cpu'] = _selectedCpu!.id;
          if (_selectedGpu != null) componentMap['gpu'] = _selectedGpu!.id;
          if (_selectedRam != null) componentMap['ram'] = _selectedRam!.id;
          if (_selectedStorage != null) componentMap['storage'] = _selectedStorage!.id;
        }
        
        final result = await _repository.buildGamingPC(name, userId, componentMap.isNotEmpty ? componentMap : null);
        _currentBuild = result.data;
      }
      else if (buildType == PCBuildType.workstation) {
        // Optional custom components for workstation build
        if (_selectedCpu != null || _selectedRam != null) {
          if (_selectedCpu != null) componentMap['cpu'] = _selectedCpu!.id;
          if (_selectedRam != null) componentMap['ram'] = _selectedRam!.id;
          if (_selectedStorage != null) componentMap['storage'] = _selectedStorage!.id;
        }
        
        final result = await _repository.buildWorkstationPC(name, userId, componentMap.isNotEmpty ? componentMap : null);
        _currentBuild = result.data;
      }
      
      _isLoading = false;
      notifyListeners();
      
      // Refresh user builds after creating a new one
      await loadUserBuilds();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a PC build
  Future<bool> deletePCBuild(String pcId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _repository.deletePC(pcId);
      
      // Remove from local list
      _userBuilds.removeWhere((build) => build.id == pcId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Add all components of a PC build to the user's cart
  Future<bool> addPCComponentsToCart(String pcId, String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    
    try {
      final result = await _repository.addPCComponentsToCart(pcId, userId);
      
      _isLoading = false;
      notifyListeners();
      
      if (result.status == 1) {
        return true;
      } else {
        _errorMessage = result.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update component suggestions based on selected components
  void updateSuggestions(List<ProductModel> products) {
    _suggestedCpus = products.where((p) => p.productType['name'] == 'CPU').toList();
    _suggestedMotherboards = products.where((p) => p.productType['name'] == 'Mainboard').toList();
    _suggestedGpus = products.where((p) => p.productType['name'] == 'GPU').toList();
    _suggestedRams = products.where((p) => p.productType['name'] == 'RAM').toList();
    _suggestedStorages = products.where((p) => 
      p.productType['name'] == 'SSD' || p.productType['name'] == 'HDD').toList();
    _suggestedPowerSupplies = products.where((p) => p.productType['name'] == 'PSU').toList();
    _suggestedCases = products.where((p) => p.productType['name'] == 'Case').toList();
    _suggestedCoolings = products.where((p) => p.productType['name'] == 'Cooling').toList();
    
    notifyListeners();
  }
  
  // Update component recommendations based on build type
  void updateRecommendationsForBuildType(PCBuildType type, List<ProductModel> availableProducts) {
    // First update all suggestions with available products
    updateSuggestions(availableProducts);
    
    // Then filter or prioritize based on build type
    switch (type) {
      case PCBuildType.gaming:
        // For gaming PCs, prioritize high-performance GPUs and CPUs
        _suggestedGpus = _suggestedGpus
            .where((gpu) => _isHighPerformanceGaming(gpu))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price)); // Sort by price descending
          
        _suggestedCpus = _suggestedCpus
            .where((cpu) => _isGamingCpu(cpu))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price));
          
        // Gaming builds typically need good RAM (16GB+)
        _suggestedRams = _suggestedRams
            .where((ram) => _isGamingRam(ram))
            .toList();
            
        // Fast storage for game loading
        _suggestedStorages = _suggestedStorages
            .where((storage) => storage.productType['name'] == 'SSD') // Prefer SSDs
            .toList();
        break;
        
      case PCBuildType.workstation:
        // For workstations, prioritize CPU performance and RAM capacity
        _suggestedCpus = _suggestedCpus
            .where((cpu) => _isWorkstationCpu(cpu))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price));
          
        // Workstations need more RAM
        _suggestedRams = _suggestedRams
            .where((ram) => _isWorkstationRam(ram))
            .toList()
          ..sort((a, b) => b.price.compareTo(a.price));
          
        // Large and fast storage
        _suggestedStorages = _suggestedStorages
            .where((storage) => _isWorkstationStorage(storage))
            .toList();
        break;
        
      case PCBuildType.budget:
        // For budget builds, prioritize value components
        _suggestedCpus.sort((a, b) => a.price.compareTo(b.price)); // Sort by price ascending
        _suggestedGpus.sort((a, b) => a.price.compareTo(b.price));
        _suggestedRams.sort((a, b) => a.price.compareTo(b.price));
        _suggestedStorages.sort((a, b) => a.price.compareTo(b.price));
        _suggestedPowerSupplies.sort((a, b) => a.price.compareTo(b.price));
        _suggestedCases.sort((a, b) => a.price.compareTo(b.price));
        _suggestedCoolings.sort((a, b) => a.price.compareTo(b.price));
        break;
        
      case PCBuildType.custom:
      default:
        // Keep all suggestions as is for custom builds
        break;
    }
    
    notifyListeners();
  }
  
  // Helper methods for component filtering based on build type
  bool _isHighPerformanceGaming(ProductModel gpu) {
    // Check if GPU has gaming keywords in name or specs
    final name = gpu.name.toLowerCase();
    final description = gpu.description?.toLowerCase() ?? '';
    
    return name.contains('rtx') || 
           name.contains('gaming') || 
           description.contains('gaming') ||
           description.contains('high performance');
  }
  
  bool _isGamingCpu(ProductModel cpu) {
    final name = cpu.name.toLowerCase();
    final description = cpu.description?.toLowerCase() ?? '';
    
    return name.contains('gaming') || 
           name.contains('i7') || 
           name.contains('i9') ||
           name.contains('ryzen 7') ||
           name.contains('ryzen 9') ||
           description.contains('gaming');
  }
  
  bool _isGamingRam(ProductModel ram) {
    // Gaming RAM typically 16GB or higher
    final name = ram.name.toLowerCase();
    final description = ram.description?.toLowerCase() ?? '';
    
    return name.contains('16gb') || 
           name.contains('32gb') ||
           description.contains('gaming') ||
           description.contains('rgb');
  }
  
  bool _isWorkstationCpu(ProductModel cpu) {
    final name = cpu.name.toLowerCase();
    final description = cpu.description?.toLowerCase() ?? '';
    
    return name.contains('xeon') || 
           name.contains('threadripper') ||
           name.contains('i9') ||
           name.contains('ryzen 9') ||
           description.contains('workstation') ||
           description.contains('professional');
  }
  
  bool _isWorkstationRam(ProductModel ram) {
    // Workstation RAM typically 32GB or higher
    final name = ram.name.toLowerCase();
    final description = ram.description?.toLowerCase() ?? '';
    
    return name.contains('32gb') || 
           name.contains('64gb') ||
           name.contains('ecc') ||
           description.contains('workstation') ||
           description.contains('professional');
  }
  
  bool _isWorkstationStorage(ProductModel storage) {
    // Workstations need large and reliable storage
    final name = storage.name.toLowerCase();
    final description = storage.description?.toLowerCase() ?? '';
    
    return storage.productType['name'] == 'SSD' ||
           name.contains('1tb') || 
           name.contains('2tb') ||
           name.contains('nvme') ||
           description.contains('workstation') ||
           description.contains('professional');
  }

  // Socket compatibility check between CPU and motherboard
  bool checkSocketCompatibility() {
    if (_selectedCpu == null || _selectedMotherboard == null) {
      return false;
    }
    
    String? cpuSocketType = _extractSocketType(_selectedCpu!);
    String? motherboardSocketType = _extractSocketType(_selectedMotherboard!);
    
    if (cpuSocketType == null || motherboardSocketType == null) {
      return false; // Cannot determine compatibility
    }
    
    return cpuSocketType.toLowerCase() == motherboardSocketType.toLowerCase();
  }
  
  // Helper method to extract socket type from product specifications or description
  String? _extractSocketType(ProductModel product) {
    // Try to get socket from specifications
    if (product.specifications != null && product.specifications!['socket'] != null) {
      return product.specifications!['socket'].toString();
    }
    
    // Try to identify socket type from product description or name
    String searchText = (product.description) + ' ' + (product.name);
    searchText = searchText.toLowerCase();
    
    // Common Intel sockets
    if (searchText.contains('lga1700')) return 'LGA1700';
    if (searchText.contains('lga1200')) return 'LGA1200';
    if (searchText.contains('lga1151')) return 'LGA1151';
    if (searchText.contains('lga1155')) return 'LGA1155';
    
    // Common AMD sockets
    if (searchText.contains('am5')) return 'AM5';
    if (searchText.contains('am4')) return 'AM4';
    if (searchText.contains('tr4')) return 'TR4';
    
    return null;
  }
}