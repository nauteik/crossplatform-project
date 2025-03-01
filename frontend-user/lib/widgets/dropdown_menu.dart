import 'package:flutter/material.dart';
import '../screens/screen_controller.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DropDownMenu extends StatefulWidget {
  final Function(Widget) onPageChange;
  const DropDownMenu({super.key, required this.onPageChange});

  @override
  State<DropDownMenu> createState() => _DropDownMenuState();
}

class _DropDownMenuState extends State<DropDownMenu> {
  String? _selectedValue;
  static final List<Map<String, dynamic>> _items = [
    {
      'value': 'PC GAMING',
      'leadingIcon': FaIcon(FontAwesomeIcons.gamepad),
    },
    {
      'value': 'PC VĂN PHÒNG',
      'leadingIcon': FaIcon(FontAwesomeIcons.computer),
    },
    {
      'value': 'PC ĐỒ HỌA',
      'leadingIcon': FaIcon(FontAwesomeIcons.unity),
    },
    {
      'value': 'MÀN HÌNH MÁY TÍNH',
      'leadingIcon': FaIcon(FontAwesomeIcons.display),
    },
    {
      'value': 'CHUỘT MÁY TÍNH',
      'leadingIcon': FaIcon(FontAwesomeIcons.computerMouse),
    },
    {
      'value': 'BÀN PHÍM MÁY TÍNH',
      'leadingIcon': FaIcon(FontAwesomeIcons.keyboard),
    },
    {
      'value': 'THIẾT BỊ LƯU TRỮ',
      'leadingIcon': FaIcon(FontAwesomeIcons.hardDrive),
    },
    {
      'value': 'LINH KIỆN MÁY TÍNH',
      'leadingIcon': FaIcon(FontAwesomeIcons.microchip),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 40,
          width: 235,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<String>(
            value: _selectedValue,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.blue,
            ),
            iconSize: 26,
            isExpanded: true,
            hint: Row(
              children: [
                Icon(
                  Icons.menu,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                const Text(
                  'DANH MỤC SẢN PHẨM',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(8),
            onChanged: (String? newValue) {
              setState(() {
                _selectedValue = newValue;
              });
              if (newValue != null) {
                ScreenController.setPageBody(newValue);
                widget.onPageChange(ScreenController.getPage());
                FocusScope.of(context).requestFocus(FocusNode());
              }
            },
            items: _items
                .map<DropdownMenuItem<String>>((Map<String, dynamic> item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Row(
                  children: [
                    Icon(
                      item['leadingIcon'].icon,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      item['value'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
