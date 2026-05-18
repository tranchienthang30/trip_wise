import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session.dart';
import 'api_client.dart';
import 'auth_api.dart';
import 'devices_api.dart';
import 'push_messaging_service.dart';

class AuthSessionStore extends ChangeNotifier {
  AuthSessionStore._();

  static final AuthSessionStore instance = AuthSessionStore._();

  static const String _storageKey = 'tripwise.auth.session';
  static const String _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  final AuthApi _authApi = AuthApi();

  SharedPreferences? _preferences;
  AuthSessionData? _session;
  bool _isReady = false;
  bool _didAttachInterceptor = false;
  bool _googleInitialized = false;

  bool get isReady => _isReady;
  bool get isAuthenticated => _session != null && !_session!.isExpired;
  AuthSessionData? get session => _session;

  Future<void> initialize() async {
    if (_isReady) return;
    _attachUnauthorizedInterceptor();
    _preferences = await SharedPreferences.getInstance();

    final raw = _preferences?.getString(_storageKey);
    if (raw != null && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          final session = AuthSessionData.fromStoredJson(decoded);
          if (!session.isExpired && session.token.trim().isNotEmpty) {
            _setSession(session, notify: false);
          } else {
            await _clearLocal(notify: false);
          }
        }
      } catch (_) {
        await _clearLocal(notify: false);
      }
    }

    _isReady = true;
    notifyListeners();
  }

  Future<AuthSessionData> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final session = await _authApi.register(
      fullName: fullName,
      email: email,
      password: password,
      phone: phone,
    );
    await _persistSession(session);
    await syncPushToken();
    return session;
  }

  Future<AuthSessionData> login({
    required String email,
    required String password,
  }) async {
    final session = await _authApi.login(email: email, password: password);
    await _persistSession(session);
    await syncPushToken();
    return session;
  }

  Future<AuthSessionData> signInWithGoogle() async {
    try {
      UserCredential credential;

      if (kIsWeb) {
        credential = await FirebaseAuth.instance.signInWithPopup(
          GoogleAuthProvider(),
        );
      } else {
        await _ensureGoogleInitialized();
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        final googleIdToken = googleAuth.idToken;

        if (googleIdToken == null || googleIdToken.trim().isEmpty) {
          throw AuthApiError('Google did not return an ID token');
        }

        final authCredential = GoogleAuthProvider.credential(
          idToken: googleIdToken,
        );
        credential = await FirebaseAuth.instance.signInWithCredential(
          authCredential,
        );
      }

      final firebaseIdToken = await credential.user?.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.trim().isEmpty) {
        throw AuthApiError('Unable to complete Google sign-in');
      }

      final session = await _authApi.signInWithGoogle(idToken: firebaseIdToken);
      await _persistSession(session);
      await syncPushToken();
      return session;
    } on FirebaseAuthException catch (error) {
      throw AuthApiError(error.message ?? 'Google sign-in failed');
    } on GoogleSignInException catch (error) {
      throw AuthApiError(error.description ?? 'Google sign-in failed');
    }
  }

  Future<void> logout() async {
    await _unregisterPushToken();
    try {
      await _authApi.logout();
    } catch (_) {
      // Best-effort remote logout; local sign-out still wins.
    } finally {
      await _signOutFromGoogleProviders();
      await _clearLocal();
    }
  }

  Future<void> syncPushToken() async {
    if (!isAuthenticated || !PushMessagingService.isSupported) return;
    final token = await PushMessagingService.getToken();
    if (token == null || token.trim().isEmpty) return;
    await DeviceApi().registerToken(token);
  }

  Future<void> _persistSession(AuthSessionData session) async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    await prefs.setString(_storageKey, jsonEncode(session.toStoredJson()));
    _setSession(session);
  }

  void _setSession(AuthSessionData? session, {bool notify = true}) {
    _session = session;
    ApiClient.instance.setAuthToken(session?.token);
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _clearLocal({bool notify = true}) async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    _preferences = prefs;
    await prefs.remove(_storageKey);
    _setSession(null, notify: notify);
  }

  Future<void> _unregisterPushToken() async {
    if (!isAuthenticated || !PushMessagingService.isSupported) return;
    final token = await PushMessagingService.getToken();
    if (token == null || token.trim().isEmpty) return;
    await DeviceApi().unregisterToken(token);
  }

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized || kIsWeb) return;
    if (_googleServerClientId.trim().isEmpty) {
      throw AuthApiError(
        'Google Sign-In on Android needs GOOGLE_SERVER_CLIENT_ID. Run Flutter with --dart-define=GOOGLE_SERVER_CLIENT_ID=your_web_client_id.',
      );
    }
    await GoogleSignIn.instance.initialize(
      serverClientId: _googleServerClientId,
    );
    _googleInitialized = true;
  }

  Future<void> _signOutFromGoogleProviders() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {
      // Best-effort.
    }
  }

  void _attachUnauthorizedInterceptor() {
    if (_didAttachInterceptor) return;
    _didAttachInterceptor = true;
    ApiClient.instance.dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final path = error.requestOptions.path;
          final isAuthMutation =
              path.endsWith('/auth/login') || path.endsWith('/auth/register');

          if (status == 401 && _session != null && !isAuthMutation) {
            await _clearLocal();
          }

          handler.next(error);
        },
      ),
    );
  }
}
