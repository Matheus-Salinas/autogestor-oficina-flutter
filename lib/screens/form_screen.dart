import 'package:flutter/material.dart';
import '../models/manutencao_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../widgets/custom_text_field.dart';

/// Tela de formulário para Criar ou Editar uma Ordem de Serviço.
class FormScreen extends StatefulWidget {
  final ManutencaoModel? manutencaoParaEditar;

  const FormScreen({super.key, this.manutencaoParaEditar});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _veiculoController = TextEditingController();
  final _placaController = TextEditingController();
  final _servicoController = TextEditingController();
  final _valorController = TextEditingController();

  String _statusSelecionado = 'Pendente';
  final List<String> _opcoesStatus = ['Pendente', 'Em Andamento', 'Concluído'];

  final _dbService = DatabaseService();
  final _authService = AuthService();
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    // Se for edição, preenche os campos com os dados atuais da manutenção
    final item = widget.manutencaoParaEditar;
    if (item != null) {
      _veiculoController.text = item.veiculo;
      _placaController.text = item.placa;
      _servicoController.text = item.servico;
      _valorController.text = item.valor.toStringAsFixed(2);
      _statusSelecionado = item.status;
    }
  }

  Future<void> _salvarFormulario() async {
    if (!_formKey.currentState!.validate()) return;

    final usuario = _authService.usuarioAtual;
    if (usuario == null) return;

    setState(() => _salvando = true);

    try {
      // Substitui vírgula por ponto para converter valores em reais (ex: 150,50 -> 150.50)
      final valorNumerico = double.parse(
        _valorController.text.replaceAll(',', '.').trim(),
      );

      final manutencao = ManutencaoModel(
        id: widget.manutencaoParaEditar?.id,
        userId: usuario.id,
        veiculo: _veiculoController.text.trim(),
        placa: _placaController.text.trim().toUpperCase(),
        servico: _servicoController.text.trim(),
        valor: valorNumerico,
        status: _statusSelecionado,
      );

      if (widget.manutencaoParaEditar == null) {
        await _dbService.criarManutencao(manutencao);
      } else {
        await _dbService.atualizarManutencao(manutencao);
      }

      if (!mounted) return;
      Navigator.pop(context, true); // Retorna 'true' para atualizar a lista na Home
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  void dispose() {
    _veiculoController.dispose();
    _placaController.dispose();
    _servicoController.dispose();
    _valorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.manutencaoParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(editando ? 'Editar Ordem de Serviço' : 'Nova Ordem de Serviço'),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: _veiculoController,
                    label: 'Modelo do Veículo',
                    hint: 'Ex: Chevrolet Celta 1.0 / Honda Civic',
                    icon: Icons.directions_car_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Informe o veículo' : null,
                  ),

                  CustomTextField(
                    controller: _placaController,
                    label: 'Placa',
                    hint: 'Ex: ABC-1D23',
                    icon: Icons.pin_outlined,
                    validator: (v) =>
                        (v == null || v.trim().length < 7) ? 'Informe uma placa válida' : null,
                  ),

                  CustomTextField(
                    controller: _servicoController,
                    label: 'Descrição do Serviço / Peças',
                    hint: 'Ex: Troca de óleo 15W40, filtro e revisão de freios',
                    icon: Icons.handyman_outlined,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Descreva o serviço' : null,
                  ),

                  CustomTextField(
                    controller: _valorController,
                    label: 'Valor do Serviço (R\$)',
                    hint: 'Ex: 280.00',
                    icon: Icons.attach_money,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe o valor';
                      final numero = double.tryParse(v.replaceAll(',', '.'));
                      if (numero == null || numero < 0) {
                        return 'Digite um valor numérico válido';
                      }
                      return null;
                    },
                  ),

                  // Seleção de Status
                  const Text(
                    'Status da Manutenção',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _statusSelecionado,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: Icon(Icons.flag_outlined, color: Colors.amber.shade800),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: _opcoesStatus.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (novoStatus) {
                      if (novoStatus != null) {
                        setState(() => _statusSelecionado = novoStatus);
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _salvando ? null : _salvarFormulario,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(
                        _salvando
                            ? 'SALVANDO...'
                            : (editando ? 'ATUALIZAR SERVIÇO' : 'CADASTRAR SERVIÇO'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
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