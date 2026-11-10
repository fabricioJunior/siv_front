import 'package:comercial/presentation/blocs/pagamentos_realizados_bloc/pagamentos_realizados_bloc.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Informativo discreto das promoções da venda: ativa (cor do tema) ou
/// suspensa pela forma de pagamento escolhida (apagada).
class IndicadorPromocao extends StatelessWidget {
  final PagamentosRealizadosState state;

  const IndicadorPromocao({super.key, required this.state});

  String _formas(List<int> ids) {
    final nomes = [
      for (final f in state.formasDePagamento)
        if (ids.contains(f.id)) f.nome,
    ];
    return nomes.isEmpty ? 'formas específicas' : nomes.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final promocoes = state.promocoesDistintas;
    if (promocoes.isEmpty) return const SizedBox.shrink();
    final textos = context.sivTextos;
    final cores = context.sivColors;
    final rotulos = [
      for (final p in promocoes.take(2))
        state.promocaoSuspensa(p)
            ? '${p.nome} — só em ${_formas(p.formasPagamentoPermitidasIds!)}'
            : 'Promoção: ${p.nome}',
    ];
    final extra = promocoes.length - 2;
    final suspensa = promocoes.every(state.promocaoSuspensa);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        rotulos.join(' · ') + (extra > 0 ? ' +$extra' : ''),
        style: textos.apoio.copyWith(color: suspensa ? null : cores.aco),
      ),
    );
  }
}
