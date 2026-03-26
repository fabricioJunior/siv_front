import 'package:precos/domain/data/remote/i_tabelas_de_preco_remote_data_source.dart';
import 'package:precos/domain/data/repositorios/i_tabelas_de_preco_repository.dart';
import 'package:precos/domain/models/tabela_de_preco.dart';

class TabelasDePrecoRepository implements ITabelasDePrecoRepository {
  final ITabelasDePrecoRemoteDataSource tabelasDePrecoRemoteDataSource;

  TabelasDePrecoRepository({required this.tabelasDePrecoRemoteDataSource});

  @override
  Future<TabelaDePreco> atualizarTabelaDePreco({
    required int id,
    required String nome,
    double? terminador,
  }) {
    return tabelasDePrecoRemoteDataSource.atualizarTabelaDePreco(
      id: id,
      nome: nome,
      terminador: terminador,
    );
  }

  @override
  Future<TabelaDePreco> criarTabelaDePreco({
    required String nome,
    double? terminador,
  }) {
    return tabelasDePrecoRemoteDataSource.createTabelaDePreco(
      nome: nome,
      terminador: terminador,
    );
  }

  @override
  Future<void> desativarTabelaDePreco(int id) {
    return tabelasDePrecoRemoteDataSource.desativarTabelaDePreco(id);
  }

  @override
  Future<TabelaDePreco?> obterTabelaDePreco(int id) {
    return tabelasDePrecoRemoteDataSource.fetchTabelaDePreco(id);
  }

  @override
  Future<List<TabelaDePreco>> obterTabelasDePreco({
    String? nome,
    bool? inativa,
  }) {
    return tabelasDePrecoRemoteDataSource.fetchTabelasDePreco(
      nome: nome,
      inativa: inativa,
    );
  }
}
