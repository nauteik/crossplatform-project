// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../features/navigation/providers/navigation_provider.dart';
// import '../features/product/presentation/screens/categories/pc_gaming_screen.dart';
// import '../features/product/presentation/screens/categories/pc_office_screen.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class DropDownMenu extends StatefulWidget {
//   const DropDownMenu({super.key});

//   @override
//   State<DropDownMenu> createState() => _DropDownMenuState();
// }

// class _DropDownMenuState extends State<DropDownMenu> {
//   String? _selectedValue;
//   static final List<Map<String, dynamic>> _items = [
//     {
//       'value': 'PC GAMING',
//       'leadingIcon': FaIcon(FontAwesomeIcons.gamepad),
//       'screen': PCGamingScreen(),
//     },
//     {
//       'value': 'PC VĂN PHÒNG',
//       'leadingIcon': FaIcon(FontAwesomeIcons.computer),
//       'screen': PCOfficeScreen(),
//     },
//     {
//       'value': 'PC ĐỒ HỌA',
//       'leadingIcon': FaIcon(FontAwesomeIcons.unity),
//       'screen': Text('PC Đồ Họa'),
//     },
//     {
//       'value': 'MÀN HÌNH MÁY TÍNH',
//       'leadingIcon': FaIcon(FontAwesomeIcons.display),
//       'screen': Text('Màn Hình Máy Tính'),
//     },
//     {
//       'value': 'CHUỘT MÁY TÍNH',
//       'leadingIcon': FaIcon(FontAwesomeIcons.computerMouse),
//       'screen': Text('Chuột Máy Tính'),
//     },
//     {
//       'value': 'BÀN PHÍM MÁY TÍNH',
//       'leadingIcon': FaIcon(FontAwesomeIcons.keyboard),
//       'screen': Text('Bàn Phím Máy Tính'),
//     },
//     {
//       'value': 'THIẾT BỊ LƯU TRỮ',
//       'leadingIcon': FaIcon(FontAwesomeIcons.hardDrive),
//       'screen': Text('Thiết Bị Lưu Trữ'),
//     },
//     {
//       'value': 'LINH KIỆN MÁY TÍNH',
//       'leadingIcon': FaIcon(FontAwesomeIcons.microchip),
//       'screen': Text('Linh Kiện Máy Tính'),
//     },
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
    
//     return Stack(
//       children: [
//         Container(
//           height: 40,
//           width: 235,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: Colors.grey.shade300),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           child: DropdownButton<String>(
//             value: _selectedValue,
//             icon: const Icon(
//               Icons.keyboard_arrow_down,
//               color: Colors.blue,
//             ),
//             iconSize: 26,
//             isExpanded: true,
//             hint: Row(
//               children: [
//                 Icon(
//                   Icons.menu,
//                   color: Colors.blue,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 10),
//                 const Text(
//                   'DANH MỤC SẢN PHẨM',
//                   style: TextStyle(
//                     color: Colors.blue,
//                     fontSize: 14,
//                     fontWeight: FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//             style: const TextStyle(
//               color: Colors.black87,
//               fontSize: 14,
//               fontWeight: FontWeight.normal,
//             ),
//             underline: const SizedBox(),
//             borderRadius: BorderRadius.circular(8),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedValue = newValue;
//               });
//               if (newValue != null) {
//                 final selectedItem = _items.firstWhere(
//                   (item) => item['value'] == newValue,
//                   orElse: () => _items[0],
//                 );
//                 navigationProvider.setCurrentScreen(selectedItem['screen']);
//                 FocusScope.of(context).requestFocus(FocusNode());
//               }
//             },
//             items: _items
//                 .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
//               return DropdownMenuItem<String>(
//                 value: item['value'],
//                 child: Row(
//                   children: [
//                     Icon(
//                       item['leadingIcon'].icon,
//                       color: Colors.blue,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 10),
//                     Text(
//                       item['value'],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
// }
