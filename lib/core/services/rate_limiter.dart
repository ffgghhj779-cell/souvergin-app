/// Client-side rate limiter for form submissions.
///
/// Prevents a user from submitting the same form repeatedly
/// within a cooldown window. This is a UX + lightweight abuse-
/// prevention guard. Server-side RLS policies are the real gate.
class RateLimiter {
  final Duration cooldown;
  DateTime? _lastSubmission;

  RateLimiter({this.cooldown = const Duration(seconds: 30)});

  /// Returns true if the user is allowed to submit now.
  bool get canSubmit {
    if (_lastSubmission == null) return true;
    return DateTime.now().difference(_lastSubmission!) >= cooldown;
  }

  /// Remaining seconds before the next submission is allowed.
  /// Returns 0 if [canSubmit] is true.
  int get secondsRemaining {
    if (canSubmit) return 0;
    final elapsed = DateTime.now().difference(_lastSubmission!);
    return (cooldown - elapsed).inSeconds.clamp(0, cooldown.inSeconds);
  }

  /// Record a successful submission timestamp.
  void recordSubmission() => _lastSubmission = DateTime.now();

  /// Reset the limiter (e.g. after a hard navigation away).
  void reset() => _lastSubmission = null;
}
