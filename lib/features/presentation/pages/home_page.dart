import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_cubit.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_state.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_state.dart';
import 'package:flutter_application_1/features/presentation/cubits/conversation_cubit.dart';
import 'package:flutter_application_1/features/presentation/pages/profile_page.dart';
import 'package:flutter_application_1/features/presentation/pages/conversation_history_drawer.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ConversationCubit>().loadConversations(authState.user.id);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  List<Message> _resolveMessages(MessageState state) {
    if (state is MessageInitial) {
      return state.messages;
    }
    if (state is MessageLoading) {
      return state.messages;
    }
    if (state is MessageSuccess) {
      return state.messages;
    }
    if (state is MessageError) {
      return state.messages;
    }
    if (state is AddMessage) {
      return state.messages;
    }
    return [];
  }

  Widget _buildConversationDrawer() {
    final authState = context.read<AuthCubit>().state;
    final userId = authState is AuthAuthenticated ? authState.user.id : null;
    if (userId == null) return const SizedBox.shrink();
    return ConversationHistoryDrawer(
      userId: userId,
      onNewConversation: _startNewConversation,
    );
  }

  void _startNewConversation() {
    context.read<MessageCubit>().startNewConversation();
  }

  void _openConversationDrawer() {
    _loadConversations();
    _scaffoldKey.currentState?.openDrawer();
  }

  Widget _buildMessageBubble(Message message) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isUser ? 60 : 12,
          right: isUser ? 12 : 60,
          bottom: 14,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1D4E89) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 6),
              bottomRight: Radius.circular(isUser ? 6 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isUser ? 0.15 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            message.message ?? '',
            style: TextStyle(
              height: 1.5,
              color: isUser ? Colors.white : const Color(0xFF112A46),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.id;
    }

    context.read<MessageCubit>().sendAiMessages(
      Message(message: message),
      userId: userId,
    );
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessageCubit, MessageState>(
      listener: (context, state) {
        _scrollToBottom();
        if (state is MessageError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
            ),
          );
        }
      },
      builder: (context, state) {
        final messages = _resolveMessages(state);
        final isLoading = state is MessageLoading;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // Back tuşu basıldığında hiçbir şey yapma
          },
            child: Scaffold(
              key: _scaffoldKey,
              drawer: _buildConversationDrawer(),
              extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Doctor AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'AI Saglik Asistani',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white),
                tooltip: 'Gecmis',
                onPressed: _openConversationDrawer,
              ),
              centerTitle: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.person_rounded, color: Colors.white),
                  tooltip: 'Profil',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF10224F), Color(0xFF1D4E89), Color(0xFF2A9D8F)],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Expanded(
                      child: messages.isEmpty
                          ? Center(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 24),
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.93),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1D4E89).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        color: Color(0xFF1D4E89),
                                        size: 36,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Basla Konusmaya',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF112A46),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Sagliginla ilgili sorununu sor, Doctor AI sana yonlendirici bilgiler sunacak.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF7A8BA8),
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            itemCount: messages.length,
                            itemBuilder: (_, index) => _buildMessageBubble(messages[index]),
                          ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: SizedBox(
                        height: 24,
                        child: ModernInlineLoader(
                          label: 'Doctor AI dusunuyor',
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.97),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Mesajinizi yazin...',
                              hintStyle: TextStyle(
                                color: Color(0xFFA0A0A0),
                                fontSize: 15,
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF1D4E89),
                                size: 20,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF112A46),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, size: 22),
                            color: const Color(0xFF1D4E89),
                            tooltip: 'Gonder',
                            onPressed: _sendMessage,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        );
      },
    );
  }
}