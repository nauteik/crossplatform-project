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