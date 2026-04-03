// lib/domain/usecases/auth/login_usecase.dart
import '../../entities/user.dart';
import '../../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<({UserEntity user, String token})> execute({
    required String email,
    required String password,
    required String userType,
  }) async {
    if (email.isEmpty) {
      throw Exception('Email is required');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }
    
    return await repository.login(
      email: email,
      password: password,
      userType: userType,
    );
  }
}