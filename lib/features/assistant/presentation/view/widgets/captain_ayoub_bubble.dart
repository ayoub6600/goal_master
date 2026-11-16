import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_master/core/components/keys_values.dart';
import 'package:goal_master/core/components/preference_utility.dart';
import 'package:goal_master/core/routing/app_router.dart';
import 'package:goal_master/core/routing/popup_route_tracker.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_avatar_image.dart';
import 'package:goal_master/features/location/presentation/manager/active_location_cubit.dart';

/// Smaller than it was (68): it floats over every screen, so every point of
/// it covers something.
const double _kBubbleSize = 58;

/// Gap kept between the bubble and the screen edge it docks to.
const double _kEdgeGap = 8;
const String _kPosXKey = 'captain_ayoub_pos_x';
const String _kPosYKey = 'captain_ayoub_pos_y';

/// Persistent floating "Captain Ayoub" bubble, rendered above every screen
/// via MaterialApp.router's builder Stack (same slot as NoInternetView).
/// Draggable anywhere on screen — the last position is remembered across
/// app restarts. Shows the admin-uploaded mascot avatar once loaded, falling
/// back to a placeholder icon before that (or if none was ever uploaded).
class CaptainAyoubBubble extends StatefulWidget {
  const CaptainAyoubBubble({super.key});

  /// Full-screen experiences pushed outside go_router (games) raise this
  /// while open, so the bubble doesn't sit over their touch area.
  static final suppressed = ValueNotifier<int>(0);

  @override
  State<CaptainAyoubBubble> createState() => _CaptainAyoubBubbleState();
}

/// Screens the bubble stays off: booking and payment steps, and forms with
/// a keyboard and a submit button at the bottom.
const Set<String> _hiddenOn = {
  RoutesKeys.kBookingDetails,
  RoutesKeys.kAddNewBooking,
  RoutesKeys.kPaymentWebViewPage,
  RoutesKeys.kListPaymentView,
  RoutesKeys.kCard,
  RoutesKeys.kUpdateProfile,
  RoutesKeys.kChangePassword,
};

class _CaptainAyoubBubbleState extends State<CaptainAyoubBubble>
    with WidgetsBindingObserver {
  bool _showHint = false;
  Offset? _position;
  bool _dragging = false;

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

  Offset _defaultPosition(Size screenSize, EdgeInsets safe) {
    // Docked to the left edge just above the bottom bar (~80pt tall), where
    // it covers the least: it used to sit 220pt up, right over the home
    // screen's «احجز الآن» button. Still draggable anywhere.
    return Offset(
      _kEdgeGap,
      screenSize.height - safe.bottom - 80 - _kBubbleSize - 6,
    );
  }

  /// After a drag, slide to the nearer side edge — left in the middle of the
  /// screen it always covers something.
  Offset _snapToEdge(Offset offset, Size screenSize) {
    final centreX = offset.dx + _kBubbleSize / 2;
    final x = centreX < screenSize.width / 2
        ? _kEdgeGap
        : screenSize.width - _kBubbleSize - _kEdgeGap;
    return _clamp(Offset(x, offset.dy), screenSize);
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
        listenable: Listenable.merge([
          AppRouter.router.routerDelegate,
          CaptainAyoubBubble.suppressed,
          PopupRouteTracker.instance.openPopups,
        ]),
        builder: (context, _) {
          // The screen actually on top. `uri` alone stays on the base
          // location when a screen is pushed (go_router does not reflect
          // push() in the URL by default), so the pushed screen is read from
          // the last match.
          final config = AppRouter.router.routerDelegate.currentConfiguration;
          final location = config.isNotEmpty
              ? config.last.matchedLocation
              : config.uri.path;
          // Also hidden while a sheet or dialog is open: drawn above the
          // navigator, it otherwise sat on top of their buttons. And on the
          // screens where the customer is entering details or paying — it
          // covered the booking total, and a mis-tap there costs money.
          // Re-read on every navigation, not only when this widget first
          // builds: after signing out (or a session ended elsewhere) the app
          // goes to the login screen without rebuilding the outer widget, and
          // the bubble used to stay on the login screen.
          final stillLoggedIn =
              SharedPreferenceUtil.getString(PrefKey.login) == 'true';
          if (!stillLoggedIn ||
              location == RoutesKeys.kAssistantChat ||
              _hiddenOn.contains(location) ||
              CaptainAyoubBubble.suppressed.value > 0 ||
              PopupRouteTracker.instance.openPopups.value > 0) {
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
          ? _snapToEdge(Offset(savedX, savedY), screenSize)
          : _defaultPosition(screenSize, MediaQuery.of(context).padding);
    }

    return AnimatedPositioned(
      // Follows the finger exactly while dragging; glides to the edge after.
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
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
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate: (details) {
          setState(() {
            _showHint = false;
            _position = _clamp(_position! + details.delta, screenSize);
          });
        },
        onPanEnd: (_) {
          setState(() {
            _dragging = false;
            _position = _snapToEdge(_position!, screenSize);
          });
          _savePosition(_position!);
        },
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
                          ? AssistantAvatarImage(
                              url: avatarUrl,
                              width: _kBubbleSize,
                              height: _kBubbleSize,
                              fallback: const Icon(
                                Icons.support_agent,
                                color: Colors.white,
                                size: 30,
                              ),
                            )
                          : const Icon(
                              Icons.support_agent,
                              color: Colors.white,
                              size: 30,
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
