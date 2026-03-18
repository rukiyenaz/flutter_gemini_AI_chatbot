import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/domain/entities/conversation.dart';
import 'package:flutter_application_1/features/presentation/cubits/conversation_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/conversation_state.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_cubit.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConversationHistoryDrawer extends StatelessWidget {
  final String userId;
  final VoidCallback onNewConversation;

  const ConversationHistoryDrawer({
    super.key,
    required this.userId,
    required this.onNewConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10224F), Color(0xFF1D4E89)],
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1D4E89), Color(0xFF2A9D8F)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Gecmis Konusmalar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onNewConversation();
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Yeni Konusma'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D4E89),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ConversationCubit, dynamic>(
                builder: (context, state) {
                  if (state is ConversationLoading) {
                    return const Center(
                      child: ModernInlineLoader(
                        label: 'Konusmalar yukleniyor',
                        color: Colors.white,
                        size: 16,
                      ),
                    );
                  }

                  if (state is ConversationListLoaded) {
                    final conversations = state.conversations;
                    if (conversations.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Henuz konusma yok',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        return ConversationHistoryTile(
                          conversation: conversation,
                          onTap: () {
                            context.read<MessageCubit>().loadConversation(
                              userId,
                              conversation.conversationId,
                            );
                            Navigator.pop(context);
                          },
                          onDelete: () {
                            context.read<ConversationCubit>().deleteConversation(
                              userId,
                              conversation.conversationId,
                            );
                          },
                        );
                      },
                    );
                  }

                  return Center(
                    child: Text(
                      'Hata olustu',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationHistoryTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ConversationHistoryTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${conversation.messages.length} mesaj',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  color: Colors.white.withValues(alpha: 0.6),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
