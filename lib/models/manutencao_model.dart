/// Modelo que representa uma Ordem de Serviço (Manutenção) na oficina.
class ManutencaoModel {
  final int? id; // Pode ser nulo antes de ser salvo no banco
  final String userId; // ID do usuário dono do registro
  final String veiculo; // Modelo do carro/moto (ex: Chevrolet Corsa 1.6)
  final String placa; // Placa do veículo (ex: ABC-1D23)
  final String servico; // Descrição do serviço realizado
  final String mecanico; // Mecânico responsável pela ordem de serviço
  final double valor; // Valor do orçamento/serviço
  final String status; // 'Pendente', 'Em Andamento' ou 'Concluído'

  ManutencaoModel({
    this.id,
    required this.userId,
    required this.veiculo,
    required this.placa,
    required this.servico,
    required this.mecanico,
    required this.valor,
    required this.status,
  });

  /// Converte um Map (JSON vindo do Supabase) para um objeto ManutencaoModel.
  factory ManutencaoModel.fromMap(Map<String, dynamic> map) {
    return ManutencaoModel(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      veiculo: map['veiculo'] as String,
      placa: map['placa'] as String,
      servico: map['servico'] as String,
      mecanico: (map['mecanico'] as String?) ?? '',
      valor: (map['valor'] as num).toDouble(),
      status: map['status'] as String,
    );
  }

  /// Converte um objeto ManutencaoModel para Map (para enviar ao Supabase).
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'veiculo': veiculo,
      'placa': placa.toUpperCase(),
      'servico': servico,
      'mecanico': mecanico,
      'valor': valor,
      'status': status,
    };
  }
}