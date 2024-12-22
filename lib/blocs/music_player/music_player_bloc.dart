import 'package:bloc/bloc.dart';
import 'package:just_audio/just_audio.dart';

class MusicPlayerState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;

  MusicPlayerState({
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  MusicPlayerState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
  }) {
    return MusicPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}

class MusicPlayerBloc extends Cubit<MusicPlayerState> {
  final AudioPlayer _audioPlayer;

  MusicPlayerBloc()
      : _audioPlayer = AudioPlayer(),
        super(MusicPlayerState()) {
    // Update position and duration
    _audioPlayer.positionStream.listen((position) {
      emit(state.copyWith(position: position));
    });
    _audioPlayer.durationStream.listen((duration) {
      emit(state.copyWith(duration: duration));
    });

    // Monitor playback state
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        emit(state.copyWith(isPlaying: false, position: Duration.zero));
      } else {
        emit(state.copyWith(isPlaying: playerState.playing));
      }
    });
  }

  Future<void> playMusic(String url) async {
    try {
      await _audioPlayer.setFilePath(url);
      await _audioPlayer.play();
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  Future<void> pauseMusic() async {
    await _audioPlayer.pause();
  }

  @override
  Future<void> close() async {
    await _audioPlayer.dispose();
    return super.close();
  }

  void seekTo(Duration position) {
    _audioPlayer.seek(position);
    emit(state.copyWith(position: position));
  }
}
