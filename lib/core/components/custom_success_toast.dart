import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import '../styles/app_colors.dart';

class CustomSuccessToast extends StatelessWidget {
  const CustomSuccessToast({super.key, required this.toastText});

  final String toastText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
      decoration: BoxDecoration(
        color: AppColors.successGreen,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, -2),
            // ignore: deprecated_member_use
            color: const Color(0xFF000000).withOpacity(.12),
            spreadRadius: 0,
          ),
          BoxShadow(
            blurRadius: 5,
            offset: const Offset(0, -2),
            color: const Color(0xFF000000).withOpacity(.16),
            spreadRadius: 0,
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: DefaultTextStyle(
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                child: Text(
                  toastText,
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showCustomSuccessToast(String toastText) {
  showToastWidget(
    CustomSuccessToast(toastText: toastText),
    dismissOtherToast: true,
    handleTouch: true,
    position: ToastPosition.top,
    duration: const Duration(seconds: 3),
  );
}
