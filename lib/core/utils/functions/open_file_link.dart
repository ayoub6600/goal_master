import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

void openFileLink(BuildContext context, String fileUrl) async {
  final uri = Uri.parse(fileUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    //showCustomFailureToast('Failed to open file');
  }
}
