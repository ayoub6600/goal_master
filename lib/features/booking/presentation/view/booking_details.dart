import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_calder.dart';
import 'package:goal_master/core/components/page_wrapper.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/category_cubit/category_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/club_cubit/club_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/zone_cubit/zone_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/booking_items_details.dart.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  void _nextPage() {
    if (_currentPage < 5) {
      setState(() => _currentPage++);
      _controller.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _controller.previousPage(
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  Widget _stepTitle(String title, String dis) => Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: AppTextStyles.font16Bold.copyWith(color: Colors.black)),
            HeightSpace(8.h),
            Text(
              dis,
              style: AppTextStyles.font14Medium.copyWith(
                color: AppColors.inactiveText1,
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      title: "إضافة الحجز",
      allowBack: true,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              physics: NeverScrollableScrollPhysics(),
              children: [
                BlocBuilder<ZoneCubitCubit, ZoneCubitState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _stepTitle(
                          "اختر الموقع",
                          "اختر الموقع المناسب للحجز الذي تريده",
                        ),
                        if (state is ZoneCubitSuccess)
                          ...state.location.map((zone) => ListTile(
                                title: Text(zone.name),
                                onTap: _nextPage,
                              )),
                        if (state is ZoneCubitLoading)
                          CircularProgressIndicator(),
                        if (state is ZoneCubitError)
                          Text('خطأ: ${state.message}'),
                      ],
                    );
                  },
                ),
                BlocBuilder<ClubCubit, ClubState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _stepTitle("اختر النادي",
                            "اختر النادي المناسب للحجز الذي تريده"),
                        if (state is ClubSuccess)
                          ...state.clubs.map((club) => ListTile(
                                title: Text(club.name),
                                onTap: _nextPage,
                              )),
                        if (state is ClubLoading) CircularProgressIndicator(),
                        if (state is ClubError) Text('خطأ: ${state.message}'),
                      ],
                    );
                  },
                ),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _stepTitle("اختر الفئة",
                            "اختر الفئة المناسب للحجز الذي تريده"),
                        if (state is CategorySuccess)
                          ...state.categories.map((cat) => ListTile(
                                title: Text(cat.name),
                                onTap: _nextPage,
                              )),
                        if (state is CategoryLoading)
                          CircularProgressIndicator(),
                        if (state is CategoryFailure)
                          Text('خطأ: ${state.message}'),
                      ],
                    );
                  },
                ),
                BlocBuilder<ServiceCubit, ServiceState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _stepTitle("اختر الخدمة",
                            "اختر الخدمة المناسب للحجز الذي تريده"),
                        if (state is ServiceSuccess)
                          ...state.services.map((service) => ListTile(
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //CachedNetworkImage(imageUrl: service.image),
                                    Text(service.title),
                                    Text(service.price.toString()),
                                  ],
                                ),
                                onTap: _nextPage,
                              )),
                        if (state is ServiceLoading)
                          CircularProgressIndicator(),
                        if (state is ServiceError)
                          Text('خطأ: ${state.message}'),
                      ],
                    );
                  },
                ),
                BlocBuilder<EmployeeCubit, EmployeeState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        _stepTitle("اختر الموظف",
                            "اختر الموظف المناسب للحجز الذي تريده"),
                        if (state is EmployeeSuccess)
                          ...state.employees.map((emp) => ListTile(
                                title: Text(emp.fullName ?? ""),
                                onTap: _nextPage,
                              )),
                        if (state is EmployeeLoading)
                          CircularProgressIndicator(),
                        if (state is EmployeeFailure)
                          Text('خطأ: ${state.message}'),
                      ],
                    );
                  },
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _stepTitle("تاريخ الحجز",
                          "اختر التاريخ المناسب للحجز الذي تريده"),
                      SizedBox(height: 700.h, child: CustomCalder()),
                      //    HeightSpace(20.h),
                      // CustomBookingButton(
                      //   text: "اذهب للدفع",
                      //   onTap: () {
                      //     // تنفيذ الدفع
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_currentPage > 0)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: ElevatedButton(
                onPressed: _prevPage,
                child: Text("الرجوع"),
              ),
            ),
        ],
      ),
    );
  }
}
