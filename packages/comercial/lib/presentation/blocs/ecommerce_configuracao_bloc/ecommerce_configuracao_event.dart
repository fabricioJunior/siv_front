part of 'ecommerce_configuracao_bloc.dart';

abstract class EcommerceConfiguracaoEvent extends Equatable {
  const EcommerceConfiguracaoEvent();

  @override
  List<Object?> get props => [];
}

class EcommerceConfiguracaoIniciou extends EcommerceConfiguracaoEvent {
  final int empresaId;
  final int? ecommerceId;

  const EcommerceConfiguracaoIniciou({
    required this.empresaId,
    this.ecommerceId,
  });

  @override
  List<Object?> get props => [empresaId, ecommerceId];
}

class EcommerceConfiguracaoEditou extends EcommerceConfiguracaoEvent {
  final String? titulo;
  final String? subtitulo;
  final String? descricao;
  final String? icone;
  final int? empresaEstoqueId;
  final int? tabelaDePrecoId;
  final int? terminalId;
  final int? formaDePagamentoId;

  const EcommerceConfiguracaoEditou({
    this.titulo,
    this.subtitulo,
    this.descricao,
    this.icone,
    this.empresaEstoqueId,
    this.tabelaDePrecoId,
    this.terminalId,
    this.formaDePagamentoId,
  });

  @override
  List<Object?> get props => [
        titulo,
        subtitulo,
        descricao,
        icone,
        empresaEstoqueId,
        tabelaDePrecoId,
        terminalId,
        formaDePagamentoId,
      ];
}

class EcommerceConfiguracaoSalvou extends EcommerceConfiguracaoEvent {
  const EcommerceConfiguracaoSalvou();
}
