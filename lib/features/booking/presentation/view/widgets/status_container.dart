import 'package:flutter/material.dart';

class StatusContainer extends StatelessWidget {
  final int status;

  const StatusContainer({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color containerColor;
    String statusText;

    switch (status) {
      case 0:
        containerColor = Colors.orange; // Pending
        statusText = "غير خالص";
        break;
      case 1:
        containerColor = Colors.blue; // Processing
        statusText = "في إنتظار قبول الطلب";
        break;
      case 2:
        containerColor = Colors.green; // Approved
        statusText = "مقبول";
        break;
      case 3:
        containerColor = Colors.red; // Cancel
        statusText = "ملغي";
        break;
      case 4:
        containerColor = Colors.grey; // Done
        statusText = "خالص";
        break;
      default:
        containerColor = Colors.black; // Default color
        statusText = "غير محدد";
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          statusText,
          // "في إنتظار قبول الطلب",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
