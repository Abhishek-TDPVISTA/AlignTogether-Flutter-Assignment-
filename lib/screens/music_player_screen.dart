import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:melodyvue/blocs/music_player/music_player_bloc.dart';

class MusicPlayerScreen extends StatefulWidget {
  final String musicUrl =
      "https://codeskulptor-demos.commondatastorage.googleapis.com/descent/background%20music.mp3";

  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  late PlayerController _playerController;
  late String localFilePath;
  late Timer _positionUpdateTimer;
  late Duration _songDuration;

  @override
  void initState() {
    super.initState();
    _playerController = PlayerController();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Step 1: Download the audio file to a local path
      localFilePath = await _downloadAudioFile(widget.musicUrl);

      // Step 2: Prepare the player
      await _playerController.preparePlayer(
        path: localFilePath,
        shouldExtractWaveform: true, // Ensure waveform extraction
      );

      // Step 3: Get the song's duration (in milliseconds)
      int durationInMilliseconds = await _playerController.getDuration();

      // Convert the duration from milliseconds to Duration type
      _songDuration = Duration(milliseconds: durationInMilliseconds);

      // Step 4: Start a timer to periodically update the waveform
      _positionUpdateTimer = Timer.periodic(
        const Duration(milliseconds: 500), // Update every 500 ms
        (timer) {
          setState(() {
            // Trigger a rebuild on position change
          });
        },
      );
    } catch (e) {
      print("Error initializing player: $e");
    }
  }

  Future<String> _downloadAudioFile(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_audio.mp3');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception("Failed to download audio file.");
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    _positionUpdateTimer.cancel(); // Cancel the position update timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<MusicPlayerBloc>(context);

    // Convert the duration into a string format (minutes:seconds)
    String formatDuration(Duration duration) {
      int minutes = duration.inMinutes;
      int seconds = duration.inSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/album.jpeg',
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    offset: const Offset(0, -5),
                    blurRadius: 15,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color.fromARGB(240, 0, 0, 0),
                    const Color.fromARGB(255, 27, 26, 26),
                    const Color(0xBF313131).withAlpha(255),
                  ],
                ),
                borderRadius: const BorderRadius.all(Radius.circular(40)),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 36, left: 25),
                    child: Text(
                      'Instant Crush',
                      style: TextStyle(
                        fontSize: 34,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 201, 196, 196),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.only(left: 25),
                    child: Text(
                      'feat. Julian Casablancas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(137, 247, 247, 247),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                    builder: (context, state) {
                      return GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          final width = MediaQuery.of(context).size.width;
                          final positionRatio =
                              details.localPosition.dx / width;
                          final seekTo =
                              state.duration * positionRatio.clamp(0.0, 1.0);
                          _playerController.seekTo(seekTo.inMilliseconds);
                          bloc.seekTo(seekTo);
                        },
                        child: AudioFileWaveforms(
                          playerController: _playerController,
                          size: Size(
                            MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height * 0.09,
                          ),
                          playerWaveStyle: const PlayerWaveStyle(
                            fixedWaveColor: Colors.white,
                            liveWaveColor: Colors.white,
                            backgroundColor: Colors.transparent,
                            waveThickness: 2.0,
                            showSeekLine: true,
                            seekLineThickness: 2.0,
                            seekLineColor: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),
                  // Display song duration below the waveform
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      formatDuration(_songDuration),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(137, 247, 247, 247),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.center,
                    child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                      builder: (context, state) {
                        return IconButton(
                          padding: const EdgeInsets.only(top: 50),
                          icon: Icon(
                            state.isPlaying
                                ? Icons.pause_circle
                                : Icons.play_circle,
                            size: 65,
                            color: Color.fromARGB(
                              240,
                              237,
                              237,
                              237,
                            ),
                          ),
                          onPressed: () {
                            if (state.isPlaying) {
                              bloc.pauseMusic();
                              _playerController.pausePlayer();
                            } else {
                              bloc.playMusic(localFilePath);
                              _playerController.startPlayer();
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
