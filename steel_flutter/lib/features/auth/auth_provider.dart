import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../core/pocketbase.dart';

enum AuthStatus { unknown, unauthenticated, authenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.isBusy = false,
    this.errorMessage,
    this.userId,
    this.email,
  });

  final AuthStatus status;
  final bool isBusy;
  final String? errorMessage;
  final String? userId;
  final String? email;

  AuthState copyWith({
    AuthStatus? status,
    bool? isBusy,
    String? errorMessage,
    String? userId,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: errorMessage,
      userId: userId ?? this.userId,
      email: email ?? this.email,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier();
  notifier.init();
  return notifier;
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState(status: AuthStatus.unknown));

  Future<PocketBase> _pb() => SteelPocketBase.instance();

  Future<void> init() async {
    state = state.copyWith(isBusy: true, errorMessage: null);
    try {
      final pb = await _pb();
      if (pb.authStore.isValid) {
        final record = pb.authStore.record;
        state = AuthState(
          status: AuthStatus.authenticated,
          isBusy: false,
          userId: record?.id,
          email: record?.data['email'] as String?,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated, isBusy: false);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isBusy: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isBusy: true, errorMessage: null);
    try {
      final pb = await _pb();
      final auth = await pb.collection('users').authWithPassword(email, password);
      state = AuthState(
        status: AuthStatus.authenticated,
        isBusy: false,
        userId: auth.record.id,
        email: auth.record.data['email'] as String? ?? email,
      );
    } catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.toString());
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    state = state.copyWith(isBusy: true, errorMessage: null);
    try {
      final pb = await _pb();
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': passwordConfirm,
      });
      await pb.collection('users').authWithPassword(email, password);
      await init();
    } catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isBusy: true, errorMessage: null);
    try {
      final pb = await _pb();
      pb.authStore.clear();
      state = const AuthState(status: AuthStatus.unauthenticated, isBusy: false);
    } catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.toString());
    }
  }
}

