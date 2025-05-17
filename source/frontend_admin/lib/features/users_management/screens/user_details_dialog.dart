import 'package:flutter/material.dart';
import 'package:frontend_admin/models/user_model.dart';

class UserDetailsDialog extends StatelessWidget {
  final User user;

  const UserDetailsDialog({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final birthdayFormatted = user.birthdayString;
    final createdAtFormatted = user.createdAtString;

    return AlertDialog(
      title: const Text('Chi tiết người dùng'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Hiển thị Avatar
             Center(
               child: CircleAvatar(
                  radius: 50,
                   backgroundColor: Colors.grey[300],
                   backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                       ? NetworkImage(user.avatar!) // Sử dụng NetworkImage
                       : null,
                   child: (user.avatar == null || user.avatar!.isEmpty)
                       ? Icon(Icons.account_circle, size: 50, color: Colors.grey[700])
                       : null,
               ),
             ),
             const SizedBox(height: 16),
             // Hiển thị các thông tin chi tiết dựa trên model mới
             _buildDetailRow('ID:', user.id),
             _buildDetailRow('Tên:', user.name),
             _buildDetailRow('Email:', user.email),
             _buildDetailRow('Username:', user.username ?? 'Chưa cập nhật'),
             _buildDetailRow('SĐT:', user.phone ?? 'Chưa cập nhật'),
             _buildDetailRow('Giới tính:', user.gender ?? 'Chưa cập nhật'),
             _buildDetailRow('Ngày sinh:', birthdayFormatted),
             _buildDetailRow('Ngày tạo:', createdAtFormatted),
             _buildDetailRow('Rank:', user.rank ?? 'Chưa cập nhật'),
             _buildDetailRow('Total Spend:', '${user.totalSpend ?? 0}'),
             _buildDetailRow('Loyalty Points:', '${user.loyaltyPoints ?? 0}'),
             _buildDetailRow('Vai trò:', user.roleString),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Đóng dialog
          },
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  // Hàm xây dựng một dòng chi tiết
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}