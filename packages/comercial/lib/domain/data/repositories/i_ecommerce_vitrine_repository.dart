import 'package:comercial/domain/models/ecommerce_vitrine.dart';

abstract class IEcommerceVitrineRepository {
  Future<EcommerceVitrine> recuperar(int ecommerceId);

  /// Substitui o conjunto do [local]; a posição em [itens] vira a ordem.
  Future<void> salvar(
    int ecommerceId,
    VitrineLocal local,
    List<EcommerceVitrineItem> itens,
  );
}
