import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/config_credito_devolucao.dart';
import 'package:empresas/presentation/blocs/config_credito_devolucao_bloc/config_credito_devolucao_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Card 2i: validade padrão dos créditos novos e aviso na venda.
/// Só montar com permissão ADMFM011 (sem permissão o card some).
class EmpresaCreditoDevolucaoCard extends StatelessWidget {
  final int idEmpresa;

  const EmpresaCreditoDevolucaoCard({super.key, required this.idEmpresa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfigCreditoDevolucaoBloc>(
      create: (_) => sl<ConfigCreditoDevolucaoBloc>()
        ..add(ConfigCreditoDevolucaoCarregou(idEmpresa)),
      child: BlocConsumer<ConfigCreditoDevolucaoBloc, ConfigCreditoDevolucaoState>(
        listenWhen: (a, b) => a.status != b.status,
        listener: (context, s) {
          final msg = switch (s.status) {
            ConfigCreditoDevolucaoStatus.salvo => 'Configuração salva.',
            ConfigCreditoDevolucaoStatus.erro => s.erro,
            _ => null,
          };
          if (msg != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(msg)));
          }
        },
        builder: (context, s) {
          final config = s.config;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Stack(
              children: [
                SivCard(
                  child: config == null
                      ? Center(
                          child: s.status == ConfigCreditoDevolucaoStatus.erro
                              ? Text(s.erro ?? '')
                              : const CircularProgressIndicator.adaptive(),
                        )
                      : _Formulario(
                          // Recria o formulário quando o servidor devolve a config salva.
                          key: ValueKey(config),
                          config: config,
                          salvando:
                              s.status == ConfigCreditoDevolucaoStatus.salvando,
                        ),
                ),
                ...sivCantosBlueprint(
                  context.sivColors.aco.withValues(alpha: 0.4),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Formulario extends StatefulWidget {
  final ConfigCreditoDevolucao config;
  final bool salvando;

  const _Formulario({super.key, required this.config, required this.salvando});

  @override
  State<_Formulario> createState() => _FormularioState();
}

class _FormularioState extends State<_Formulario> {
  static const _opcoes = <int?>[null, 30, 60, 90, 180];
  late int? _dias = widget.config.validadeDiasPadrao;
  late final _aviso =
      TextEditingController(text: '${widget.config.avisoDiasAntes}');

  @override
  void dispose() {
    _aviso.dispose();
    super.dispose();
  }

  void _salvar() {
    context.read<ConfigCreditoDevolucaoBloc>().add(
          ConfigCreditoDevolucaoSalvou(ConfigCreditoDevolucao(
            validadeDiasPadrao: _dias,
            avisoDiasAntes: int.tryParse(_aviso.text) ?? 0,
          )),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crédito de devolução', style: textos.secao),
        const SizedBox(height: 16),
        Text('Validade de novos créditos', style: textos.apoio),
        const SizedBox(height: 8),
        SegmentedButton<int?>(
          showSelectedIcon: false,
          segments: [
            for (final o in _opcoes)
              ButtonSegment(
                value: o,
                label: Text(o == null ? 'Sem validade' : '$o dias'),
              ),
          ],
          selected: {_dias},
          onSelectionChanged: (s) => setState(() => _dias = s.first),
        ),
        const SizedBox(height: 4),
        Text(
          'Vale para devoluções e créditos avulsos criados a partir de agora. '
          'Os créditos que já existem mantêm o prazo atual.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
        const SizedBox(height: 16),
        Text('Avisar na venda quando faltar', style: textos.apoio),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextField(
                controller: _aviso,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 10),
            Text('dias para vencer', style: textos.corpo),
          ],
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: widget.salvando ? null : _salvar,
            child: const Text('Salvar'),
          ),
        ),
      ],
    );
  }
}
