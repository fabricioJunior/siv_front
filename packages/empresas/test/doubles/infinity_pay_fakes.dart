import 'package:empresas/data/remote_data_sourcers/dtos/empresa_parametro_dto.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';
import 'package:empresas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Servidor" em memória: chave -> valor.
class ServidorParametros {
  final Map<String, String> valores;
  final Set<String> falham;
  final List<List<String>> chamadas = [];

  ServidorParametros(this.valores, {this.falham = const {}});

  List<EmpresaParametro> lista() => [
    for (final e in valores.entries)
      EmpresaParametro.create(
        id: e.key.hashCode,
        empresaId: 1,
        chave: e.key,
        descricao: e.key,
        tipo: ehParametroBooleanoPorChave(e.key)
            ? TipoEmpresaParametro.checkbox
            : TipoEmpresaParametro.texto,
        valorTexto: ehParametroBooleanoPorChave(e.key) ? null : e.value,
        valorBooleano: ehParametroBooleanoPorChave(e.key)
            ? e.value == 'S'
            : null,
        descontinuado: false,
      ),
  ];
}

class FakeRecuperarParametros extends Fake
    implements RecuperarParametrosEmpresa {
  final ServidorParametros servidor;
  FakeRecuperarParametros(this.servidor);

  @override
  Future<List<EmpresaParametro>> call(int empresaId) async => servidor.lista();
}

/// Como a API real: devolve uma List<EmpresaParametroDto> (tipo de execução),
/// sem os parâmetros que ainda não foram criados para a empresa.
class FakeRecuperarParametrosDto extends Fake
    implements RecuperarParametrosEmpresa {
  @override
  Future<List<EmpresaParametro>> call(int empresaId) async =>
      <EmpresaParametroDto>[];
}

class FakeAtualizarParametros extends Fake
    implements AtualizarParametrosEmpresa {
  final ServidorParametros servidor;
  FakeAtualizarParametros(this.servidor);

  @override
  Future<List<EmpresaParametro>> call({
    required int empresaId,
    required List<EmpresaParametro> parametros,
  }) async {
    servidor.chamadas.add([for (final p in parametros) p.chave]);
    final p = parametros.single;
    if (servidor.falham.contains(p.chave)) {
      throw Exception('Recusado ${p.chave}');
    }
    servidor.valores[p.chave] =
        p.valorTexto ?? (p.valorBooleano == true ? 'S' : 'N');
    return servidor.lista();
  }
}

Map<String, String> parametrosBase() => {
  'INTEGRACAO_INFINITY_PAY_HABILITADA': 'N',
  'INTEGRACAO_INFINITY_PAY_API_HANDLE': '',
  'INTEGRACAO_INFINITY_PAY_URL_WEBHOOK': '',
  'INTEGRACAO_INFINITY_PAY_URL_REDIRECT': '',
  'RESERVA_ESTOQUE_TTL_MINUTOS': '5',
  'EMAIL_FINANCEIRO_ESTORNO': '',
  'INTEGRACAO_INFINITY_PAY_API_KEY': '',
  'INTEGRACAO_INFINITY_PAY_PARCELAS_SEM_JUROS': '',
  'INTEGRACAO_INFINITY_PAY_PIX_HABILITADO': 'S',
  'URL_SITE_EMPRESA': 'https://loja.com.br',
  'INTEGRACAO_MERCADO_PAGO_HABILITADA': 'S',
  'INTEGRACAO_OPEN_PIX_HABILITADA': 'N',
};
