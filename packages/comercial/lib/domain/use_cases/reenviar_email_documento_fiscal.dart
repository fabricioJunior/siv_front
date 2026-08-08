import 'package:comercial/domain/data/repositories/i_integracao_fiscal_repository.dart';

class ReenviarEmailDocumentoFiscal {
  final IIntegracaoFiscalRepository _repository;

  ReenviarEmailDocumentoFiscal({required IIntegracaoFiscalRepository repository})
      : _repository = repository;

  Future<void> call(int id, {String? emailDestino}) =>
      _repository.reenviarEmail(id, emailDestino: emailDestino);
}
