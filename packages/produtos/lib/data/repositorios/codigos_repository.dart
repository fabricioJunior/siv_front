import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:produtos/data/remote/dtos/codigo_dto.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/data/remote/i_codigos_do_produto_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_codigos_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_codigos_repository.dart';
import 'package:produtos/domain/models/codigo.dart';

class CodigoDeBarrasRepository implements ICodigosRepository {
  final ICodigosDoProdutoRemoteDatasource _codigosDoProdutoRemoteDatasource;
  final ICodigosRemoteDataSource _codigosRemoteDataSource;
  final ICodigosLocalDataSource _codigosLocalDataSource;
  final IPaginacaoDataSource _paginacaoDataSource;

  CodigoDeBarrasRepository({
    required ICodigosDoProdutoRemoteDatasource codigoDeBarrasRemoteDatasource,
    required ICodigosRemoteDataSource codigosRemoteDataSource,
    required ICodigosLocalDataSource codigosLocalDataSource,
    required IPaginacaoDataSource paginacaoDataSource,
  }) : _codigosDoProdutoRemoteDatasource = codigoDeBarrasRemoteDatasource,
       _codigosRemoteDataSource = codigosRemoteDataSource,
       _codigosLocalDataSource = codigosLocalDataSource,
       _paginacaoDataSource = paginacaoDataSource;

  @override
  Future<void> criarCodigo({required int produtoId, required String codigo}) async {
    await _codigosDoProdutoRemoteDatasource.salvarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );

    await _codigosLocalDataSource.salvarCodigosDeBarras([
      CodigoDto(codigo: codigo, tipo: TipoCodigo.ean13, produtoId: produtoId),
    ]);
  }

  @override
  Future<void> deletarCodigo({required int produtoId, required String codigo}) {
    return _codigosDoProdutoRemoteDatasource.deletarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );
  }

  @override
  Future<String?> recuperarCodigoPorProdutoId(int produtoId) async {
    final codigos = await _codigosLocalDataSource.recuperarCodigosPorProdutoId(
      produtoId,
    );

    for (final codigo in codigos) {
      final valor = codigo.codigo.trim();
      if (valor.isNotEmpty) {
        return valor;
      }
    }

    return null;
  }

  @override
  Stream<Paginacao> sincronizarCodigos() async* {
    var paginacao = await _paginacaoDataSource.buscarPaginacao('codigos_sync');
    final syncAnteriorConcluida = paginacao?.ended == true;
    final ultimaAtualizacaoFim = DateTime.now();
    final ultimaAtualizacaoInicio =
        syncAnteriorConcluida ? paginacao!.dataAtualizacao : null;
    final ultimaAtualizacaoFimFiltro =
        syncAnteriorConcluida ? ultimaAtualizacaoFim : null;
    int page = syncAnteriorConcluida ? 0 : paginacao?.paginaAtual ?? 0;
    int pageSize = 2000;
    while (true) {
      final codigosPaginados = await _codigosRemoteDataSource.buscarCodigos(
        pagina: page,
        limite: pageSize,
        ultimaAtualizacaoInicio: ultimaAtualizacaoInicio,
        ultimaAtualizacaoFim: ultimaAtualizacaoFimFiltro,
      );

      if (codigosPaginados.items?.isEmpty ?? true) {
        final paginacaoFinal = codigosPaginados.copyWith(
          ended: true,
          dataAtualizacao: ultimaAtualizacaoFimFiltro ?? DateTime.now(),
        );
        yield paginacaoFinal;
        await _paginacaoDataSource.salvarPaginacao(paginacaoFinal);
        break;
      }
      await _codigosLocalDataSource.salvarCodigosDeBarras(
        codigosPaginados.items!,
      );

      yield codigosPaginados.copyWith(
        dataAtualizacao: ultimaAtualizacaoFimFiltro ?? DateTime.now(),
      );

      await _paginacaoDataSource.salvarPaginacao(
        codigosPaginados.copyWith(
          dataAtualizacao: ultimaAtualizacaoFimFiltro ?? DateTime.now(),
        ),
      );
      page++;
    }
  }
}
