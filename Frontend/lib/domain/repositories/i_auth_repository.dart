// lib/domain/repositories/i_auth_repository.dart
import '../entities/user.dart';

abstract class IAuthRepository {
  Future<({UserEntity user, String token})> login({
    required String email,
    required String password,
    required String userType,
  });
  
  Future<({UserEntity user, String token})> register({
    required Map<String, dynamic> userData,
    required String password,
  });
  
  Future<UserEntity> getProfile(String token);
  
  Future<void> logout();
  
  Future<void> saveToken(String token);
  
  Future<String?> getToken();
  
  Future<void> clearToken();
}