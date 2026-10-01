part of 'importacao_guiada_bloc.dart';

const _manter = Object();

class EtapaImportacaoState extends Equatable {
  final ImportacaoGuiada? importacao;
  final String? arquivoNome;
  final bool enviando;

  /// Só a etapa de vendas usa.
  final int? tabelaDePrecoId;
  final int? funcionarioId;

  const EtapaImportacaoState({
    this.importacao,
    this.arquivoNome,
    this.enviando = false,
    this.tabelaDePrecoId,
    this.funcionarioId,
  });

  /// `Object? = _manter` deixa distinguir "não mexer" de "limpar (null)".
  EtapaImportacaoState copyWith({
    Object? importacao = _manter,
    Object? arquivoNome = _manter,
    bool? enviando,
    Object? tabelaDePrecoId = _manter,
    Object? funcionarioId = _manter,
  }) {
    return EtapaImportacaoState(
      importacao: identical(importacao, _manter)
          ? this.importacao
          : importacao as ImportacaoGuiada?,
      arquivoNome: identical(arquivoNome, _manter)
          ? this.arquivoNome
          : arquivoNome as String?,
      enviando: enviando ?? this.enviando,
      tabelaDePrecoId: identical(tabelaDePrecoId, _manter)
          ? this.tabelaDePrecoId
          : tabelaDePrecoId as int?,
      funcionarioId: identical(funcionarioId, _manter)
          ? this.funcionarioId
          : funcionarioId as int?,
    );
  }

  bool get emAndamento => importacao?.situacao.emAndamento ?? false;

  bool get concluida => importacao?.situacao == ImportacaoSituacao.concluida;

  @override
  List<Object?> get props => [
    importacao,
    arquivoNome,
    enviando,
    tabelaDePrecoId,
    funcionarioId,
  ];
}

class ImportacaoGuiadaState extends Equatable {
  final Map<ImportacaoEtapa, EtapaImportacaoState> etapas;
  final ImportacaoEtapa etapaAtual;
  final bool carregando;

  /// Mensagens de uma exibição só (SnackBar): qualquer emissão seguinte
  /// que não as repasse as limpa.
  final String? erro;
  final String? mensagem;

  ImportacaoGuiadaState({
    Map<ImportacaoEtapa, EtapaImportacaoState>? etapas,
    this.etapaAtual = ImportacaoEtapa.clientes,
    this.carregando = false,
    this.erro,
    this.mensagem,
  }) : etapas =
           etapas ??
           {
             for (final etapa in ImportacaoEtapa.values)
               etapa: const EtapaImportacaoState(),
           };

  EtapaImportacaoState operator [](ImportacaoEtapa etapa) => etapas[etapa]!;

  /// A primeira etapa está sempre liberada; as demais só depois da anterior
  /// concluída (a ordem importa: vendas dependem de clientes e produtos).
  bool liberada(ImportacaoEtapa etapa) {
    final anterior = etapa.anterior;
    return anterior == null || this[anterior].concluida;
  }

  ImportacaoGuiadaState copyWith({
    Map<ImportacaoEtapa, EtapaImportacaoState>? etapas,
    ImportacaoEtapa? etapaAtual,
    bool? carregando,
    String? erro,
    String? mensagem,
  }) {
    return ImportacaoGuiadaState(
      etapas: etapas ?? this.etapas,
      etapaAtual: etapaAtual ?? this.etapaAtual,
      carregando: carregando ?? this.carregando,
      erro: erro,
      mensagem: mensagem,
    );
  }

  /// Copia trocando só o estado de uma etapa.
  ImportacaoGuiadaState comEtapa(
    ImportacaoEtapa etapa,
    EtapaImportacaoState novo, {
    String? erro,
    String? mensagem,
  }) {
    return copyWith(
      etapas: {...etapas, etapa: novo},
      erro: erro,
      mensagem: mensagem,
    );
  }

  @override
  List<Object?> get props => [etapas, etapaAtual, carregando, erro, mensagem];
}
