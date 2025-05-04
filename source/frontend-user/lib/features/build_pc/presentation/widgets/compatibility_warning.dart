import 'package:flutter/material.dart';
import 'package:frontend_user/features/build_pc/models/pc_model.dart';

class CompatibilityWarning extends StatelessWidget {
  final PCModel? pcBuild;
  final bool checkCpuMotherboard;
  
  const CompatibilityWarning({
    Key? key,
    required this.pcBuild,
    this.checkCpuMotherboard = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pcBuild == null) {
      return const SizedBox();
    }
    
    // Check for any compatibility issues
    final List<String> issues = pcBuild!.getAllCompatibilityIssues();
    
    // If no issues and we're not specifically checking CPU+Motherboard, return empty widget
    if (issues.isEmpty && !checkCpuMotherboard) {
      return const SizedBox();
    }
    
    // Special case for socket compatibility
    if (checkCpuMotherboard && 
        pcBuild!.cpu != null && 
        pcBuild!.motherboard != null) {
      
      // Check for socket compatibility issues
      if (pcBuild!.hasSocketCompatibilityIssue()) {
        return _buildWarningCard(
          context,
          'Socket Incompatibility',
          pcBuild!.getSocketCompatibilityMessage() ?? 
              'CPU socket is not compatible with motherboard socket.',
          Icons.warning,
          Colors.red.shade100,
          Colors.red,
        );
      }
      
      // Check for socket compatibility warnings
      if (pcBuild!.hasSocketCompatibilityWarning()) {
        return _buildWarningCard(
          context,
          'Socket Compatibility Warning',
          'Unable to verify CPU and motherboard socket compatibility. Please verify manually.',
          Icons.info_outline,
          Colors.amber.shade100,
          Colors.amber,
        );
      }
      
      // If no socket issues, show compatibility check passed
      return _buildWarningCard(
        context,
        'Socket Compatibility',
        'CPU and motherboard sockets are compatible.',
        Icons.check_circle_outline,
        Colors.green.shade100,
        Colors.green,
      );
    }
    
    // If we have other compatibility issues
    if (issues.isNotEmpty) {
      return _buildWarningCard(
        context,
        'Compatibility Issues',
        'There are ${issues.length} compatibility issues with your build. Please review and adjust components.',
        Icons.error_outline,
        Colors.red.shade100,
        Colors.red,
      );
    }
    
    // Default empty widget
    return const SizedBox();
  }
  
  Widget _buildWarningCard(
    BuildContext context,
    String title,
    String message,
    IconData icon,
    Color backgroundColor,
    Color iconColor,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: backgroundColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: iconColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}