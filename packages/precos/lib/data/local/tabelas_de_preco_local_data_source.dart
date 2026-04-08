import 'package:core/data_sourcers.dart';
import 'package:precos/domain/data/local/i_tabelas_de_preco_local_data_source.dart';
import 'package:precos/models.dart';

import 'dtos/tabela_de_preco_dto.dart';

class TabelasDePrecoLocalDataSource
    extends IsarLocalDataSourceBase<TabelaDePrecoDto, TabelaDePreco>
    implements ITabelasDePrecoLocalDataSource {
  TabelasDePrecoLocalDataSource({required super.getIsar});

  @override
  TabelaDePrecoDto toDto(TabelaDePreco entity) {
    return TabelaDePrecoDto(
      id: entity.id,
      inativa: entity.inativa,
      nome: entity.nome,
      terminador: entity.terminador,
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
