import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_cubit.dart';
import 'package:goal_master/features/layout/presentation/manager/layout_state.dart';

const double _kBubbleSize = 68;
const String _kPosXKey = 'captain_ayoub_pos_x';
const String _kPosYKey = 'captain_ayoub_pos_y';

/// Persistent floating "Captain Ayoub" bubble, rendered above every screen
/// via MaterialApp.router's builder Stack (same slot as NoInternetView).
/// Draggable anywhere on screen — the last position is remembered across
/// app restarts. Shows the admin-uploaded mascot avatar once loaded, falling
/// back to a placeholder icon before that (or if none was ever uploaded).
class CaptainAyoubBubble extends StatefulWidget {
  const CaptainAyoubBubble({super.key});

  @override
  State<CaptainAyoubBubble> createState() => _CaptainAyoubBubbleState();
}

class _CaptainAyoubBubbleState extends State<CaptainAyoubBubble> {
  bool _showHint = false;
  Offset? _position;

  @override
  void initState() {
    super.initState();
    _maybeShowHintOnce();
    // Fetch (once) so the avatar is ready before the user ever opens the
    // chat screen — cheap no-op if already loaded elsewhere.
    final cubit = context.read<AssistantChatCubit>();
    if (cubit.state.messages.isEmpty && !cubit.state.loading) {
      cubit.loadHistory();
    }
  }

  Future<void> _maybeShowHintOnce() async {
    const hintShownKey = 'captain_ayoub_hint_shown';
    final alreadyShown = SharedPreferenceUtil.getBool(hintShownKey);
    if (!alreadyShown) {
      setState(() => _showHint = true);
      SharedPreferenceUtil.putBool(hintShownKey, true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _showHint = false);
      });
    }
  }

  Offset _defaultPosition(Size screenSize) {
    // Above the bottom nav bar by default, not overlapping/behind it — the
    // user can still drag it anywhere, including lower, if they want.
    return Offset(16, screenSize.height - 220);
  }

  Offset _clamp(Offset offset, Size screenSize) {
    final maxX = screenSize.width - _kBubbleSize;
    final maxY = screenSize.height - _kBubbleSize;
    return Offset(
      offset.dx.clamp(0, maxX < 0 ? 0 : maxX),
      offset.dy.clamp(0, maxY < 0 ? 0 : maxY),
    );
  }

  void _savePosition(Offset offset) {
    SharedPreferenceUtil.putDouble(_kPosXKey, offset.dx);
    SharedPreferenceUtil.putDouble(_kPosYKey, offset.dy);
  }

  @override
  Widget build(BuildContext context) {
    final loggedIn = SharedPreferenceUtil.getString(PrefKey.login) == 'true';
    if (!loggedIn) return const SizedBox.shrink();

    // This widget is the one thing mounted globally on every screen (it's
    // rendered from MaterialApp.router's builder Stack, not from inside any
    // single route) — so the location -> zone -> profile refresh lives
    // here, not on the home screen. A listener on the home screen alone
    // only fires while the home tab happens to be the active/mounted one;
    // this fires no matter which screen the customer is looking at.
    return BlocListener<LayoutCubit, LayoutState>(
      listenWhen: (previous, current) =>
          current.currentPosition != null &&
          previous.currentPosition != current.currentPosition,
      listener: (context, state) {
        // The captain's identity/avatar can be scoped to a zone (see
        // AssistantProfile::resolveForZone on the backend) — reload so the
        // bubble picks up the right persona the moment the customer's
        // location moves into a different zone, instead of only updating
        // once they tap it open.
        context.read<AssistantChatCubit>().loadHistory();
      },
      // Rebuilds on every navigation so the bubble can hide itself while the
      // chat screen is open — no BuildContext-based route lookup, since this
      // widget's context sits above the Router (see the push() note below).
      // Not routeInformationProvider: that tracks the URL/history state (for
      // deep-linking) and doesn't reliably fire on an imperative pop() back
      // off the chat screen, which is why the bubble stayed hidden until a hot
      // restart. routerDelegate.currentConfiguration is the live matched route
      // stack and updates immediately on both push and pop.
      child: ListenableBuilder(
        listenable: AppRouter.router.routerDelegate,
        builder: (context, _) {
          final location =
              AppRouter.router.routerDelegate.currentConfiguration.uri.toString();
          if (location == RoutesKeys.kAssistantChat) {
            return const SizedBox.shrink();
          }
          return _buildBubble(context);
        },
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (_position == null) {
      final savedX = SharedPreferenceUtil.getDouble(_kPosXKey, defValue: -1);
      final savedY = SharedPreferenceUtil.getDouble(_kPosYKey, defValue: -1);
      _position = savedX >= 0 && savedY >= 0
          ? _clamp(Offset(savedX, savedY), screenSize)
          : _defaultPosition(screenSize);
    }

    return Positioned(
      left: _position!.dx,
      top: _position!.dy,
      child: GestureDetector(
        onTap: () {
          setState(() => _showHint = false);
          // Not context.push(): this widget lives in MaterialApp.router's
          // `builder`, whose context sits above the Router itself, so
          // GoRouter.of(context) can't find an ancestor there and throws
          // "No GoRouter found in context". Use the static router
          // instance instead (same fix already used in main.dart's
          // notification-tap handler for the same reason).
          AppRouter.router.push(RoutesKeys.kAssistantChat);
        },
        onPanUpdate: (details) {
          setState(() {
            _showHint = false;
            _position = _clamp(_position! + details.delta, screenSize);
          });
        },
        onPanEnd: (_) => _savePosition(_position!),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<AssistantChatCubit, AssistantChatState>(
              buildWhen: (previous, current) =>
                  previous.avatarUrl != current.avatarUrl ||
                  previous.avatarStates != current.avatarStates ||
                  previous.messages.length != current.messages.length,
              builder: (context, state) {
                // Reacts to whatever just happened in the chat (booking
                // success, an error...) even from the home screen — falls
                // back to the default avatar once there's no message yet,
                // or once the latest one is just an ordinary reply.
                final latestState = state.messages.isNotEmpty
                    ? state.messages.last.assistantState
                    : 'default';
                final avatarUrl = state.avatarFor(latestState);
                return Container(
                  width: _kBubbleSize,
                  height: _kBubbleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            // The uploaded artwork is a tall character
                            // illustration — a centered crop cuts off the
                            // face. Anchoring to the top keeps the face in
                            // frame at this small size.
                            alignment: Alignment.topCenter,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.support_agent,
                              color: Colors.white,
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.support_agent,
                            color: Colors.white,
                            size: 36,
                          ),
                  ),
                );
              },
            ),
            if (_showHint)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: const BoxConstraints(maxWidth: 200),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BlocBuilder<AssistantChatCubit, AssistantChatState>(
                  buildWhen: (previous, current) =>
                      previous.assistantShortName != current.assistantShortName,
                  builder: (context, state) => Text(
                    'أهلاً، أنا ${state.assistantShortName} هنا لمساعدتك 👋',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
