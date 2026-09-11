import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

// Cria o romaneio, adiciona os itens e recebe no caixa em 1 request só -- substitui o fluxo de
// criar + N itens + receber (3+ chamadas) usado por RomaneioCriacaoBloc. Só serve venda (romaneio
// novo do zero, sem idLista prévio).
class CriarVendaCompleta {
  final IRomaneiosRepository _repository;

  CriarVendaCompleta({required IRomaneiosRepository repository})
      : _repository = repository;

  Future<Romaneio> call({
    required int caixaId,
    int? pessoaId,
    required int funcionarioId,
    required int tabelaPrecoId,
    required List<RomaneioItem> itens,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    List<Map<String, dynamic>> descontosPromocao = const [],
    Map<String, dynamic>? cupom,
    double? valorTaxaEntrega,
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
    bool pontuarFidelidade = false,
    bool enviarNotaPorEmail = false,
    String emailNota = '',
  }) {
    return _repository.criarVendaCompleta(
      caixaId: caixaId,
      pessoaId: pessoaId,
      funcionarioId: funcionarioId,
      tabelaPrecoId: tabelaPrecoId,
      itens: itens,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
      descontosItens: descontosItens,
      descontosPromocao: descontosPromocao,
      cupom: cupom,
      valorTaxaEntrega: valorTaxaEntrega,
      incluirCpfNaNota: incluirCpfNaNota,
      cpfNaNota: cpfNaNota,
      pontuarFidelidade: pontuarFidelidade,
      enviarNotaPorEmail: enviarNotaPorEmail,
      emailNota: emailNota,
    );
  }
}
