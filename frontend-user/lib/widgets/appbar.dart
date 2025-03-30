// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io' show Platform;
// import 'package:flutter/foundation.dart' show kIsWeb;
// import '../features/navigation/providers/navigation_provider.dart';
// import '../features/auth/presentation/screens/login_screen.dart';
// import '../features/build_pc/presentation/screens/build_configuration_screen.dart';
// import '../features/support/presentation/screens/support_screen.dart';
// import '../features/cart/presentation/screens/cart_screen.dart';
// import 'popup_menu_account.dart';

// class ActionSection extends StatefulWidget {
//   final bool isMobile;
//   const ActionSection({
//     super.key,
//     this.isMobile = false,
//   });

//   @override
//   State<ActionSection> createState() => _ActionSectionState();
// }

// class _ActionSectionState extends State<ActionSection> {
//   static final ThemeData _theme = ThemeData(
//     iconTheme: const IconThemeData(
//       color: Colors.white,
//       size: 20,
//     ),
//     textTheme: const TextTheme(
//       bodySmall: TextStyle(
//         color: Colors.white,
//         fontSize: 12,
//       ),
//     ),
//   );

//   bool _isLoggedIn = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkLoginStatus();
//   }

//   @override
//   void didUpdateWidget(ActionSection oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     _checkLoginStatus();
//   }

//   // This runs after each build to check if login state changed
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _checkLoginStatus();
//   }

//   Future<void> _checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('jwt_token');

//     print(
//         "Checking login status: token = ${token != null ? 'exists' : 'null'}");

//     if ((token != null) != _isLoggedIn) {
//       print("Login state changed: ${_isLoggedIn} -> ${token != null}");
//       setState(() {
//         _isLoggedIn = token != null;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
//     if (widget.isMobile) {
//       return Theme(
//         data: _theme,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.shopping_cart),
//               onPressed: () {
//                 navigationProvider.setCurrentScreen(const CartScreen());
//               },
//             ),
//             _isLoggedIn
//               ? IconButton(
//                   icon: const Icon(Icons.account_circle),
//                   onPressed: () {
//                     showMenu(
//                       context: context,
//                       position: RelativeRect.fromLTRB(
//                         0, 
//                         kToolbarHeight, 
//                         0, 
//                         0
//                       ),
//                       items: [
//                         PopupMenuItem(
//                           value: 'profile',
//                           child: const Text('Thông tin cá nhân'),
//                         ),
//                         PopupMenuItem(
//                           value: 'logout',
//                           child: const Text('Đăng xuất'),
//                         ),
//                       ],
//                     );
//                   },
//                 )
//               : IconButton(
//                   icon: const Icon(Icons.login),
//                   onPressed: () {
//                     navigationProvider.setCurrentScreen(const LoginScreen());
//                   },
//                 ),
//           ],
//         ),
//       );
//     }
    
//     return Theme(
//       data: _theme,
//       child: Row(
//         children: [
//           SizedBox(
//             width: 110,
//             child: InkWell(
//               onTap: () {
//                 print("Nút xây dựng cấu hình được nhấn"); // Debug print
//                 navigationProvider.setCurrentScreen(const BuildConfigurationScreen());
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const FaIcon(FontAwesomeIcons.screwdriverWrench),
//                   Text(
//                     "Xây dựng cấu hình",
//                     style: _theme.textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 110,
//             child: InkWell(
//               onTap: () {
//                 print("Nút hỗ trợ được nhấn"); // Debug print
//                 navigationProvider.setCurrentScreen(const SupportScreen());
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.phone),
//                   Text(
//                     "Hỗ trợ",
//                     style: _theme.textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 110,
//             child: InkWell(
//               onTap: () {
//                 print("Nút giỏ hàng được nhấn"); // Debug print
//                 navigationProvider.setCurrentScreen(const CartScreen());
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.shopping_cart),
//                   Text(
//                     "Giỏ hàng",
//                     style: _theme.textTheme.bodySmall,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           SizedBox(
//             width: 110,
//             child: _isLoggedIn
//                 ? const PopupMenuAccount()
//                 : InkWell(
//                     onTap: () {
//                       print("Nút đăng nhập trong ActionButton được nhấn"); // Debug print
//                       navigationProvider.setCurrentScreen(const LoginScreen());
//                     },
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.login),
//                         Text(
//                           "Đăng nhập",
//                           style: _theme.textTheme.bodySmall,
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class NavBar extends StatelessWidget {
//   const NavBar({super.key});

//   List<Widget>? _buildActions(BuildContext context) {
//     final isMobile = !(kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    
//     if (!isMobile) {
//       return [
//         const ActionSection(),
//         const SizedBox(width: 100),
//       ];
//     }
//     return null;
//   }

//   Widget _platformSpecificSizedBox(double width) {
//     if (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
//       return SizedBox(width: width);
//     }
//     return const SizedBox(width: 0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isMobile = !(kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    
//     return AppBar(
//       backgroundColor: Colors.blue,
//       title: Column(
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _platformSpecificSizedBox(20),
//               Expanded(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxWidth: isMobile 
//                         ? screenWidth * 0.6
//                         : 500,
//                   ),
//                   child: SizedBox(
//                     height: 40,
//                     child: TextField(
//                       decoration: InputDecoration(
//                         hintText: 'Tìm kiếm...',
//                         filled: true,
//                         fillColor: Colors.white,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           borderSide: BorderSide.none,
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           borderSide: BorderSide(color: Colors.blue, width: 2.0),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 10),
//                         prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               _platformSpecificSizedBox(10)
//             ],
//           ),
//         ],
//       ),
//       actions: isMobile
//           ? [
//               ActionSection(isMobile: true),
//             ]
//           : _buildActions(context),
//       centerTitle: isMobile,
//     );
//   }
// } 