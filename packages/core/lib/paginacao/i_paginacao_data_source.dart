import 'package:core/paginacao/paginacao.dart';

abstract class IPaginacaoDataSource {
  Future<Paginacao?> buscarPaginacao(String key);
  Future<void> salvarPaginacao(Paginacao paginacao);
}
