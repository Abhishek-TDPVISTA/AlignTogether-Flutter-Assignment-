abstract class MusicPlayerEvent {}

class PlayMusic extends MusicPlayerEvent {
  final String trackUrl;
  PlayMusic({required this.trackUrl});
}

class PauseMusic extends MusicPlayerEvent {}

class ResumeMusic extends MusicPlayerEvent {}

class StopMusic extends MusicPlayerEvent {}
