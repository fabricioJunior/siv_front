import 'package:financeiro/data.dart';
import 'package:financeiro/domain/models/caixa.dart';

class RecuperarCaixaAberto {
  final ICaixaRepository repository;

  RecuperarCaixaAberto({required this.repository});

  Future<Caixa?> call({required int idEmpresa, required int idTerminal}) async {
    return await repository.recuperarCaixaAberto(
        idEmpresa: idEmpresa, terminalId: idTerminal);
  }
}
