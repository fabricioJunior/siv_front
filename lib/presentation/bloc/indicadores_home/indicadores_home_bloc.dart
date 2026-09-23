import 'package:comercial/domain/models/contagem_pedidos_por_situacao.dart';
import 'package:comercial/domain/models/relatorios.dart';
import 'package:comercial/domain/use_cases/contar_pedidos_por_situacao.dart';
import 'package:comercial/domain/use_cases/get_relatorio_faturamento.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';

part 'indicadores_home_event.dart';
part 'indicadores_home_state.dart';

class IndicadoresHomeBloc extends Bloc<IndicadoresHomeEvent, IndicadoresHomeState> {
  final GetRelatorioFaturamento _getRelatorioFaturamento;
  final ContarPedidosPorSituacao _contarPedidosPorSituacao;

  IndicadoresHomeBloc(
    this._getRelatorioFaturamento,
    this._contarPedidosPorSituacao,
  ) : super(const IndicadoresHomeState()) {
    on<IndicadoresHomeCarregou>(_onCarregou);
  }

  Future<void> _onCarregou(
    IndicadoresHomeCarregou event,
    Emitter<IndicadoresHomeState> emit,
  ) async {
    final hoje = DateTime.now();
    final hojeIso = '${hoje.year.toString().padLeft(4, '0')}-'
        '${hoje.month.toString().padLeft(2, '0')}-'
        '${hoje.day.toString().padLeft(2, '0')}';

    RelatorioFaturamento? faturamento;
    ContagemPedidosPorSituacao? contagemPedidos;

    final tarefas = <Future<void>>[];
    if (PermissaoPorNome.acessoPermitido('RELFC001')) {
      tarefas.add(
        _getRelatorioFaturamento
            .call(empresaIds: [event.empresaId], dataInicial: hojeIso, dataFinal: hojeIso)
            .then((r) {
              faturamento = r;
            })
            .catchError((_) {}),
      );
    }
    if (PermissaoPorNome.acessoPermitido('PEDFC001')) {
      tarefas.add(
        _contarPedidosPorSituacao.call().then((c) {
          contagemPedidos = c;
        }).catchError((_) {}),
      );
    }

    await Future.wait(tarefas);

    emit(
      state.copyWith(
        faturamento: faturamento,
        contagemPedidos: contagemPedidos,
        carregando: false,
      ),
    );
  }
}
