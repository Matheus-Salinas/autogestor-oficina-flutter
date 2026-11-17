import 'package:flutter/material.dart';
import '../models/manutencao_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/manutencao_card.dart';
import 'form_screen.dart';

/// Tela Principal (protegida) que lista e gerencia as manutenções.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _dbService = DatabaseService();

  List<ManutencaoModel> _listaManutencoes = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _verificarAutenticacaoECarregar();
  }

  /// Proteção de tela: verifica se o usuário está logado antes de buscar dados.
  void _verificarAutenticacaoECarregar() {
    if (_authService.usuarioAtual == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }
    _carregarManutencoes();
  }

  /// Busca as ordens de serviço no banco de dados Supabase.
  Future<void> _carregarManutencoes() async {
    setState(() => _carregando = true);
    try {
      final dados = await _dbService.listarManutencoes();
      if (mounted) {
        setState(() => _listaManutencoes = dados);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Abre a tela de formulário para criar ou editar uma manutenção.
  Future<void> _abrirFormulario({ManutencaoModel? manutencao}) async {
    final atualizou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormScreen(manutencaoParaEditar: manutencao),
      ),
    );

    if (atualizou == true) {
      _carregarManutencoes();
    }
  }

  /// Exibe confirmação e exclui uma manutenção do banco de dados.
  Future<void> _confirmarExclusao(ManutencaoModel manutencao) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Deseja realmente excluir a ordem de serviço do veículo "${manutencao.veiculo}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmar == true && manutencao.id != null) {
      try {
        await _dbService.deletarManutencao(manutencao.id!);
        _carregarManutencoes();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordem de serviço excluída com sucesso!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  /// Realiza o logout e retorna para a tela de login.
  Future<void> _realizarLogout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final emailUsuario = _authService.usuarioAtual?.email ?? '';
    final valorTotal = _listaManutencoes.fold<double>(
      0.0,
      (soma, item) => soma + item.valor,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Painel da Oficina'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar Lista',
            onPressed: _carregarManutencoes,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: _realizarLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Cabeçalho com Resumo Financeiro e Quantidade de Veículos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blueGrey.shade800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Operador: $emailUsuario',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _construirResumoBox(
                        titulo: 'Ordens de Serviço',
                        valor: '${_listaManutencoes.length}',
                        icone: Icons.car_repair,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _construirResumoBox(
                        titulo: 'Total Orçado',
                        valor: 'R\$ ${valorTotal.toStringAsFixed(2)}',
                        icone: Icons.payments_outlined,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Lista de Manutenções
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _listaManutencoes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Icon(
                            Icons.directions_car_filled_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nenhuma manutenção cadastrada ainda.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _listaManutencoes.length,
                        itemBuilder: (context, index) {
                          final item = _listaManutencoes[index];
                          return ManutencaoCard(
                            manutencao: item,
                            onEdit: () => _abrirFormulario(manutencao: item),
                            onDelete: () => _confirmarExclusao(item),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Nova OS',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _construirResumoBox({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icone, color: Colors.amber.shade400, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}