import 'package:frontend_user/data/model/product_model.dart';

class PCModel {
  final String? id;
  final String name;
  final String userId;
  final double totalPrice;
  final ProductModel? cpu;
  final ProductModel? motherboard;
  final ProductModel? gpu;
  final ProductModel? ram;
  final ProductModel? storage;
  final ProductModel? powerSupply;
  final ProductModel? pcCase;
  final ProductModel? cooling;
  final Map<String, String> compatibilityNotes;
  final bool isComplete;
  final String buildStatus; // "compatible", "incompatible", "incomplete"

  PCModel({
    this.id,
    required this.name,
    required this.userId,
    required this.totalPrice,
    this.cpu,
    this.motherboard,
    this.gpu,
    this.ram,
    this.storage,
    this.powerSupply,
    this.pcCase,
    this.cooling,
    required this.compatibilityNotes,
    required this.isComplete,
    required this.buildStatus,
  });

  factory PCModel.fromJson(Map<String, dynamic> json) {
    return PCModel(
      id: json['id'],
      name: json['name'] ?? 'Custom PC',
      userId: json['userId'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      cpu: json['cpu'] != null ? ProductModel.fromJson(json['cpu']) : null,
      motherboard: json['motherboard'] != null ? ProductModel.fromJson(json['motherboard']) : null,
      gpu: json['gpu'] != null ? ProductModel.fromJson(json['gpu']) : null,
      ram: json['ram'] != null ? ProductModel.fromJson(json['ram']) : null,
      storage: json['storage'] != null ? ProductModel.fromJson(json['storage']) : null,
      powerSupply: json['powerSupply'] != null ? ProductModel.fromJson(json['powerSupply']) : null,
      pcCase: json['pcCase'] != null ? ProductModel.fromJson(json['pcCase']) : null,
      cooling: json['cooling'] != null ? ProductModel.fromJson(json['cooling']) : null,
      compatibilityNotes: (json['compatibilityNotes'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, value.toString()),
      ) ?? {},
      isComplete: json['isComplete'] ?? false,
      buildStatus: json['buildStatus'] ?? 'incomplete',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userId': userId,
      'components': {
        if (cpu != null) 'cpu': cpu!.id,
        if (motherboard != null) 'motherboard': motherboard!.id,
        if (gpu != null) 'gpu': gpu!.id,
        if (ram != null) 'ram': ram!.id,
        if (storage != null) 'storage': storage!.id,
        if (powerSupply != null) 'powerSupply': powerSupply!.id,
        if (pcCase != null) 'pcCase': pcCase!.id,
        if (cooling != null) 'cooling': cooling!.id,
      }
    };
  }

  // Helper method to check for socket compatibility issues
  bool hasSocketCompatibilityIssue() {
    return compatibilityNotes.containsKey('cpu_motherboard');
  }

  // Get socket compatibility message
  String? getSocketCompatibilityMessage() {
    return compatibilityNotes['cpu_motherboard'];
  }

  // Check if there's a socket compatibility warning
  bool hasSocketCompatibilityWarning() {
    return compatibilityNotes.containsKey('cpu_motherboard_warning');
  }

  // Get all compatibility issues
  List<String> getAllCompatibilityIssues() {
    return compatibilityNotes.values.toList();
  }
}