import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:goal_master/core/components/custom_text_field/custom_app_form_text_field.dart';
import 'package:goal_master/core/routing/route_utils.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/features/auth/data/model/onboarding/onboarding_screen_model.dart';
import 'package:goal_master/features/auth/data/services/onboarding_screens_service.dart';
import 'package:goal_master/features/auth/presentation/manager/register_cubit/register_cubit.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/onboarding/signup_step_scaffold.dart';

/// Signing up as a short conversation rather than a form.
///
/// One question per screen, each with a single field and a single button. The
/// two fields that used to sit here and asked nothing of the customer's
/// judgement — the account handle and the repeated password — are gone: the
/// backend generates the handle, and a show/hide toggle catches typos better
/// than typing the same thing twice.
class RegisterViewBody extends StatefulWidget {
  const RegisterViewBody({super.key});

  @override
  State<RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<RegisterViewBody> {
  final _pageController = PageController();
  int _step = 0;
  bool _passwordShown = false;

  static const _totalSteps = 3;

  final _screens = OnboardingScreensService.instance;

  @override
  void initState() {
    super.initState();
    // Fire-and-repaint: the steps render immediately with the app's own
    // wording and artwork, and swap in whatever the admin configured the
    // moment it lands. Signing up never waits on this.
    _screens.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _next(bool Function() validate) {
    FocusScope.of(context).unfocus();
    if (!validate()) return;
    _goTo(_step + 1);
  }

  void _back() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      // Signup is now where the walkthrough ends, and it arrives there by
      // replacement — so there is nothing behind it to pop to. Back from the
      // first question means "I already have an account".
      if (canPop(context)) {
        pop(context);
      } else {
        pushReplacement(RoutesKeys.kLogin, context);
      }
      return;
    }
    _goTo(_step - 1);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          // Straight on to the OTP the account is waiting on — the success
          // screen lives there, once the number is actually confirmed.
          push(
            RoutesKeys.kOtp,
            context,
            extra: {
              'phone': cubit.phoneController.text.trim(),
              'forget': false
            },
          );
        }
      },
      builder: (context, state) {
        final error = state is RegisterError ? state.errMessage : null;
        final busy = state is RegisterLoading;

        // Only the step the customer is looking at may show an error;
        // otherwise a message from step one follows them to step three.
        String? errorFor(int step) => _step == step ? error : null;

        return PopScope(
          // Every exit runs through _back, including the system gesture on the
          // first step: letting the framework pop that one directly would hit
          // the same empty stack.
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _back();
          },
          child: PageView(
            controller: _pageController,
            // Driven by the buttons alone: a swipe past an unanswered
            // question would land the customer somewhere they cannot finish.
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _nameStep(cubit, errorFor(0), busy),
              _phoneStep(cubit, errorFor(1), busy),
              _passwordStep(cubit, errorFor(2), busy),
            ],
          ),
        );
      },
    );
  }

  Widget _nameStep(RegisterCubit cubit, String? error, bool busy) {
    return SignupStepScaffold(
      stepIndex: 0,
      totalSteps: _totalSteps,
      emoji: '👋',
      artworkUrl: _screens.imageFor(OnboardingSlugs.name),
      question: _screens.titleFor(OnboardingSlugs.name, 'هلا بيك 👋 شن اسمك؟'),
      subtitle: _screens.subtitleFor(OnboardingSlugs.name, 'باش نعرف نناديك بيه'),
      error: error,
      isBusy: busy,
      onBack: _back,
      field: CustomTextField(
        hint: 'اكتب اسمك',
        controller: cubit.nameController,
        inputType: TextInputType.name,
      ),
      ctaText: 'التالي',
      onCta: () => _next(cubit.validateName),
    );
  }

  Widget _phoneStep(RegisterCubit cubit, String? error, bool busy) {
    final name = cubit.firstName;

    return SignupStepScaffold(
      stepIndex: 1,
      totalSteps: _totalSteps,
      emoji: '📱',
      artworkUrl: _screens.imageFor(OnboardingSlugs.phone),
      question: _screens.titleFor(
        OnboardingSlugs.phone,
        name.isEmpty
            ? 'تمام 👌 توا عطيني رقم هاتفك'
            : 'تمام يا $name 👌 توا عطيني رقم هاتفك',
      ),
      subtitle: _screens.subtitleFor(
          OnboardingSlugs.phone, 'نستعملوه للدخول ولتأكيد حسابك'),
      error: error,
      isBusy: busy,
      onBack: _back,
      field: CustomTextField(
        hint: '09XXXXXXXX',
        controller: cubit.phoneController,
        inputType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
      ),
      ctaText: 'التالي',
      onCta: () => _next(cubit.validatePhone),
    );
  }

  Widget _passwordStep(RegisterCubit cubit, String? error, bool busy) {
    return SignupStepScaffold(
      stepIndex: 2,
      totalSteps: _totalSteps,
      emoji: '🔐',
      artworkUrl: _screens.imageFor(OnboardingSlugs.password),
      question: _screens.titleFor(
          OnboardingSlugs.password, 'آخر خطوة 🔐 اختار كلمة مرور لحسابك'),
      subtitle:
          _screens.subtitleFor(OnboardingSlugs.password, '8 أحرف على الأقل'),
      error: error,
      isBusy: busy,
      onBack: _back,
      field: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            hint: 'اكتب كلمة المرور',
            controller: cubit.passwordController,
            password: !_passwordShown,
          ),
          SizedBox(height: 10.h),
          // Shown rather than repeated: seeing what was typed catches a
          // mistake more reliably than typing it a second time.
          GestureDetector(
            onTap: () => setState(() => _passwordShown = !_passwordShown),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  _passwordShown ? Icons.visibility_off : Icons.visibility,
                  size: 17.sp,
                  color: AppColors.primary,
                ),
                SizedBox(width: 6.w),
                Text(
                  _passwordShown ? 'إخفاء كلمة المرور' : 'إظهار كلمة المرور',
                  style: AppTextStyles.font12Bold
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
      ctaText: 'إنشاء الحساب',
      onCta: cubit.register,
    );
  }
}
