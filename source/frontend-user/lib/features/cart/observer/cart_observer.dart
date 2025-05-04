import 'package:frontend_user/data/model/cart_item_model.dart';

abstract class CartObserver {
  void update(List<CartItemModel> items);
}