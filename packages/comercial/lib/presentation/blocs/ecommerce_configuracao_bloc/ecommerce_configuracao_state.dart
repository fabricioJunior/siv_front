part of 'ecommerce_configuracao_bloc.dart';

class EcommerceConfiguracaoState extends Equatable {
  final int? id;
  final int? empresaId;
  final String? titulo;
  final String? subtitulo;
  final String? descricao;
  final String? icone;
  final int? empresaEstoqueId;
  final int? tabelaDePrecoId;
  final int? terminalId;
  final int? formaDePagamentoId;
  final String? erro;
  final EcommerceConfiguracaoStep step;

  const EcommerceConfiguracaoState({
    this.id,
    this.empresaId,
    this.titulo,
    this.subtitulo,
    this.descricao,
    this.icone,
    this.empresaEstoqueId,
    this.tabelaDePrecoId,
    this.terminalId,
    this.formaDePagamentoId,
    this.erro,
    required this.step,
  });

  EcommerceConfiguracaoState.fromModel(
    Ecommerce ecommerce, {
    EcommerceConfiguracaoStep? step,
  })  : id = ecommerce.id,
        empresaId = ecommerce.empresaId,
        titulo = ecommerce.titulo,
        subtitulo = ecommerce.subtitulo,
        descricao = ecommerce.descricao,
        icone = ecommerce.icone,
        empresaEstoqueId = ecommerce.empresaEstoqueId,
        tabelaDePrecoId = ecommerce.tabelaDePrecoId,
        terminalId = ecommerce.terminalId,
        formaDePagamentoId = ecommerce.formaDePagamentoId,
        erro = null,
        step = step ?? EcommerceConfiguracaoStep.carregado;

  EcommerceConfiguracaoState copyWith({
    int? id,
    int? empresaId,
    String? titulo,
    String? subtitulo,
    String? descricao,
    String? icone,
    int? empresaEstoqueId,
    int? tabelaDePrecoId,
    int? terminalId,
    int? formaDePagamentoId,
    String? erro,
    EcommerceConfiguracaoStep? step,
  }) {
    return EcommerceConfiguracaoState(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      titulo: titulo ?? this.titulo,
      subtitulo: subtitulo ?? this.subtitulo,
      descricao: descricao ?? this.descricao,
      icone: icone ?? this.icone,
      empresaEstoqueId: empresaEstoqueId ?? this.empresaEstoqueId,
      tabelaDePrecoId: tabelaDePrecoId ?? this.tabelaDePrecoId,
      terminalId: terminalId ?? this.terminalId,
      formaDePagamentoId: formaDePagamentoId ?? this.formaDePagamentoId,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
        id,
        empresaId,
        titulo,
        subtitulo,
        descricao,
        icone,
        empresaEstoqueId,
        tabelaDePrecoId,
        terminalId,
        formaDePagamentoId,
        erro,
        step,
      ];
}

enum EcommerceConfiguracaoStep {
  inicial,
  carregando,
  carregado,
  editando,
  salvo,
  criado,
  falha,
}
