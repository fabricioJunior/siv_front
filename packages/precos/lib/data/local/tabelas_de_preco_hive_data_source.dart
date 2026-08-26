import 'package:core/data_sourcers.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';
import 'package:precos/models.dart';

import 'dtos/tabela_de_preco_hive_dto.dart';

class TabelasDePrecoHiveDataSource
    extends HiveLocalDataSourceBase<TabelaDePrecoHiveDto, TabelaDePreco>
    implements ITabelasDePrecoLocalDataSource {
  TabelasDePrecoHiveDataSource({required super.getBox});

  @override
  TabelaDePrecoHiveDto toDto(TabelaDePreco entity) {
    return TabelaDePrecoHiveDto(
      id: entity.id,
      inativa: entity.inativa,
      nome: entity.nome,
      terminador: entity.terminador,
      padrao: entity.padrao,
    );
  }

  @override
  Future<void> limparTabelasDePreco() {
    return deleteAll();
  }

  @override
  Future<TabelaDePreco?> obterTabelaDePreco(int id) {
    return fetchById(id);
  }

  @override
  Future<List<TabelaDePreco>> obterTabelasDePreco() async {
    return (await fetchAll()).toList();
  }

  @override
  Future<void> salvarTabelaDePreco(TabelaDePreco tabela) {
    return put(tabela);
  }

  @override
  Future<void> salvarTabelasDePreco(List<TabelaDePreco> tabelas) {
    return putAll(tabelas);
  }
}
