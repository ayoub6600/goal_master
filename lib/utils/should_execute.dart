// // ignore_for_file: use_build_context_synchronously

// import 'package:avc_client/core/components/bottom_sheet/show_login_required_bottom_sheet.dart';
// import 'package:avc_client/core/utils/auth_manager.dart';
// import 'package:avc_client/features/book_appointment/views/widgets/choose_patient_modal.dart';
// import 'package:flutter/material.dart';

// Future<bool> shouldExecute({
//   required BuildContext context,
//   required VoidCallback callback,
//   bool checkLogged = true,
//   bool checkSelectedPatient = true,
// }) async {
//   var user = await AuthManager.getUser();
//   if (user == null && checkLogged) {
//     showLoginRequiredBottomSheet(context);
//     return false;
//   }
//   var selectedPatient = user?.selectedPatient;
//   if (selectedPatient == null && checkSelectedPatient) {
//     choosePatientDialog(context);
//     return false;
//   }
//   callback();
//   return true;
// }
