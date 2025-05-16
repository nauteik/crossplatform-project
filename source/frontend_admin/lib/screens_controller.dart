import 'package:flutter/material.dart';
import 'package:frontend_admin/proxy/proxy_screen_access.dart';
import 'package:frontend_admin/proxy/screen_access_interface.dart';

// Using the Proxy pattern for access control
final ScreenAccessInterface _screenAccess = ProxyScreenAccess();

Widget navigateToScreen(int index, BuildContext context) {
  return _screenAccess.getScreen(index, context);
}
