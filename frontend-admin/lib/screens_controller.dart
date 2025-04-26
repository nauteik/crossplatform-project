import 'package:admin_interface/proxy/proxy_screen_access.dart';
import 'package:admin_interface/proxy/screen_access_interface.dart';
import 'package:flutter/material.dart';

// Using the Proxy pattern for access control
final ScreenAccessInterface _screenAccess = ProxyScreenAccess();

Widget navigateToScreen(int index, BuildContext context) {
  return _screenAccess.getScreen(index, context);
}
