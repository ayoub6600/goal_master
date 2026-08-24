import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goal_master/core/routing/routes_keys.dart';
import 'package:goal_master/core/styles/app_colors.dart';
import 'package:goal_master/features/assistant/data/model/assistant_message.dart';
import 'package:goal_master/features/assistant/presentation/manager/assistant_chat_cubit/assistant_chat_cubit.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_avatar_popup.dart';
import 'package:goal_master/features/assistant/presentation/view/widgets/assistant_message_bubble.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<AssistantChatCubit>().loadHistory();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
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
          if (state.messages.isNotEmpty) _scrollToBottom();

          // Only pop up for messages we haven't already reacted to, and
          // only for a captain message whose state actually means
          // something (booking_success/error/warning/empty_results/welcome)
          // — a plain "default" reply doesn't deserve a celebration overlay.
          if (state.messages.length > _seenMessageCount) {
            final newMessages = state.messages.skip(_seenMessageCount);
            AssistantMessage? notable;
            for (final m in newMessages.toList().reversed) {
              if (m.isCaptain && m.assistantState != 'default') {
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
    return Column(
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
        if (state.sending)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: state.sending ? null : _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
