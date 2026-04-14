import 'package:financeiro/domain/data/repositories/i_caixa_repository.dart';
import 'package:financeiro/domain/models/caixa.dart';

class AbrirCaixa {
  final ICaixaRepository _repository;

  AbrirCaixa({required ICaixaRepository repository}) : _repository = repository;

  Future<Caixa> call({required int idEmpresa, required int terminalId}) {
    return _repository.abrirCaixa(idEmpresa: idEmpresa, terminalId: terminalId);
  }
}
