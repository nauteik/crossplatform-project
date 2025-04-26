import 'package:flutter/material.dart';

// The interface that both the RealScreenAccess and ProxyScreenAccess will implement
abstract class ScreenAccessInterface {
  Widget getScreen(int index, BuildContext context);
}
