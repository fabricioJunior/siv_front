import 'package:financeiro/domain/data/remote/i_suprimentos_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_suprimentos_repository.dart';
import 'package:financeiro/domain/models/suprimento.dart';

class SuprimentosRepository implements ISuprimentosRepository {
  final ISuprimentosRemoteDataSource remoteDataSource;

  SuprimentosRepository({required this.remoteDataSource});

  @override
  Future<void> cancelarSuprimento({
    required int caixaId,
    required int suprimentoId,
    required String motivo,
  }) {
    return remoteDataSource.cancelarSuprimento(
      suprimentoId: suprimentoId,
      caixaId: caixaId,
      motivo: motivo,
    );
  }

  @override
  Future<Suprimento> criarSuprimento({
    required int caixaId,
    required double valor,
    required String descricao,
  }) {
    return remoteDataSource.criarSuprimento(
      caixaId: caixaId,
      valor: valor,
      descricao: descricao,
    );
  }

  @override
  Future<Suprimento> recuperarSuprimento({
    required int caixaId,
    required int suprimentoId,
  }) {
    return remoteDataSource.recuperarSuprimento(
      suprimentoId: suprimentoId,
      caixaId: caixaId,
    );
  }

  @override
  Future<List<Suprimento>> recuperarSuprimentos({required int caixaId}) {
    return remoteDataSource.recuperarSuprimentos(caixaId: caixaId);
  }
}
