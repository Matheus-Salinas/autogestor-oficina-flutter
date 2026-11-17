import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/manutencao_model.dart';

/// Serviço responsável pelas operações de CRUD na tabela 'manutencoes'.
class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _tabela = 'manutencoes';

  /// READ: Busca todas as manutenções cadastradas pelo usuário logado.
  Future<List<ManutencaoModel>> listarManutencoes() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuário não autenticado.');
    }

    final response = await _supabase
        .from(_tabela)
        .select()
        .eq('user_id', userId)
        .order('id', ascending: false);

    // Converte a lista de mapas do banco para uma lista de ManutencaoModel
    return (response as List)
        .map((item) => ManutencaoModel.fromMap(item))
        .toList();
  }

  /// CREATE: Insere uma nova ordem de serviço no banco de dados.
  Future<void> criarManutencao(ManutencaoModel manutencao) async {
    await _supabase.from(_tabela).insert(manutencao.toMap());
  }

  /// UPDATE: Atualiza os dados de uma ordem de serviço existente.
  Future<void> atualizarManutencao(ManutencaoModel manutencao) async {
    if (manutencao.id == null) {
      throw Exception('ID da manutenção não encontrado para atualização.');
    }

    await _supabase
        .from(_tabela)
        .update(manutencao.toMap())
        .eq('id', manutencao.id!);
  }

  /// DELETE: Remove uma ordem de serviço do banco de dados pelo ID.
  Future<void> deletarManutencao(int id) async {
    await _supabase.from(_tabela).delete().eq('id', id);
  }
}