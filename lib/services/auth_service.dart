import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável por gerenciar a autenticação de usuários no Supabase.
class AuthService {
  // Instância do cliente Supabase
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna o usuário atualmente autenticado (ou null se estiver deslogado).
  User? get usuarioAtual => _supabase.auth.currentUser;

  /// Realiza o login com e-mail e senha.
  Future<void> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on AuthException catch (e) {
      throw Exception(_traduzirErroAuth(e.message));
    } catch (_) {
      throw Exception('Erro inesperado ao tentar fazer login.');
    }
  }

  /// Cadastra um novo usuário no Supabase Auth.
  Future<void> registrar(String email, String password) async {
    try {
      await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
    } on AuthException catch (e) {
      throw Exception(_traduzirErroAuth(e.message));
    } catch (_) {
      throw Exception('Erro inesperado ao criar conta.');
    }
  }

  /// Encerra a sessão do usuário atual (Logout).
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Traduz mensagens de erro do Supabase para português claro.
  String _traduzirErroAuth(String mensagemOriginal) {
    final msg = mensagemOriginal.toLowerCase();
    if (msg.contains('invalid login credentials')) {
      return 'E-mail ou senha incorretos.';
    } else if (msg.contains('user already registered')) {
      return 'Este e-mail já está cadastrado no sistema.';
    } else if (msg.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    } else if (msg.contains('invalid format') || msg.contains('unable to validate email')) {
      return 'Formato de e-mail inválido.';
    }
    return 'Erro de autenticação: $mensagemOriginal';
  }
}