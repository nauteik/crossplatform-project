import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'home_page/home_page_desktop.dart';
import 'home_page/home_page_mobile.dart';
import 'home_page/home_page_web.dart';

enum ScreenType {
  mobile,
  desktop,
  web
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key});

  static ScreenType getScreenType(BuildContext context) {
     if (kIsWeb) {
      return ScreenType.web;
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      return ScreenType.desktop;
    }
    return ScreenType.mobile;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        ScreenType screenType = getScreenType(context);
        
        switch (screenType) {
          case ScreenType.mobile:
            return HomePageMobile();
          case ScreenType.web:
            return HomePageWeb();
          case ScreenType.desktop:
            return HomePageDesktop();
        }
      },
    );
  }
}