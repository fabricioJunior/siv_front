import 'package:comercial/domain/data/remote/i_ecommerce_vitrine_remote_data_source.dart';
import 'package:comercial/domain/data/repositories/i_ecommerce_vitrine_repository.dart';
import 'package:comercial/domain/models/ecommerce_vitrine.dart';

class EcommerceVitrineRepository implements IEcommerceVitrineRepository {
  final IEcommerceVitrineRemoteDataSource remoteDataSource;

  EcommerceVitrineRepository({required this.remoteDataSource});

  @override
  Future<EcommerceVitrine> recuperar(int ecommerceId) =>
      remoteDataSource.recuperar(ecommerceId);

  @override
  Future<void> salvar(
    int ecommerceId,
    VitrineLocal local,
    List<EcommerceVitrineItem> itens,
  ) =>
      remoteDataSource.salvar(ecommerceId, local, itens);
}
