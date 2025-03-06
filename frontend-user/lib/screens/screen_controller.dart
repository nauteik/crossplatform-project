import 'landing_page.dart';
import 'package:flutter/material.dart';
import 'product_page/pc_gaming_page.dart';
import 'product_page/pc_office_page.dart';
import 'product_page/pc_graphics_page.dart';
import 'product_page/monitor_page.dart';
import 'product_page/keyboard_page.dart';
import 'product_page/mouse_page.dart';
import 'product_page/storage_page.dart';
import 'action_button_page/cart_page.dart';
import 'action_button_page/build_configuration_page.dart';
import 'action_button_page/support_page.dart';
import 'product_page/pc_component_page.dart';
import 'account_manager_page/order_page.dart';
import 'account_manager_page/profile_page.dart';
import 'account_manager_page/wishlist_page.dart';
import 'account_manager_page/setting_page.dart';

class ScreenController {
  static Widget _page = LandingPage();

  static void setPageBody(String value) {
    switch (value) {
      case 'PC GAMING':
        _page = PCGamingPage();
        break;
      case 'PC VĂN PHÒNG':
        _page = PCOfficePage();
        break;
      case 'PC ĐỒ HỌA':
        _page = PCGraphicsPage();
        break;
      case 'MÀN HÌNH MÁY TÍNH':
        _page = MonitorPage();
        break;
      case 'CHUỘT MÁY TÍNH':
        _page = MousePage();
        break;
      case 'BÀN PHÍM MÁY TÍNH':
        _page = KeyboardPage();
        break;
      case 'THIẾT BỊ LƯU TRỮ':
        _page = StoragePage();
        break;
      case 'LINH KIỆN MÁY TÍNH':
        _page = PCComponentPage();
        break;
      case 'Xây dựng cấu hình':
        _page = BuildConfigurationPage();
        break;
      case 'Hỗ trợ':
        _page = SupportPage();
        break;
      case 'Giỏ hàng':
        _page = CartPage();
        break;
      case 'PROFILE':
        _page = ProfilePage();
        break;
      case 'ORDERS':
        _page = OrderPage();
        break;
      case 'WISHLIST':
        _page = WishlistPage();
        break;
      case 'SETTINGS':
        _page = SettingPage();
        break;
      default:
        _page = LandingPage();
        break;
    }
  }

  static Widget getPage() {
    return _page;
  }
}
