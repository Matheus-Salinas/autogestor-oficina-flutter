import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';

/// Tela de Login do sistema da oficina.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _authService = AuthService();
  bool _carregando = false;

  /// Executa a validação do formulário e chama o serviço de login.
  Future<void> _realizarLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      await _authService.login(
        _emailController.text,
        _senhaController.text,
      );

      if (!mounted) return;
      // Navega para a tela principal substituindo a tela de login
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ícone e título personalizados da Oficina
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.build_circle_outlined,
                      size: 64,
                      color: Colors.amber.shade900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AutoGestor Oficina',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Controle de Ordens de Serviço e Manutenção',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),

                  // Campo de E-mail
                  CustomTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    hint: 'mecanico@oficina.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe o seu e-mail';
                      }
                      if (!valor.contains('@')) {
                        return 'Digite um e-mail válido';
                      }
                      return null;
                    },
                  ),

                  // Campo de Senha
                  CustomTextField(
                    controller: _senhaController,
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (valor) {
                      if (valor == null || valor.trim().isEmpty) {
                        return 'Informe a sua senha';
                      }
                      if (valor.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Botão Entrar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _carregando ? null : _realizarLogin,
                      child: _carregando
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'ENTRAR NO SISTEMA',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Link para Cadastro
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text(
                      'Não possui conta? Cadastre-se aqui',
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}