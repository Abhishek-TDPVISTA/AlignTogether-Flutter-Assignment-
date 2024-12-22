abstract class MusicPlayerState {}

class MusicPlayerInitial extends MusicPlayerState {}

class MusicPlaying extends MusicPlayerState {
  final Duration currentDuration;
  MusicPlaying({required this.currentDuration});
}

class MusicPaused extends MusicPlayerState {}

class MusicStopped extends MusicPlayerState {}

class MusicError extends MusicPlayerState {
  final String errorMessage;
  MusicError({required this.errorMessage});
}
