import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend_user/core/utils/format_currency.dart';
import 'package:frontend_user/features/build_pc/models/pc_model.dart';
import 'package:frontend_user/features/build_pc/providers/pc_provider.dart';
import 'package:frontend_user/features/auth/providers/auth_provider.dart';
import 'package:frontend_user/core/utils/navigation_helper.dart';

class SavedBuildsScreen extends StatefulWidget {
  const SavedBuildsScreen({Key? key}) : super(key: key);

  @override
  State<SavedBuildsScreen> createState() => _SavedBuildsScreenState();
}

class _SavedBuildsScreenState extends State<SavedBuildsScreen> {
  // Track which builds are currently adding to cart
  final Map<String, bool> _addingToCartMap = {};
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserBuilds();
    });
  }

  Future<void> _loadUserBuilds() async {
    final pcProvider = Provider.of<PCProvider>(context, listen: false);
    await pcProvider.loadUserBuilds();
  }
  
  // New method to handle adding PC components to cart
  Future<void> _addComponentsToCart(String pcId) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pcProvider = Provider.of<PCProvider>(context, listen: false);
    
    // Check if user is authenticated
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add items to your cart'))
      );
      NavigationHelper.navigateToLogin(context);
      return;
    }
    
    // Set the specific build as loading
    setState(() {
      _addingToCartMap[pcId] = true;
    });
    
    try {
      final String? userId = authProvider.userId;
      
      if (userId == null) {
        throw Exception('User ID not found');
      }
      
      final result = await pcProvider.addPCComponentsToCart(pcId, userId);
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All components added to cart successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${pcProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding components to cart: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _addingToCartMap[pcId] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pcProvider = Provider.of<PCProvider>(context);
    final userBuilds = pcProvider.userBuilds;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My PC Builds'),
      ),
      body: pcProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userBuilds.isEmpty
              ? _buildEmptyState()
              : _buildBuildsList(userBuilds, pcProvider),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.computer,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'No PC builds yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start building your custom PC now!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/build_pc');
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Build'),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildsList(List<PCModel> builds, PCProvider provider) {
    return RefreshIndicator(
      onRefresh: _loadUserBuilds,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: builds.length,
        itemBuilder: (context, index) {
          final build = builds[index];
          // Check if this build is currently being added to cart
          final bool isAddingToCart = _addingToCartMap[build.id ?? ''] ?? false;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          build.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getBuildStatusColor(build.buildStatus),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getBuildStatusText(build.buildStatus),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Show components
                  _buildComponentItem(
                    'CPU',
                    build.cpu?.name ?? 'Not selected', 
                    Icons.memory,
                    build.cpu?.price ?? 0,
                  ),
                  
                  _buildComponentItem(
                    'Motherboard',
                    build.motherboard?.name ?? 'Not selected',
                    Icons.dashboard,
                    build.motherboard?.price ?? 0,
                  ),
                  
                  _buildComponentItem(
                    'Graphics Card',
                    build.gpu?.name ?? 'Not selected',
                    Icons.videogame_asset,
                    build.gpu?.price ?? 0,
                  ),
                  
                  _buildComponentItem(
                    'RAM',
                    build.ram?.name ?? 'Not selected',
                    Icons.memory_outlined,
                    build.ram?.price ?? 0,
                  ),
                  
                  // Show more components button if needed
                  if (build.storage != null || build.powerSupply != null || 
                      build.pcCase != null || build.cooling != null)
                    ExpansionTile(
                      title: const Text('Show more components'),
                      tilePadding: EdgeInsets.zero,
                      children: [
                        if (build.storage != null)
                          _buildComponentItem(
                            'Storage',
                            build.storage!.name,
                            Icons.storage,
                            build.storage!.price,
                          ),
                          
                        if (build.powerSupply != null)
                          _buildComponentItem(
                            'Power Supply',
                            build.powerSupply!.name,
                            Icons.electrical_services,
                            build.powerSupply!.price,
                          ),
                          
                        if (build.pcCase != null)
                          _buildComponentItem(
                            'Case',
                            build.pcCase!.name,
                            Icons.cases,
                            build.pcCase!.price,
                          ),
                          
                        if (build.cooling != null)
                          _buildComponentItem(
                            'Cooling',
                            build.cooling!.name,
                            Icons.ac_unit,
                            build.cooling!.price,
                          ),
                      ],
                    ),
                  
                  const Divider(height: 24),
                  
                  // Compatibility notes
                  if (build.compatibilityNotes.isNotEmpty) ...[
                    const Text(
                      'Compatibility Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...build.compatibilityNotes.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 8),
                  ],
                  
                  // Total price
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatCurrency(build.totalPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isAddingToCart || build.id == null
                              ? null // Disable when already adding to cart or no build ID
                              : () => _addComponentsToCart(build.id!),
                          icon: isAddingToCart 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.shopping_cart),
                          label: Text(isAddingToCart ? 'Adding...' : 'Add to Cart'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isAddingToCart
                              ? null // Disable delete while adding to cart
                              : () {
                                  // Show delete confirmation
                                  _showDeleteConfirmation(context, build.id!, provider);
                                },
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Delete Build'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComponentItem(String label, String value, IconData icon, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (price > 0)
            Text(
              formatCurrency(price),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Color _getBuildStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'compatible':
        return Colors.green;
      case 'incompatible':
        return Colors.red;
      case 'incomplete':
        return Colors.orange;
      case 'updated_pending_validation':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getBuildStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'compatible':
        return 'Compatible';
      case 'incompatible':
        return 'Incompatible';
      case 'incomplete':
        return 'Incomplete';
      case 'updated_pending_validation':
        return 'Needs Validation';
      default:
        return 'Unknown';
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String pcId, PCProvider provider) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete PC Build'),
        content: const Text('Are you sure you want to delete this PC build? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deletePCBuild(pcId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}