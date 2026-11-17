import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';


// ============================================================================
// CONFIGURAÇÃO DE LIGAÇÃO AO SUPABASE (PROJETO: oficina-p2)
// ============================================================================

/// Endereço URL do teu projeto Supabase (já preenchido com o ID do teu projeto).
const String supabaseUrl = 'https://nbsphkfaluxczedesggy.supabase.co';

/// Chave pública do Supabase:
/// Apaga o texto abaixo e cola a chave que copiaste no botão da 'Publishable key'.
const String supabaseAnonKey = 'sb_publishable_miP3xipTkMoCox4XwhYXkQ_nvxMoPNO';

// ============================================================================
// FUNÇÃO PRINCIPAL DA APLICAÇÃO
// ============================================================================

Future<void> main() async {
  // Garante que os recursos nativos do Flutter estão prontos antes de iniciar
  WidgetsFlutterBinding.ensureInitialized();

  // Estabelece a ligação segura com o teu projeto no Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Inicia a aplicação AutoGestor Oficina
  runApp(const OficinaApp());
}

/// Componente raiz que gere o tema visual, a sessão inicial e as rotas de navegação.
class OficinaApp extends StatelessWidget {
  const OficinaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Verifica se já existe um utilizador autenticado no dispositivo
    final bool sessaoAtiva = Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      title: 'AutoGestor Oficina',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Parâmetro ajustável: podes alterar a cor principal da aplicação aqui
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      // Proteção inicial de rota: envia para o painel apenas se estiver autenticado
      initialRoute: sessaoAtiva ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}