import 'package:dio/dio.dart';
import 'package:hrm_app/core/network/api_envelope.dart';
import 'package:hrm_app/core/network/api_error_mapper.dart';
import 'package:hrm_app/features/authentication/data/dto/auth_session_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  });
  Future<Map<String, dynamic>> me();
  Future<void> logout(String refreshToken);
}

class DioAuthRemoteDataSource implements AuthRemoteDataSource {
  const DioAuthRemoteDataSource(this._dio);
  final Dio _dio;

  @override
  Future<AuthSessionDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthSessionDto.fromLoginJson(
        ApiEnvelope.fromJson(response.data ?? const {}).requireObjectData(),
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<Map<String, dynamic>> me() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      return ApiEnvelope.fromJson(
        response.data ?? const {},
      ).requireObjectData();
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  @override
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/auth/logout',
        data: {'refreshToken': refreshToken},
      );
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}
