import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:flutter_test/flutter_test.dart';

CreditoTransferivel _c(int id, double v) => CreditoTransferivel(
      romaneioId: id,
      faturaId: id,
      faturaParcela: 1,
      data: DateTime(2026, 1, 1),
      valor: v,
    );

class _Get implements GetCreditosTransferiveis {
  @override
  Future<List<CreditoTransferivel>> call({required int pessoaId}) async =>
      [_c(1, 10.10), _c(2, 20.20)];
}

class _Transf implements TransferirCreditosDevolucao {
  List<int>? ids;
  Object? erro;

  @override
  Future<ResultadoTransferenciaCredito> call({
    required int pessoaId,
    required List<int> romaneioIds,
  }) async {
    if (erro != null) throw erro!;
    ids = romaneioIds;
    return const ResultadoTransferenciaCredito(
      valorTotal: 30.30,
      saldoCreditoDevolucaoDestino: 30.30,
    );
  }
}

void main() {
  late _Transf transf;
  late TransferirCreditoBloc bloc;

  setUp(() {
    transf = _Transf();
    bloc = TransferirCreditoBloc(_Get(), transf);
  });

  tearDown(() => bloc.close());

  Future<void> carregarESelecionar() async {
    bloc.add(TransferirCreditoCarregou(7));
    await bloc.stream.firstWhere((s) => s.status == TransferirCreditoStatus.pronto);
    bloc.add(TransferirCreditoAlternou(1));
    bloc.add(TransferirCreditoAlternou(2));
    await bloc.stream.firstWhere((s) => s.selecionados.length == 2);
  }

  test('carrega lista e soma seleção', () async {
    await carregarESelecionar();
    expect(bloc.state.creditos.length, 2);
    expect(bloc.state.total, 30.30);
    bloc.add(TransferirCreditoAlternou(1));
    await bloc.stream.firstWhere((s) => s.selecionados.length == 1);
    expect(bloc.state.total, 20.20);
  });

  test('confirmar chama use case com romaneioIds e emite sucesso', () async {
    await carregarESelecionar();
    bloc.add(TransferirCreditoConfirmou());
    final s = await bloc.stream
        .firstWhere((s) => s.status == TransferirCreditoStatus.sucesso);
    expect(transf.ids, [1, 2]);
    expect(s.resultado?.valorTotal, 30.30);
  });

  test('erro 400 mostra mensagem da API', () async {
    await carregarESelecionar();
    transf.erro = HttpException(
      'x',
      statusCode: 400,
      apiMessage: 'Romaneio já transferido',
    );
    bloc.add(TransferirCreditoConfirmou());
    final s = await bloc.stream.firstWhere((s) => s.erro != null);
    expect(s.erro, 'Romaneio já transferido');
    expect(s.status, TransferirCreditoStatus.pronto);
  });
}
