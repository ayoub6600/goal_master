import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';

class TermAndConditionView extends StatelessWidget {
  const TermAndConditionView({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "الشروط والأحكام",
      allowBack: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeightSpace(20.h),
              _buildTerm(
                number: "1",
                title: "قبول الشروط:",
                content:
                    "باستخدام هذا الموقع، فإنك توافق على الالتزام بكافة الشروط والأحكام المذكورة أدناه. إذا كنت لا توافق على هذه الشروط، يُرجى عدم استخدام الموقع.",
              ),
              HeightSpace(12.h),
              _buildTerm(
                number: "2",
                title: "حجز الملاعب:",
                content:
                    "- يتيح الموقع حجز الملاعب الرياضية في الأوقات المتاحة فقط.\n"
                    "- يجب تأكيد الحجز والدفع المسبق لضمان الحجز النهائي.",
              ),
              HeightSpace(12.h),
              _buildTerm(
                number: "3",
                title: "الخصوصية والأمان:",
                content:
                    "- يلتزم الموقع بحماية بيانات المستخدمين ولن يتم مشاركة أي معلومات شخصية مع أطراف ثالثة إلا عند الضرورة القصوى أو بموافقة المستخدم.\n"
                    "- يُرجى الحفاظ على معلومات الدخول الخاصة بك وعدم مشاركتها مع أي شخص آخر.",
              ),
              HeightSpace(12.h),
              _buildTerm(
                number: "4",
                title: "الالتزامات والمسؤوليات:",
                content:
                    "- يتحمل المستخدم مسؤولية استخدام الملعب بطريقة آمنة ومسؤولة.\n"
                    "- الموقع غير مسؤول عن أي إصابات أو أضرار قد تحدث أثناء استخدام الملاعب.\n"
                    "- يجب اتباع التعليمات والإرشادات المتاحة في الموقع والملاعب لضمان السلامة.\n"
                    "- يحق للموقع تعديل أو إلغاء أي حجز في حال حدوث ظروف خارجة عن الإرادة.",
              ),
              HeightSpace(12.h),
              _buildTerm(
                  number: "5",
                  title: " خدمات الإسعافات الأولية",
                  content:
                      "يوفر الموقع خدمات الإسعافات الأولية ولكن لا يتحمل أي مسؤولية عن الأضرار الناتجة عن الإصابات."),
              HeightSpace(12.h),
              _buildTerm(
                number: "6",
                title: " خدمات الإسعافات الأولية",
                content:
                    "-يمكن إلغاء الحجز قبل موعد اللعب بـ 24 ساعة على الأقل للحصول على استرداد كامل للمبلغ المدفوع.\n-لن يتم رد أي مبالغ للحجوزات الملغاة بعد هذه الفترة الزمنية.",
              ),
              HeightSpace(12.h),
              _buildTerm(
                number: "7",
                title: "السلوك المحظور",
                content:
                    "يُحظر القيام بأي نشاط غير قانوني، أو يُسبب إزعاجاً للآخرين، أو يُلحق الضرر بالملاعب أو الأدوات الرياضية.",
              ),
              HeightSpace(30.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTerm({
    required String number,
    required String title,
    required String content,
  }) {
    return Text.rich(
      TextSpan(
        text: '$number- $title\n',
        style: AppTextStyles.font16Bold.copyWith(
          color: Colors.black,
        ),
        children: [
          TextSpan(
            text: content,
            style: AppTextStyles.font14Medium.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }
}
