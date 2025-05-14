import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/auth/data/firebase_auth_repo.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_cubit.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_state.dart';
import 'package:flutter_application_1/features/auth/presenatiton/pages/auth_pages.dart';
import 'package:flutter_application_1/features/data/gemini_ai_service.dart';
import 'package:flutter_application_1/features/domain/repositories/message_ai_repo.dart';
import 'package:flutter_application_1/features/presentation/cubits/message_ai_cubit.dart';
import 'package:flutter_application_1/features/presentation/pages/home_page.dart';
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

  // This widget is the root of your application.
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: App() // Replace with your SignInPage widget
    );
  }
}

class App extends StatelessWidget{
  App({super.key});
  final authRepo=FirebaseAuthRepo();
  final aiService=GeminiAIService();


  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        //auth cubit
        BlocProvider<AuthCubit>(create: (context) => AuthCubit(authRepository: authRepo)..checkAuth()),
        //message cubit
        BlocProvider<MessageCubit>(create: (context) => MessageCubit(messageAiRepo: MessageAiRepo(aiService: aiService)),)],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: BlocConsumer<AuthCubit,AuthState>(builder: (context,authState){
          if( authState is AuthLoading){
            return const Center(child: CircularProgressIndicator(),);
          }
          else if (authState is AuthAuthenticated){
            return const HomePage();
          }
          else if (authState is AuthUnauthenticated){
            return const AuthPages();
          }
          else if (authState is AuthError){
            return Scaffold(
              body: Center(
                child: Text(authState.message),
              ),
            );
          }
          return const AuthPages();
        }, listener: (context, authState){
          if (authState is AuthError){
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(authState.message),
              ),
            );
          }
        }
      ),)
    );
    
}}