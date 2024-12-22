import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:melodyvue/blocs/music_player/music_player_bloc.dart';
import 'package:melodyvue/screens/music_player_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => MusicPlayerBloc(),
        child: MusicPlayerScreen(),
      ),
    );
  }
}
