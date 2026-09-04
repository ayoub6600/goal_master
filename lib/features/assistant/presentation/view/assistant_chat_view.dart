import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_avatar_popup.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_message_bubble.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_typing_indicator.dart';

class AssistantChatView extends StatefulWidget {
  const AssistantChatView({super.key});

  @override
  State<AssistantChatView> createState() => _AssistantChatViewState();
}

class _AssistantChatViewState extends State<AssistantChatView> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int _seenMessageCount = 0;
  String? _popupAvatarUrl;
  bool _initialPositioned = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Opening the chat is reading it — this is what clears the badge.
    context
        .read<AssistantChatCubit>()
        .loadHistory(markRead: true)
        .whenComplete(_positionAtLatestMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final distance = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    final shouldShow = distance > 120;
    if (shouldShow != _showScrollToBottom && mounted) {
      setState(() => _showScrollToBottom = shouldShow);
    }
  }

  void _positionAtLatestMessage() {
    if (!mounted) return;
    _initialPositioned = true;
    _scrollToBottom(immediately: true);
  }

  void _scrollToBottom({bool immediately = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      if (immediately) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        // The last bubbles may finish layout one frame later.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(
              _scrollController.position.maxScrollExtent,
            );
          }
        });
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleQuickReply(QuickReply reply) {
    if (reply.action == 'topup_wallet') {
      // Handled entirely client-side — the backend can't send the customer
      // to a wallet top-up screen, so this action never reaches the API.
      context.push(RoutesKeys.kCard);
      return;
    }
    context.read<AssistantChatCubit>().sendAction(reply.action, reply.payload);
    _scrollToBottom();
  }

  void _handleSend() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    context.read<AssistantChatCubit>().sendText(text);
    _controller.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        // Not hardcoded: whichever AssistantProfile the backend resolved
        // for this conversation names itself here.
        title: BlocBuilder<AssistantChatCubit, AssistantChatState>(
          buildWhen: (previous, current) =>
              previous.assistantName != current.assistantName,
          builder: (context, state) => Text(state.assistantName),
        ),
      ),
      body: BlocConsumer<AssistantChatCubit, AssistantChatState>(
        listener: (context, state) {
          if (state.messages.isNotEmpty) {
            if (!_initialPositioned) {
              _positionAtLatestMessage();
            } else if (!_showScrollToBottom) {
              _scrollToBottom();
            }
          }

          // Only for messages the BACKEND marked as worth interrupting for —
          // an empty wallet, a completed booking. Deriving it from the avatar
          // state instead meant every routine warning and every welcome threw
          // the character across the screen mid-conversation.
          if (state.messages.length > _seenMessageCount) {
            final newMessages = state.messages.skip(_seenMessageCount);
            AssistantMessage? notable;
            for (final m in newMessages.toList().reversed) {
              if (m.isCaptain && m.showAvatarPopup) {
                notable = m;
                break;
              }
            }
            if (notable != null) {
              final url = state.avatarFor(notable.assistantState);
              if (url != null) {
                setState(() => _popupAvatarUrl = url);
              }
            }
            _seenMessageCount = state.messages.length;
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildBody(state),
              if (_popupAvatarUrl != null)
                AssistantAvatarPopup(
                  imageUrl: _popupAvatarUrl!,
                  onDismissed: () => setState(() => _popupAvatarUrl = null),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBody(AssistantChatState state) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: state.loading && state.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        return AssistantMessageBubble(
                          message: message,
                          isLatest: index == state.messages.length - 1,
                          onQuickReply: _handleQuickReply,
                          avatarUrl: state.avatarFor(message.assistantState),
                        );
                      },
                    ),
            ),
            // Shown as one of the assistant's own bubbles rather than a bare
            // spinner: the customer is waiting for a person to answer, not
            // for a screen to load.
            if (state.sending)
              AssistantTypingIndicator(
                avatarUrl: state.avatarFor('default'),
              ),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 18),
                        onPressed: state.sending ? null : _handleSend,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        PositionedDirectional(
          end: 18,
          bottom: 84,
          child: AnimatedScale(
            scale: _showScrollToBottom ? 1 : 0,
            duration: const Duration(milliseconds: 160),
            child: IgnorePointer(
              ignoring: !_showScrollToBottom,
              child: Material(
                color: AppColors.primary,
                elevation: 3,
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'آخر الرسائل',
                  onPressed: _scrollToBottom,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
