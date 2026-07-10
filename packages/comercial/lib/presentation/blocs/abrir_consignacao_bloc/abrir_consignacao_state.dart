part of 'abrir_consignacao_bloc.dart';

enum AbrirConsignacaoStep { editando, salvando, sucesso, falha }

class AbrirConsignacaoState extends Equatable {
  final AbrirConsignacaoStep step;
  final SelectData? pessoaSelecionada;
  final SelectData? funcionarioSelecionado;
  final SelectData? tabelaSelecionada;
  final String observacao;
  final String? erro;
  final Consignacao? consignacaoCriada;

  const AbrirConsignacaoState({
    this.step = AbrirConsignacaoStep.editando,
    this.pessoaSelecionada,
    this.funcionarioSelecionado,
    this.tabelaSelecionada,
    this.observacao = '',
    this.erro,
    this.consignacaoCriada,
  });

  bool get podeConfirmar =>
      pessoaSelecionada != null &&
      funcionarioSelecionado != null &&
      tabelaSelecionada != null &&
      step != AbrirConsignacaoStep.salvando;

  AbrirConsignacaoState copyWith({
    AbrirConsignacaoStep? step,
    SelectData? pessoaSelecionada,
    bool limparPessoa = false,
    SelectData? funcionarioSelecionado,
    bool limparFuncionario = false,
    SelectData? tabelaSelecionada,
    bool limparTabela = false,
    String? observacao,
    String? erro,
    Consignacao? consignacaoCriada,
  }) {
    return AbrirConsignacaoState(
      step: step ?? this.step,
      pessoaSelecionada:
          limparPessoa ? null : (pessoaSelecionada ?? this.pessoaSelecionada),
      funcionarioSelecionado: limparFuncionario
          ? null
          : (funcionarioSelecionado ?? this.funcionarioSelecionado),
      tabelaSelecionada:
          limparTabela ? null : (tabelaSelecionada ?? this.tabelaSelecionada),
      observacao: observacao ?? this.observacao,
      erro: erro,
      consignacaoCriada: consignacaoCriada ?? this.consignacaoCriada,
    );
  }

  @override
  List<Object?> get props => [
        step,
        pessoaSelecionada,
        funcionarioSelecionado,
        tabelaSelecionada,
        observacao,
        erro,
        consignacaoCriada,
      ];
}
