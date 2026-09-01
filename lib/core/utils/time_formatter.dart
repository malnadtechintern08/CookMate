class TimeFormatter {
  static String formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final int hours = minutes ~/ 60;
    final int remainingMins = minutes % 60;
    if (remainingMins == 0) {
      return '${hours}h';
    }
    return '${hours}h ${remainingMins}m';
  }

  static String formatSeconds(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    if (seconds == 0) {
      return '$minutes mins';
    }
    return '${minutes}m ${seconds}s';
  }

  static String formatSecondsToTimer(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
