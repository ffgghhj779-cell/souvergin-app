/// Tracks whether Firebase was successfully initialized at startup.
///
/// Encapsulated to prevent uncontrolled mutation from outside this file.
/// Only [setFirebaseReady] may transition the state to `true`.
/// All Firebase-dependent code must check [firebaseReady] before use.
bool _firebaseReady = false;

/// Returns `true` if Firebase initialized successfully at app startup.
bool get firebaseReady => _firebaseReady;

/// Called exactly once from `main()` after [Firebase.initializeApp] succeeds.
/// Idempotent — calling more than once is a no-op.
void setFirebaseReady() {
  if (!_firebaseReady) _firebaseReady = true;
}
