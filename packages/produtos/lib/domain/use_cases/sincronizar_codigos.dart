import 'package:core/paginacao/paginacao.dart';
import 'package:produtos/repositorios.dart';

class SincronizarCodigos {
  final ICodigosRepository _codigosRepository;

  SincronizarCodigos({required ICodigosRepository codigosRepository})
    : _codigosRepository = codigosRepository;

  Stream<Paginacao> call() async* {
    yield* _codigosRepository.sincronizarCodigos();
  }
}
