import 'package:core/precos_portas.dart';

class ListarPrecosDaReferenciaPorTabela {
  final PortaListarPrecosDaReferenciaPorTabela _porta;

  ListarPrecosDaReferenciaPorTabela(this._porta);

  Future<List<PrecoDaReferenciaPorTabela>> call({required int referenciaId}) {
    return _porta(referenciaId: referenciaId);
  }
}
