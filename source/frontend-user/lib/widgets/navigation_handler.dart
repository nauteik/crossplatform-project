import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/navigation/providers/navigation_provider.dart';

/// Wrapper để xử lý việc quay lại màn hình trước đó
class NavigationHandler extends StatelessWidget {
  final Widget child;

  const NavigationHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final NavigationProvider navigationProvider = 
            Provider.of<NavigationProvider>(context, listen: false);
        
        // Nếu đã quay lại được màn hình trước đó, trả về false để không đóng ứng dụng
        if (navigationProvider.goBack()) {
          return false;
        }
        
        // Nếu không còn màn hình nào để quay lại, hiển thị hộp thoại xác nhận thoát
        bool shouldExit = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thoát ứng dụng'),
            content: const Text('Bạn có chắc chắn muốn thoát khỏi ứng dụng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Thoát', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ?? false;
        
        return shouldExit;
      },
      child: child,
    );
  }
} 