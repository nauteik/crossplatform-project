import 'package:flutter/material.dart';
import '../../../../data/model/product_model.dart';

class ProductSpecifications extends StatelessWidget {
  final ProductModel product;

  const ProductSpecifications({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    // Generate all specifications
    List<Widget> allSpecs = [];
    
    // Basic info (only add non-empty values)
    if (product.productType['name'] != null && product.productType['name'].toString().isNotEmpty) {
      allSpecs.add(_buildSpecItem('Loại sản phẩm', product.productType['name']));
    }
    
    if (product.brand['name'] != null && product.brand['name'].toString().isNotEmpty) {
      allSpecs.add(_buildSpecItem('Thương hiệu', product.brand['name']));
    }
    
    allSpecs.add(_buildSpecItem('Mã sản phẩm', product.id));
    allSpecs.add(_buildSpecItem('Bảo hành', '24 tháng'));
    
    // Technical specifications
    List<Widget> detailedSpecs = [];
    if (product.specifications != null && product.specifications!.isNotEmpty) {
      detailedSpecs = buildDetailedSpecifications(product.specifications!);
    }
    
    // Special handling based on product type
    List<Widget> specialSpecs = [];
    if (product.productType['name'] == 'CPU') {
      specialSpecs = _buildCpuSpecificInfo();
    } else if (product.productType['name'] == 'Mainboard' || product.productType['name'] == 'Motherboard') {
      specialSpecs = _buildMotherboardSpecificInfo();
    } else if (product.productType['name'] == 'RAM') {
      specialSpecs = _buildRamSpecificInfo();
    }
    
    // Combine all specifications
    if (detailedSpecs.isNotEmpty || specialSpecs.isNotEmpty) {
      allSpecs.add(const Divider(height: 24));
      allSpecs.addAll(detailedSpecs);
      allSpecs.addAll(specialSpecs);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông Số Kỹ Thuật',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: allSpecs,
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> buildDetailedSpecifications(Map<String, dynamic> specs) {
    List<Widget> specWidgets = [];
    
    // Sort the keys for a consistent display
    final sortedKeys = specs.keys.toList()..sort();
    
    for (String key in sortedKeys) {
      // Skip null or empty values
      if (specs[key] == null || specs[key].toString().trim().isEmpty || 
          specs[key].toString().trim() == 'N/A') {
        continue;
      }
      
      // Use key as is, since they are already in Vietnamese
      String displayKey = key;
      
      // Add the spec item
      specWidgets.add(_buildSpecItem(displayKey, specs[key].toString()));
    }
    
    return specWidgets;
  }
  
  // Special handling for CPU products
  List<Widget> _buildCpuSpecificInfo() {
    // Extract CPU-specific info from description or specs
    final description = product.description.toLowerCase();
    final List<Widget> cpuInfo = [];
    
    // Try to identify socket type
    String socketType = '';
    if (product.specifications != null && product.specifications!['Socket'] != null) {
      socketType = product.specifications!['Socket'].toString();
    } else {
      if (description.contains('lga1700')) socketType = 'LGA1700';
      else if (description.contains('lga1200')) socketType = 'LGA1200';
      else if (description.contains('am5')) socketType = 'AM5';
      else if (description.contains('am4')) socketType = 'AM4';
    }
    
    // Try to identify cores/threads
    if (!(product.specifications != null && 
         (product.specifications!.containsKey('Số nhân') || 
          product.specifications!.containsKey('Số luồng')))) {
      final coreRegex = RegExp(r'(\d+)\s*cores?', caseSensitive: false);
      final threadRegex = RegExp(r'(\d+)\s*threads?', caseSensitive: false);
      
      final coreMatch = coreRegex.firstMatch(description);
      final threadMatch = threadRegex.firstMatch(description);
      
      if (coreMatch != null) {
        final cores = coreMatch.group(1) ?? '';
        if (cores.isNotEmpty) {
          cpuInfo.add(_buildSpecItem('Số nhân', cores));
        }
      }
      
      if (threadMatch != null) {
        final threads = threadMatch.group(1) ?? '';
        if (threads.isNotEmpty) {
          cpuInfo.add(_buildSpecItem('Số luồng', threads));
        }
      }
    }
    
    // Add socket type if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Socket')) && 
        socketType.isNotEmpty) {
      cpuInfo.add(_buildSpecItem('Socket', socketType));
    }
    
    return cpuInfo;
  }
  
  // Special handling for motherboard products
  List<Widget> _buildMotherboardSpecificInfo() {
    // Extract motherboard-specific info
    final description = product.description.toLowerCase();
    final List<Widget> moboInfo = [];
    
    // Try to identify socket type
    String socketType = '';
    if (product.specifications != null && product.specifications!['Socket'] != null) {
      socketType = product.specifications!['Socket'].toString();
    } else {
      if (description.contains('lga1700')) socketType = 'LGA1700';
      else if (description.contains('lga1200')) socketType = 'LGA1200';
      else if (description.contains('am5')) socketType = 'AM5';
      else if (description.contains('am4')) socketType = 'AM4';
    }
    
    // Try to identify chipset
    String chipset = '';
    if (product.specifications != null && product.specifications!['Chipset'] != null) {
      chipset = product.specifications!['Chipset'].toString();
    } else {
      if (description.contains('z690')) chipset = 'Z690';
      else if (description.contains('b660')) chipset = 'B660';
      else if (description.contains('x570')) chipset = 'X570';
      else if (description.contains('b550')) chipset = 'B550';
    }
    
    // Try to identify form factor
    String formFactor = '';
    if (product.specifications != null && product.specifications!['Form factor'] != null) {
      formFactor = product.specifications!['Form factor'].toString();
    } else {
      if (description.contains('atx') && !description.contains('micro') && !description.contains('mini')) {
        formFactor = 'ATX';
      } else if (description.contains('micro-atx') || description.contains('matx')) {
        formFactor = 'Micro-ATX';
      } else if (description.contains('mini-itx') || description.contains('itx')) {
        formFactor = 'Mini-ITX';
      }
    }
    
    // Add socket type if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Socket')) && 
        socketType.isNotEmpty) {
      moboInfo.add(_buildSpecItem('Socket', socketType));
    }
    
    // Add chipset if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Chipset')) &&
        chipset.isNotEmpty) {
      moboInfo.add(_buildSpecItem('Chipset', chipset));
    }
    
    // Add form factor if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Form factor')) &&
        formFactor.isNotEmpty) {
      moboInfo.add(_buildSpecItem('Form factor', formFactor));
    }
    
    return moboInfo;
  }
  
  // Special handling for RAM products
  List<Widget> _buildRamSpecificInfo() {
    // Extract RAM-specific info
    final description = product.description.toLowerCase();
    final name = product.name.toLowerCase();
    final List<Widget> ramInfo = [];
    
    // Try to identify RAM type
    String ramType = '';
    if (product.specifications != null && product.specifications!['Loại RAM'] != null) {
      ramType = product.specifications!['Loại RAM'].toString();
    } else {
      if (description.contains('ddr5') || name.contains('ddr5')) ramType = 'DDR5';
      else if (description.contains('ddr4') || name.contains('ddr4')) ramType = 'DDR4';
      else if (description.contains('ddr3') || name.contains('ddr3')) ramType = 'DDR3';
    }
    
    // Try to identify capacity
    String capacity = '';
    if (product.specifications != null && product.specifications!['Dung lượng'] != null) {
      capacity = product.specifications!['Dung lượng'].toString();
    } else {
      final capacityRegex = RegExp(r'(\d+)(?:\s*gb|\s*tb)', caseSensitive: false);
      final capacityMatch = capacityRegex.firstMatch(name) ?? 
                           capacityRegex.firstMatch(description);
      
      if (capacityMatch != null) {
        capacity = '${capacityMatch.group(1)}GB';
      }
    }
    
    // Add memory type if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Loại RAM')) &&
        ramType.isNotEmpty) {
      ramInfo.add(_buildSpecItem('Loại RAM', ramType));
    }
    
    // Add capacity if not already in specs and not empty
    if (!(product.specifications != null && product.specifications!.containsKey('Dung lượng')) &&
        capacity.isNotEmpty) {
      ramInfo.add(_buildSpecItem('Dung lượng', capacity));
    }
    
    return ramInfo;
  }
  
  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}