import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';

class CustomDropdown<T> extends StatelessWidget {
  final List<T> items;

  final T? value;
  final ValueChanged<T?> onChanged;
  final String hint;

  const CustomDropdown({
    super.key,
    required this.items,
    this.value,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   label,
        //   style: const TextStyle(
        //     color: Color(0xFF242424),
        //     fontSize: 16,
        //     fontFamily: 'Inter',
        //     fontWeight: FontWeight.w500,
        //     height: 0,
        //   ),
        // ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0), // Rounded corners
            boxShadow: const [
              BoxShadow(
                color: Color(0x07000000),
                blurRadius: 24,
                offset: Offset(0, 3),
                spreadRadius: 0,
              )
            ],
          ),
          child: DropdownButtonFormField<T>(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
            value: value,
            onChanged: onChanged,
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: AppColors.fontColor,
            ),
            hint: Text(
              hint,
              style: TextStyle(
                color: Color(0xFF797979),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  item.toString(),
                  style: TextStyle(color: AppColors.primary),
                ),
              );
            }).toList(),
            menuMaxHeight: 300.h,
          ),
        ),
      ],
    );
  }
}
