import 'package:flutter/material.dart';
import '../screens/home_page.dart';

class LeadingButton extends StatelessWidget {
  const LeadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (BuildContext context) => HomePage()),
        );
      },
      borderRadius: BorderRadius.circular(50), // Bo góc để hiệu ứng đúng
      child: CircleAvatar(
        backgroundImage: NetworkImage(
            "https://images.squarespace-cdn.com/content/v1/5930dc9237c5817c00b10842/1557979868721-ZFEVPV8NS06PZ21ZC174/images.png"),
        radius: 30,
      ),
    );
  }
}
