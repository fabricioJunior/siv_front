import 'package:comercial/models.dart';
import 'package:comercial/presentation/blocs/ecommerce_referencias_bloc/ecommerce_referencias_bloc.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/remote_data_sourcers.dart' show HttpException;
import 'package:flutter_test/flutter_test.dart';

/// Adicionar: toda referência falha; a 7 com a mensagem do servidor (duplicada), as demais sem corpo.
class _Adicionar implements AdicionarReferenciaEcommerce {
  @override
  Future<EcommerceReferencia> call(
    int ecommerceId, {
    required int referenciaId,
    int? tabelaDePrecoId,
  }) async {
    if (referenciaId == 7) {
      throw HttpException(
        'Requisição inválida',
        statusCode: 409,
        apiMessage: 'Referência já adicionada a este e-commerce.',
      );
    }
    throw HttpException('Erro interno', statusCode: 500);
  }

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Recuperar implements RecuperarReferenciasEcommerce {
  @override
  Future<EcommerceReferenciasPagina> call(
    int ecommerceId, {
    String? busca,
    List<int>? categoriaIds,
    bool? rascunho,
    bool? publicavel,
    int page = 1,
    int limit = 50,
  }) async =>
      const EcommerceReferenciasPagina(itens: [], total: 0);

  @override
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Outros {
  dynamic noSuchMethod(Invocation i) => throw UnimplementedError();
}

class _Atualizar extends _Outros implements AtualizarReferenciaEcommerce {}

class _Publicar extends _Outros implements PublicarReferenciasEmLoteEcommerce {}

void main() {
  test('adicionar em lote guarda a mensagem do servidor de cada falha (ex.: duplicada)', () async {
    final bloc = EcommerceReferenciasBloc(
      _Recuperar(),
      _Adicionar(),
      _Atualizar(),
      _Publicar(),
    );
    addTearDown(bloc.close);

    final concluiu = bloc.stream.firstWhere(
      (s) => s is EcommerceReferenciasAdicionarLoteConcluiu,
    );
    bloc.add(
      const EcommerceReferenciasAdicionarEmLoteSolicitou(
        ecommerceId: 1,
        referenciaIds: [7, 9],
      ),
    );
    final estado = (await concluiu) as EcommerceReferenciasAdicionarLoteConcluiu;

    expect(estado.adicionados, 0);
    expect(estado.falhas, hasLength(2));
    final duplicada = estado.falhas.firstWhere((f) => f.referenciaId == 7);
    expect(duplicada.mensagem, 'Referência já adicionada a este e-commerce.');
    final outra = estado.falhas.firstWhere((f) => f.referenciaId == 9);
    expect(outra.mensagem, 'Não foi possível adicionar a referência.');
  });
}
