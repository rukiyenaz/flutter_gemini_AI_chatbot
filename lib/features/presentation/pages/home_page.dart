import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_cubit.dart';
import 'package:flutter_application_1/features/domain/entities/message.dart';
import 'package:flutter_application_1/features/domain/repositories/message_ai_repo.dart';
import 'package:flutter_application_1/features/domain/repositories/message_firestore_repo.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
      }
          });
  }



  @override
  Widget build(BuildContext context) {
    final authCubit= context.read<AuthCubit>();

    return BlocConsumer<MessageCubit,MessageState>(
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
      builder: (context, state){
        List<Message> messages = [];
        
        if (state is MessageLoading) {
          return const Center(child: CircularProgressIndicator(),);
        } else if (state is MessageSuccess){
          messages = state.messages;
        }
        return Scaffold(
          appBar: AppBar(
            backgroundColor:  Color.fromARGB(255, 163, 196, 249),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  // Handle logout
                  authCubit.signOut();
                },
              ),
            ],
            title: const Text('Home Page'),
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (_, index){
                    
                    return messages[index].isUser ? 
                    Card(
                      margin: const EdgeInsets.only(left: 100,right: 10),
                      color: Colors.grey[200],
                      child: ListTile(
                        title: Text(messages[index].message ?? ''),
                        subtitle: const Text('User') 
                      ),
                    ) : ListTile(
                      title: Text(messages[index].message ?? ''),
                      subtitle: const Text('AI')
                    );
          })),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Type a message',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        String message = _messageController.text.trim();
                        if (message.isNotEmpty) {
                          context.read<MessageCubit>().sendAiMessages(Message(message: message));
                          _messageController.clear();
                        }
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        );

   }
  );
 }
 
}