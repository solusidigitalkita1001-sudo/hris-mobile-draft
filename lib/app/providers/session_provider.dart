import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/authentication/authentication_providers.dart';

enum SessionStatus { authenticated, unauthenticated }

final sessionProvider = AsyncNotifierProvider<SessionController, SessionStatus>(
  SessionController.new,
);

class SessionController extends AsyncNotifier<SessionStatus> {
  @override
  Future<SessionStatus> build() async {
    final session = await ref.watch(authControllerProvider.future);
    return session == null
        ? SessionStatus.unauthenticated
        : SessionStatus.authenticated;
  }

  Future<void> signOut() async {
    await ref.read(authControllerProvider.notifier).logout();
  }
}
