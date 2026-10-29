import 'package:core/http/i_http_response.dart';
import 'package:core/http/i_http_source.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/despesas_calendario_remote_data_source.dart';
import 'package:financeiro/data/remote/despesas_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa.dart';
import 'package:flutter_test/flutter_test.dart';

class _Resposta implements IHttpResponse {
  @override
  final int statusCode;
  @override
  final dynamic body;
  _Resposta(this.statusCode, this.body);
  @override
  String? get message => null;
  @override
  Uri? get uri => null;
}

class _Http implements IHttpSource {
  dynamic bodyEnviado;
  Uri? uriEnviada;
  final IHttpResponse resposta;
  _Http(this.resposta);

  @override
  Future<IHttpResponse> post({required dynamic body, required Uri uri}) async {
    bodyEnviado = body;
    uriEnviada = uri;
    return resposta;
  }

  @override
  Future<IHttpResponse> patch({required dynamic body, required Uri uri}) async {
    bodyEnviado = body;
    uriEnviada = uri;
    return resposta;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Info extends IInformacoesParaRequests {
  _Info(IHttpSource http)
      : super(httpClient: http, uriBase: Uri.parse('https://api.test'));
}

void main() {
  test(
      'pagarFatura manda o corpo como Map (o HttpSource é quem faz o jsonEncode)',
      () async {
    final http = _Http(_Resposta(200, {'atualizadas': 2, 'valorTotal': 30.5}));
    final r = await DespesasRemoteDataSource(
            informacoesParaRequest: _Info(http))
        .pagarFatura(empresaId: 1, origemPagamentoId: 6, ano: 2026, mes: 11);

    expect(http.bodyEnviado,
        {'empresaId': 1, 'origemPagamentoId': 6, 'ano': 2026, 'mes': 11});
    expect(http.uriEnviada!.path, '/v1/despesas/pagar-fatura');
    expect(r.atualizadas, 2);
    expect(r.valorTotal, 30.5);
  });

  test('pagarFatura com status de erro lança em vez de estourar no cast',
      () async {
    final http = _Http(_Resposta(400, {
      'message': ['mes must not be greater than 12']
    }));
    expect(
      () => DespesasRemoteDataSource(informacoesParaRequest: _Info(http))
          .pagarFatura(empresaId: 1, origemPagamentoId: 6, ano: 2026, mes: 11),
      throwsA(predicate((e) => e.toString().contains('pagar-fatura 400'))),
    );
  });

  test(
      'registrarOcorrencia (marcar recorrente como paga) bate em /v1/despesas/{id}/ocorrencias',
      () async {
    final http = _Http(_Resposta(201, {'id': 1}));
    await DespesasCalendarioRemoteDataSource(
            informacoesParaRequest: _Info(http))
        .registrarOcorrencia(125,
            ano: 2026, mes: 10, status: StatusDespesa.pago);

    expect(http.uriEnviada!.path, '/v1/despesas/125/ocorrencias');
    expect(http.bodyEnviado, contains('"status":"pago"'));
  });

  test(
      'registrarOcorrencia com erro HTTP lança (antes ficava pendente sem avisar)',
      () async {
    final http = _Http(_Resposta(404, {'message': 'Cannot POST'}));
    expect(
      () => DespesasCalendarioRemoteDataSource(
              informacoesParaRequest: _Info(http))
          .registrarOcorrencia(125,
              ano: 2026, mes: 10, status: StatusDespesa.pago),
      throwsA(predicate((e) => e.toString().contains('ocorrencias 404'))),
    );
  });
}
