import 'package:core/paginacao/i_paginacao_data_source.dart';
import 'package:core/paginacao/paginacao.dart';
import 'package:produtos/domain/data/local/i_codigos_local_data_source.dart';
import 'package:produtos/domain/data/remote/i_codigos_do_produto_remote_data_source.dart';
import 'package:produtos/domain/data/remote/i_codigos_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_codigos_repository.dart';

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
  Future<void> criarCodigo({required int produtoId, required String codigo}) {
    return _codigosDoProdutoRemoteDatasource.salvarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );
  }

  @override
  Future<void> deletarCodigo({required int produtoId, required String codigo}) {
    return _codigosDoProdutoRemoteDatasource.deletarCodigo(
      produtoId: produtoId,
      codigoDeBarras: codigo,
    );
  }

  @override
  Stream<Paginacao> sincronizarCodigos() async* {
    var paginacao = await _paginacaoDataSource.buscarPaginacao('codigos_sync');
    int page = paginacao?.ended == true ? 0 : paginacao?.paginaAtual ?? 0;
    int pageSize = 2000;
    while (true) {
      final codigosPaginados = await _codigosRemoteDataSource.buscarCodigos(
        pagina: page,
        limite: pageSize,
      );

      if (codigosPaginados.items?.isEmpty ?? true) {
        final paginacaoFinal = codigosPaginados.copyWith(ended: true);
        yield paginacaoFinal;
        await _paginacaoDataSource.salvarPaginacao(paginacaoFinal);
        break;
      }
      await _codigosLocalDataSource.salvarCodigosDeBarras(
        codigosPaginados.items!,
      );

      yield codigosPaginados;

      await _paginacaoDataSource.salvarPaginacao(codigosPaginados);
      page++;
    }
  }
}
