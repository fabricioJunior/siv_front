import 'preco_da_referencia_por_tabela.dart';

/// Porta pra salvar (criar ou atualizar) o preço da referência numa
/// tabela específica.
///
/// [precoJaExiste] decide qual operação a implementação chama: a API tem
/// endpoints separados de criar (POST) e atualizar (PUT) -- atualizar numa
/// tabela sem preço ainda falha (backend exige o registro já existir).
abstract class PortaSalvarPrecoDaReferencia {
  Future<PrecoDaReferenciaPorTabela> call({
    required int tabelaDePrecoId,
    required int referenciaId,
    required double valor,
    required bool precoJaExiste,
  });
}
