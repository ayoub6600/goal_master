import 'package:flutter/material.dart';
import 'package:goal_master/features/auth/presentation/view/widgets/register_view_body.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // The body used to carry its own Scaffold; splitting it into steps left
    // it with none, so the screen rendered on bare black with Flutter's
    // yellow "no Material ancestor" underlines under every line of text.
    return const Scaffold(
      backgroundColor: Colors.white,
      // The keyboard must not shove a fixed-height step into a negative
      // space — each step scrolls its own content instead.
      resizeToAvoidBottomInset: true,
      body: RegisterViewBody(),
    );
  }
}
