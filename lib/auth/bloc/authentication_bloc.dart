import 'dart:async';
import 'package:crypto_with_bloc/auth/data/repositories/authenticaiton_repository.dart';
import 'package:crypto_with_bloc/auth/models/authentication_detail.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;

  AuthenticationBloc(
      {required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(AuthenticationInitial());

  StreamSubscription<AuthenticationDetail>? authStreamSub;

  @override

  ///close the stream to avoid memory leake issue
  Future<void> close() {
    authStreamSub?.cancel();
    return super.close();
  }

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AuthenticationStarted) {
      try {
        emit(AuthenticationLoading());
        authStreamSub = _authenticationRepository
            .getAuthDetailStream()
            .listen((authDetail) {
          add(AuthenticationStateChanged(authenticationDetail: authDetail));
        });
      } catch (error) {
        print(
            'Error occured while fetching authentication detail : ${error.toString()}');
        emit(AuthenticationFailiure(
            message: 'Error occrued while fetching auth detail'));
      }
    } else if (event is AuthenticationStateChanged) {
      if (event.authenticationDetail.isValid!) {
        emit(AuthenticationSuccess(
            authenticationDetail: event.authenticationDetail));
      } else {
        emit(AuthenticationFailiure(message: 'User has logged out'));
      }
    } else if (event is AuthenticationGoogleStarted) {
      try {
        emit(AuthenticationLoading());
        AuthenticationDetail authenticationDetail =
            await _authenticationRepository.authenticateWithGoogle();

        if (authenticationDetail.isValid!) {
          emit(AuthenticationSuccess(
              authenticationDetail: authenticationDetail));
        } else {
          emit(AuthenticationFailiure(message: 'User detail not found.'));
        }
      } catch (error) {
        print('Error occured while login with Google ${error.toString()}');
        emit(AuthenticationFailiure(
          message: 'Unable to login with Google. Try again.',
        ));
      }
    } else if (event is AuthenticationExited) {
      try {
        emit(AuthenticationLoading());
        await _authenticationRepository.unAuthenticate();
      } catch (error) {
        print('Error occured while logging out. : ${error.toString()}');
        emit(AuthenticationFailiure(
            message: 'Unable to logout. Please try again.'));
      }
    }
  }
}
