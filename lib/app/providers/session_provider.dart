import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/token_storage.dart';

enum SessionStatus { authenticated, unauthenticated }

final sessionProvider = AsyncNotifierProvider<SessionController, SessionStatus>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<SessionStatus> {
  @override
  Future<SessionStatus> build() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    return token == null
        ? SessionStatus.unauthenticated
        : SessionStatus.authenticated;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(tokenStorageProvider).clear();
    state = const AsyncData(SessionStatus.unauthenticated);
  }
}
