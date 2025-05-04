import 'package:frontend_user/features/cart/observer/cart_observer.dart';

abstract class CartSubject {
  void attach(CartObserver observer);
  void detach(CartObserver observer);
  void notify();
}