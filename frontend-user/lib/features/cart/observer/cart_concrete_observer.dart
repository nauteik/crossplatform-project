import 'package:frontend_user/data/model/cart_item_model.dart';
import 'package:frontend_user/features/cart/observer/cart_observer.dart';

class CartBadgeObserver implements CartObserver {
  final Function(int) updateBadgeCount;

  CartBadgeObserver(this.updateBadgeCount);

  @override
  void update(List<CartItemModel> items) {
    updateBadgeCount(items.length);
  }
}

// filepath: lib/features/cart/observers/cart_total_observer.dart
class CartTotalObserver implements CartObserver {
  final Function(double) onTotalChanged;

  CartTotalObserver(this.onTotalChanged);

  @override
  void update(List<CartItemModel> items) {
    double total = 0.0;
    for (var item in items) {
      total += item.price * item.quantity;
    }
    onTotalChanged(total);
  }
}