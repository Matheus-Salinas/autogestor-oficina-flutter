import 'package:flutter/material.dart';
import '../models/manutencao_model.dart';

/// Cartão personalizado para exibir os dados de uma manutenção na lista.
class ManutencaoCard extends StatelessWidget {
  final ManutencaoModel manutencao;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ManutencaoCard({
    super.key,
    required this.manutencao,
    required this.onEdit,
    required this.onDelete,
  });

  /// Define a cor da etiqueta conforme o status da ordem de serviço.
  Color _obterCorStatus(String status) {
    switch (status) {
      case 'Concluído':
        return Colors.green.shade700;
      case 'Em Andamento':
        return Colors.blue.shade700;
      default:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final corStatus = _obterCorStatus(manutencao.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha superior: Nome do veículo e etiqueta de Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.directions_car, color: Colors.blueGrey.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          manutencao.veiculo,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: corStatus.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: corStatus),
                  ),
                  child: Text(
                    manutencao.status,
                    style: TextStyle(
                      color: corStatus,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Placa do veículo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Placa: ${manutencao.placa}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Descrição do serviço
            Text(
              'Serviço: ${manutencao.servico}',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 6),

            // Mecânico responsável
            Row(
              children: [
                Icon(
                  Icons.engineering_outlined,
                  size: 16,
                  color: Colors.blueGrey.shade600,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Mecânico: ${manutencao.mecanico.isEmpty ? 'Não informado' : manutencao.mecanico}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Linha inferior: Valor formatado e Botões de Ação (Editar / Excluir)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'R\$ ${manutencao.valor.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                      tooltip: 'Editar Ordem de Serviço',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Excluir Ordem de Serviço',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}