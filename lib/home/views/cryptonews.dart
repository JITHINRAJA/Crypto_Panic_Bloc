import 'package:crypto_with_bloc/home/bloc/crypto_bloc.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:crypto_with_bloc/home/repositories/crypto_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'news_details.dart';

class CryptoNews extends StatelessWidget {
  const CryptoNews({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(

        ///LoadApi events
        create: (context) => CryptoBloc(
              RepositoryProvider.of<CryptoRepository>(context),
            )..add(LoadApiEvent()),
        child: Scaffold(
            body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<CryptoBloc, CryptoState>(
            builder: (context, state) {
              Future.delayed(const Duration(seconds: 1), () {
                context.read<CryptoBloc>().add(LoadApiEvent());
              });
              if (state is CryptoLoadingState) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              }
              if (state is CryptoLoadedState) {
                return RefreshIndicator(
                  color: Colors.red,

                  ///Implemet Refresh
                  onRefresh: () async {
                    context.read<CryptoBloc>().add(LoadApiEvent());
                  },
                  child: ListView.builder(
                      itemCount: state.results!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(

                                    ///Navigate to News Details Screen
                                    builder: (context) => CryptoNewsDetails(
                                        index: index, state: state)));
                          },
                          child: Column(
                            children: [
                              Container(
                                  child: Row(
                                children: [
                                  Container(
                                    child: Text(timeago.format(
                                        state.results![index].publishedAt!
                                            .subtract(
                                                const Duration(minutes: 1)),
                                        locale: 'en_short')),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                          text: state.results![index].title!),
                                      TextSpan(
                                          text:
                                              '🔗${state.results![index].source?.domain}',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontFamily: 'Open_Sans'),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              ///launch to the domain
                                              launchUrl(Uri.parse(
                                                  'https://${state.results![index].source?.domain}'));
                                            })
                                    ])),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Text(
                                      '${state.results![index].currencies?[0].code ?? ''}',
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w700,
                                          fontFamily: 'Open_Sans'),
                                    ),
                                  )
                                ],
                              )),
                              Divider(
                                color: Colors.white,
                              ),
                            ],
                          ),
                        );
                      }),
                );
              }
              return Container();
            },
          ),
        )));
  }
}
