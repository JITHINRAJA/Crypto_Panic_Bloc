import 'package:crypto_with_bloc/auth/bloc/authentication_bloc.dart';
import 'package:crypto_with_bloc/home/views/cryptonews.dart';
import 'package:crypto_with_bloc/login/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ///assign current user from firebase to user
    final user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Crypto_Panic',
            style: TextStyle(fontFamily: 'Open_Sans'),
          ),
          actions: [
            Row(
              children: [
                ///Display the username from user
                Text('${user?.displayName}'),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.logout,
                  ),
                  onPressed: () =>

                      ///Exit from user
                      BlocProvider.of<AuthenticationBloc>(context).add(
                    AuthenticationExited(),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Center(
          child: BlocConsumer<AuthenticationBloc, AuthenticationState>(
            listener: (context, state) {
              if (state is AuthenticationFailiure) {
                ///if authentication failed navigate to login page again
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginPage()));
              }
            },
            builder: (context, state) {
              if (state is AuthenticationInitial) {
                BlocProvider.of<AuthenticationBloc>(context)
                    .add(AuthenticationStarted());
                return CircularProgressIndicator(
                  color: Colors.red,
                );
              } else if (state is AuthenticationLoading) {
                return CircularProgressIndicator(
                  color: Colors.red,
                );
              } else if (state is AuthenticationSuccess) {
                ///if authentication success the news page display
                return CryptoNews();
              }
              return Text('Undefined state : ${state.runtimeType}');
            },
          ),
        ),
      ),
    );
  }
}
