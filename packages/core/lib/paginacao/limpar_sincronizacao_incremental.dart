import 'package:core/paginacao/i_paginacao_data_source.dart';

class LimparSincronizacaoIncremental {
  final IPaginacaoDataSource _paginacaoDataSource;

  LimparSincronizacaoIncremental({required IPaginacaoDataSource paginacaoDataSource})
      : _paginacaoDataSource = paginacaoDataSource;

  Future<void> call() => _paginacaoDataSource.limparTudo();
}
