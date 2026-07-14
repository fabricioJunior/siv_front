part of 'romaneio_bloc.dart';

abstract class RomaneioEvent {}

class RomaneioIniciou extends RomaneioEvent {
  final int? idRomaneio;

  RomaneioIniciou({this.idRomaneio});
}

class RomaneioCampoAlterado extends RomaneioEvent {
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final TipoOperacao? operacao;
  final String? observacao;

  RomaneioCampoAlterado({
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.operacao,
    this.observacao,
  });
}

class RomaneioSalvou extends RomaneioEvent {}

class RomaneioObservacaoAtualizada extends RomaneioEvent {
  final String? observacao;

  RomaneioObservacaoAtualizada({this.observacao});
}

class RomaneioVendedorAtualizado extends RomaneioEvent {
  final int funcionarioId;

  RomaneioVendedorAtualizado({required this.funcionarioId});
}

class RomaneioFormaDePagamentoCorrigida extends RomaneioEvent {
  final List<Map<String, dynamic>> pagamentos;

  RomaneioFormaDePagamentoCorrigida({required this.pagamentos});
}

class RomaneioPagamentoRecebido extends RomaneioEvent {
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  // Substitui (não soma) o desconto já persistido no romaneio -- ver
  // comentário em romaneio_page.dart:_irParaPagamento.
  final double? desconto;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;

  RomaneioPagamentoRecebido({
    required this.formasDePagamentoRealizadas,
    this.desconto,
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
  });
}

class RomaneioContinuarEnvioSolicitado extends RomaneioEvent {}
