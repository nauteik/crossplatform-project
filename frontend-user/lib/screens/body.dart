import 'package:flutter/material.dart';
import '../widgets/sell_item.dart';

class Body {
  static Widget landingPageBody() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(left: 100, right: 100),
        decoration: BoxDecoration(
          color: Colors.grey,
        ),
        child: ListView(
          children: const [
            SellItem(
              name: 'Laptop Asus A15',
              price: 20000000,
              soldCount: 150,
              discountPercent: 10,
              imageUrl: '../../assets/bag_1.png',
            ),
          ],
        ),
      ),
    );
  }
}