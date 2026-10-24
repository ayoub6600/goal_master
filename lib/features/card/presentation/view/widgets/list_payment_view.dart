import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/button_app_two.dart';
import 'package:goal_master/core/components/page_wrapper.dart';

import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet.dart';
import 'package:goal_master/features/card/presentation/view/widgets/top_up_sheet_visa.dart';

class ListPaymentView extends StatefulWidget {
  const ListPaymentView({super.key, this.embedded = false, this.onUpdated});

  final bool embedded;
  final VoidCallback? onUpdated;

  @override
  State<ListPaymentView> createState() => _ListPaymentViewState();
}

class _ListPaymentViewState extends State<ListPaymentView> {
  int? _selectedMethod;

  void _completed() {
    widget.onUpdated?.call();
    if (!widget.embedded && Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _selectedMethod = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.all(widget.embedded ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedMethod == null) ...[
            HeightSpace(8.h),
            ButtonAppTwo(
              assetIcon: Assets.creditCards,
              text: 'البطاقة المصرفية (اونلاين)',
              onTap: () => setState(() => _selectedMethod = 1),
            ),
            HeightSpace(12.h),
            ButtonAppTwo(
              text: 'شحن بالكرت',
              assetIcon: Assets.scratch,
              onTap: () => setState(() => _selectedMethod = 2),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedMethod == 1
                        ? 'شحن بالبطاقة المصرفية'
                        : 'شحن بالكرت',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.right,
                  ),
                ),
                IconButton(
                  tooltip: 'رجوع',
                  onPressed: () => setState(() => _selectedMethod = null),
                  icon: const Icon(Icons.arrow_back),
                ),
              ],
            ),
            if (_selectedMethod == 1)
              TopUpSheetVisa(embedded: true, onCompleted: _completed)
            else
              TopUpSheet(embedded: true, onCompleted: _completed),
          ],
        ],
      ),
    );

    if (widget.embedded) {
      return Card(child: content);
    }
    return PageWrapper(
      allowBack: true,
      title: 'خدمات المحفظة',
      child: content,
    );
  }
}
