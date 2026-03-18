import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/data/firebase_auth_repo.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_cubit.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_state.dart';
import 'package:flutter_application_1/features/auth/presenatiton/pages/auth_pages.dart';
import 'package:flutter_application_1/features/data/health_profile_service.dart';
import 'package:flutter_application_1/features/data/gemini_ai_service.dart';
import 'package:flutter_application_1/features/data/conversation_service.dart';
import 'package:flutter_application_1/features/domain/repositories/message_ai_repo.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/profile_cubit.dart';
import 'package:flutter_application_1/features/presentation/cubits/conversation_cubit.dart';
import 'package:flutter_application_1/features/presentation/pages/profile_gate_page.dart';
import 'package:flutter_application_1/features/presentation/widgets/modern_loading.dart';
import 'package:flutter_application_1/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return App();
  }
}

class App extends StatelessWidget{
  App({super.key});
  final authRepo = FirebaseAuthRepo();
  final aiService = GeminiAIService();
  final healthProfileService = HealthProfileService();
  final conversationService = ConversationService();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //auth cubit
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(authRepository: authRepo)..checkAuth(),
        ),
        //message cubit
        BlocProvider<MessageCubit>(
          create: (context) => MessageCubit(
            messageAiRepo: MessageAiRepo(
              aiService: aiService,
              profileService: healthProfileService,
            ),
            conversationService: conversationService,
          ),
        ),
        //profile cubit
        BlocProvider<ProfileCubit>(
          create: (context) =>
              ProfileCubit(healthProfileService: healthProfileService),
        ),
        //conversation cubit
        BlocProvider<ConversationCubit>(
          create: (context) =>
              ConversationCubit(conversationService: conversationService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const _AppRoot(),
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, authState) {
        if (authState is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authState.message)),
          );
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          return Navigator(
            pages: [
              if (authState is AuthLoading || authState is AuthInitial)
                const MaterialPage(
                  key: ValueKey('auth-loading'),
                  child: ModernLoadingScreen(
                    title: 'Doctor AI Hazirlaniyor',
                    subtitle: 'Guvenli oturum kontrol ediliyor',
                  ),
                )
              else if (authState is AuthAuthenticated)
                MaterialPage(
                  key: const ValueKey('auth-profile-gate'),
                  child: ProfileGatePage(user: authState.user),
                )
              else
                const MaterialPage(
                  key: ValueKey('auth-pages'),
                  child: AuthPages(),
                ),
            ],
            onDidRemovePage: (page) {},
          );
        },
      ),
    );
  }
}