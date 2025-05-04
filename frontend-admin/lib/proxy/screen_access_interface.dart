import 'package:flutter/material.dart';

// RealScreenAccess and ProxyScreenAccess will implement
abstract class ScreenAccessInterface {
  Widget getScreen(int index, BuildContext context);
}
