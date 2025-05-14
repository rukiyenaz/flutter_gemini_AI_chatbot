import 'package:flutter_application_1/features/auth/domain/entities/app_user.dart';
import 'package:flutter_application_1/features/auth/domain/repositories/auth_repo.dart';
import 'package:flutter_application_1/features/auth/presenatiton/cubits/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepository authRepository;
  AppUser? _currentUser;

  AuthCubit({required this.authRepository}) : super(AuthInitial());

   //check if user is authenticated
    void checkAuth() async{
      final AppUser? user = await authRepository.getCurrentUser();
      if (user != null){
        emit(AuthAuthenticated(user));
      }
      else{
        emit(AuthUnauthenticated());
      }
    }

   //get current user
   AppUser? get currentUser => _currentUser;
   //sign in with email and password
   Future<void> signInWithEmailAndPassword(String email,String password)async {
    try{
      emit(AuthLoading());
      final user = await authRepository.signInWithEmailAndPassword(email, password);
      if (user != null){
        _currentUser = user;
        emit(AuthAuthenticated(user));
      }
      else{
        emit(AuthError(message: "Invalid email or password"));
      }
    }
    catch(e){
      emit(AuthError(message: e.toString()));
    }
   }

   //sign up with email and password
    Future<void> signUpWithEmailAndPassword(String name,String email,String password)async {
      try{
        emit(AuthLoading());
        final user = await authRepository.signUpWithEmailAndPassword(name, email, password);
        if (user != null){
          _currentUser = user;
          emit(AuthAuthenticated(user));
        }
        else{
          emit(AuthError(message: "Invalid email or password"));
        }
      }
      catch(e){
        emit(AuthError(message: e.toString()));
      }
    }

    //sign out
    Future<void> signOut() async {
      try{
        emit(AuthLoading());
        await authRepository.signOut();
        _currentUser = null;
        emit(AuthUnauthenticated());
      }
      catch(e){
        emit(AuthError(message: e.toString()));
      }
    }
}