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
