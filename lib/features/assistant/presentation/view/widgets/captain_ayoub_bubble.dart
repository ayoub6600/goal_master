import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';
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

class _CaptainAyoubBubbleState extends State<CaptainAyoubBubble>
    with WidgetsBindingObserver {
  bool _showHint = false;
  Offset? _position;

  @override
  void initState() {
    super.initState();
    _maybeShowHintOnce();
    // Fetch (once) so the avatar is ready before the user ever opens the
    // chat screen — cheap no-op if already loaded elsewhere.
    // Fetched here so the avatar is ready before the chat is ever opened.
    //
    // At a cold start the Active Location is usually still being read from the
    // account, so this first call carries no zone — and the backend answers an
    // unplaceable request with the DEFAULT profile, which is a real captain
    // from a real city, not a neutral one. The listener above corrects it the
    // moment the location lands; the cubit records which zone the persona it
    // is showing belongs to, so that correction is guaranteed rather than
    // dependent on this ordering.
    final cubit = context.read<AssistantChatCubit>();
    if (cubit.state.messages.isEmpty && !cubit.state.loading) {
      cubit.loadHistory();
    }
    // The badge is what makes an unprompted message findable at all — the
    // wallet offer after a venue refuses used to sit unseen in a chat the
    // customer had no reason to open.
    cubit.refreshUnread();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// An offer can arrive while the app is closed, so re-check on the way back
  /// in rather than only at startup.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AssistantChatCubit>().refreshUnread();
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
    return BlocListener<ActiveLocationCubit, ActiveLocationState>(
      // Keyed to the ZONE of the authoritative Active Location.
      //
      // This used to watch LayoutCubit.currentPosition — the raw GPS/map pin —
      // which is a different fact from where the customer is shopping, and the
      // mismatch produced a captain from the wrong city:
      //
      //   • Set on Map moved the pin, so the listener fired and the captain
      //     corrected itself. That is why that path always appeared to work.
      //   • «موقعي الحالي» often returned the SAME coordinates already in
      //     LayoutCubit, so previous == current, the listener never fired, and
      //     the captain stayed as it was.
      //   • Saved Locations never touch LayoutCubit at all, so it never fired.
      //
      // Zone rather than position, because the persona is scoped by zone: it
      // is the only change that can alter the captain, and it avoids refetching
      // on every metre of GPS drift.
      listenWhen: (previous, current) =>
          previous.location?.zoneId != current.location?.zoneId,
      listener: (context, state) {
        context.read<AssistantChatCubit>().loadHistory(forceRefresh: true);
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
          final location = AppRouter
              .router.routerDelegate.currentConfiguration.uri
              .toString();
          if (location == RoutesKeys.kAssistantChat) {
            return const SizedBox.shrink();
          }
          return _buildBubble(context);
        },
      ),
    );
  }

  /// A count badge over the avatar, shown only when something is waiting.
  ///
  /// Sits outside the ClipOval so it is not cropped by it, and overflows the
  /// bubble's circle the way an unread badge is expected to.
  Widget _withBadge(int count, Widget avatar) {
    if (count <= 0) return avatar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        Positioned(
          top: -2,
          left: -2,
          child: Container(
            constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(11),
              // A ring in the scaffold colour keeps the badge legible
              // wherever the bubble has been dragged to.
              border: Border.all(color: Colors.white, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
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
                  previous.messages.length != current.messages.length ||
                  previous.unreadCount != current.unreadCount,
              builder: (context, state) {
                // Reacts to whatever just happened in the chat (booking
                // success, an error...) even from the home screen — falls
                // back to the default avatar once there's no message yet,
                // or once the latest one is just an ordinary reply.
                final latestState = state.messages.isNotEmpty
                    ? state.messages.last.assistantState
                    : 'default';
                final avatarUrl = state.avatarFor(latestState);
                return _withBadge(
                  state.unreadCount,
                  Container(
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
