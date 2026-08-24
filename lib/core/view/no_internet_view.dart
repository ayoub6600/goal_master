import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/assets.dart';
import 'package:goal_master/core/view/connection_cubit.dart';

class NoInternetView extends StatefulWidget {
  const NoInternetView({super.key});

  @override
  State<NoInternetView> createState() => _NoInternetViewState();
}

class _NoInternetViewState extends State<NoInternetView> {
  bool _isRetrying = false;

  Future<void> _retryConnection() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    final connected = await context.read<ConnectionCubit>().retryCheck();

    if (!mounted) return;

    if (connected) {
      GoRouter.of(context).refresh();
    }

    if (mounted) {
      setState(() => _isRetrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This view is rendered as a plain overlay (a `Positioned.fill` sibling
    // of the routed app content in `main.dart`'s Stack, gated by
    // `ConnectionCubit`'s own bool state) — it was never pushed onto the
    // Navigator, so it has no Navigator ancestor to pop. Dismissal happens
    // on its own once `ConnectionCubit` flips back to `true`, since the
    // parent `BlocBuilder` simply stops rendering this widget at all.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Assets.imagesPngImageNoInternet,
                width: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'الاتصال بالإنترنت غير متوفر',
                style: AppTextStyles.font20Regular
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.',
                style: AppTextStyles.font16Regular,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRetrying ? null : _retryConnection,
                  icon: _isRetrying
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label:
                      Text(_isRetrying ? 'جاري المحاولة...' : 'إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
