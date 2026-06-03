import '../models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> getCurrentUser();
  Future<UserProfile> signInWithGoogle();
  Future<void> signOut();
  Stream<UserProfile?> get authStateChanges;
}

// Placeholder — replace with real Supabase implementation once credentials are registered.
class SupabaseAuthRepository implements AuthRepository {
  // TODO: inject SupabaseClient once supabase_flutter is configured
  // final SupabaseClient _client;

  @override
  Future<UserProfile?> getCurrentUser() async {
    // TODO: return UserProfile.fromJson(_client.auth.currentUser!.userMetadata!)
    return null;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    // TODO: await _client.auth.signInWithOAuth(OAuthProvider.google)
    // For now return a guest profile so UI can be developed
    return UserProfile(
      id: 'guest-001',
      displayName: '게스트',
      email: 'guest@puzzlebox.app',
      totalPoints: 0,
      gamesPlayed: 0,
      streakDays: 1,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    // TODO: await _client.auth.signOut()
  }

  @override
  Stream<UserProfile?> get authStateChanges async* {
    // TODO: yield* _client.auth.onAuthStateChange.map(...)
    yield null;
  }
}
