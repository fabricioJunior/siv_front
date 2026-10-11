import 'package:entregas/domain/data/remote/i_frete_remote_data_source.dart';
import 'package:entregas/domain/data/repositories/i_frete_repository.dart';
import 'package:entregas/domain/models/frete.dart';

class FreteRepository implements IFreteRepository {
  final IFreteRemoteDataSource remoteDataSource;

  FreteRepository({required this.remoteDataSource});

  @override
  Future<ConfiguracaoFrete> getConfiguracao() =>
      remoteDataSource.getConfiguracao();

  @override
  Future<List<String>> getTransportadoras() =>
      remoteDataSource.getTransportadoras();

  @override
  Future<void> salvarTransportadoras({
    required bool ativo,
    required List<String> transportadoras,
  }) =>
      remoteDataSource.salvarTransportadoras(
        ativo: ativo,
        transportadoras: transportadoras,
      );
}
