import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/features/booking/presentation/manager/employee_cubit/employee_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/page_view_cubit/page_view_cubit_cubit.dart';
import 'package:goal_master/features/booking/presentation/manager/service_cubit/service_cubit.dart';
import 'package:goal_master/features/booking/presentation/view/widgets/step_title.dart';

class ServiceSelection extends StatelessWidget {
  final PageController controller;

  const ServiceSelection({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCubit, ServiceState>(
      builder: (context, state) {
        if (state is ServiceLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ServiceError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'خطأ: ${state.message}',
                textAlign: TextAlign.center,
                style: AppTextStyles.font14Medium,
              ),
            ),
          );
        }

        if (state is ServiceSuccess) {
          if (state.services.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'لا توجد ملاعب متاحة للحجز حالياً',
                  style: AppTextStyles.font16Bold,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepTitle(
                title: "الملعب",
                description: "اختر الملعب المناسب للحجز الذي تريده",
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.only(
                    left: 8.w,
                    right: 8.w,
                    bottom: 24.h,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: state.services.length,
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 16.h);
                  },
                  itemBuilder: (context, index) {
                    final service = state.services[index];

                    return _ServiceCard(
                      title: service.title,
                      price: service.price.toString(),
                      offerHeadline: service.marketingOffer?.headline,
                      showOffer: service.marketingOffer != null,
                      discountType: service.marketingOffer?.discountType,
                      discountValue: service.marketingOffer?.discountValue,
                      imageUrls: service.images.isNotEmpty
                          ? service.images
                          : [
                              if (service.image.trim().isNotEmpty)
                                service.image,
                            ],
                      onTap: () {
                        final pageViewCubit = context.read<PageViewCubit>();

                        final clubId = pageViewCubit.state.clubId;

                        pageViewCubit.setServiceId(
                          service.id,
                          service.title,
                        );

                        context.read<EmployeeCubit>().listEmployee(clubId ?? 0);

                        pageViewCubit.nextPage();

                        controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final String title;
  final String price;
  final List<String> imageUrls;
  final String? offerHeadline;
  final bool showOffer;
  final String? discountType;
  final double? discountValue;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.price,
    required this.imageUrls,
    required this.offerHeadline,
    required this.showOffer,
    required this.discountType,
    required this.discountValue,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  late final PageController _imageController;

  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();

    _imageController = PageController();
  }

  @override
  void dispose() {
    _imageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images =
        widget.imageUrls.where((image) => image.trim().isNotEmpty).toList();
    final basePrice = double.tryParse(widget.price) ?? 0;
    final advertisedDiscount = widget.discountValue == null
        ? 0.0
        : widget.discountType == 'percent'
            ? basePrice * widget.discountValue! / 100
            : widget.discountValue!;
    final advertisedPrice =
        (basePrice - advertisedDiscount).clamp(0, basePrice);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.10),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// ===============================
              /// صورة الملعب
              /// ===============================
              SizedBox(
                height: 180.h,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (images.isNotEmpty)
                      PageView.builder(
                        controller: _imageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          if (_currentImageIndex != index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          }
                        },
                        itemBuilder: (context, imageIndex) {
                          return CachedNetworkImage(
                            imageUrl: images[imageIndex],
                            width: double.infinity,
                            height: 180.h,
                            fit: BoxFit.cover,
                            placeholder: (context, url) {
                              return const _ImagePlaceholder(
                                showLoader: true,
                              );
                            },
                            errorWidget: (context, url, error) {
                              return const _ImagePlaceholder();
                            },
                            fadeInDuration: const Duration(
                              milliseconds: 250,
                            ),
                            memCacheHeight:
                                (360 * MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                          );
                        },
                      )
                    else
                      const _ImagePlaceholder(),

                    /// Gradient بسيط أسفل الصورة
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.10),
                            ],
                          ),
                        ),
                      ),
                    ),

                    /// مؤشرات الصور
                    if (images.length > 1)
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            images.length,
                            (index) {
                              final isSelected = index == _currentImageIndex;

                              return AnimatedContainer(
                                duration: const Duration(
                                  milliseconds: 200,
                                ),
                                margin: EdgeInsets.symmetric(
                                  horizontal: 3.w,
                                ),
                                width: isSelected ? 18.w : 7.w,
                                height: 7.h,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              /// ===============================
              /// بيانات الملعب
              /// ===============================
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.font16Bold.copyWith(
                          fontSize: 17.sp,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      HeightSpace(10.h),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.w,
                        runSpacing: 3.h,
                        children: [
                          Text("سعر الحجز الأساسي:",
                              style: AppTextStyles.font14Medium),
                          Text("${widget.price} دينار",
                              style: AppTextStyles.font16Bold.copyWith(
                                color: AppColors.primary,
                                decoration: widget.showOffer
                                    ? TextDecoration.lineThrough
                                    : null,
                              )),
                          if (widget.showOffer && widget.discountValue != null)
                            Text(
                              ' ${advertisedPrice.toStringAsFixed(2)} دينار',
                              style: AppTextStyles.font16Bold
                                  .copyWith(color: AppColors.primary),
                            ),
                        ],
                      ),
                      if (widget.showOffer && widget.offerHeadline != null) ...[
                        SizedBox(height: 5.h),
                        Row(
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 15.r, color: const Color(0xFF2F7B3B)),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                widget.offerHeadline!,
                                style: TextStyle(
                                  color: const Color(0xFF286B33),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      HeightSpace(12.h),
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app_outlined,
                            color: AppColors.primary,
                            size: 19.r,
                          ),
                          WidthSpace(6.w),
                          Text(
                            "اضغط لاختيار الملعب",
                            style: AppTextStyles.font14Medium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showLoader;

  const _ImagePlaceholder({
    this.showLoader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: showLoader
            ? SizedBox(
                width: 28.r,
                height: 28.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary.withOpacity(0.7),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer_rounded,
                    size: 50.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'لا توجد صورة للملعب',
                    style: AppTextStyles.font14Medium.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
