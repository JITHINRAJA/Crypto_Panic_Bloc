import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_with_bloc/auth/bloc/authentication_bloc.dart';

class CryptoNewsDetails extends StatelessWidget {
  const CryptoNewsDetails({this.state, this.index});
  final state;
  final index;

  @override
  Widget build(BuildContext context) {
    ///Assign current user from firebase to user
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'News Details',
          style: TextStyle(fontFamily: 'Open_Sans'),
        ),
        actions: [
          Row(
            children: [
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
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Wrap(
              children: [
                Text(
                  state.results[index].title,
                  style: TextStyle(fontSize: 25, fontFamily: 'Open_Sans'),
                ),
                Text(
                  state.results[index].domain,
                  style:
                      TextStyle(color: Colors.yellow, fontFamily: 'Open_Sans'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
