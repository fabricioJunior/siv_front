part of 'integracao_meta_bloc.dart';

const Object _sentinela = Object();

class IntegracaoMetaState extends Equatable {
  final int? empresaId;
  final IntegracaoMeta? configuracao;
  final IntegracaoMetaTeste? teste;
  final bool carregando;
  final bool salvando;
  final bool testando;
  final bool salvou;
  final String? erro;

  const IntegracaoMetaState({
    this.empresaId,
    this.configuracao,
    this.teste,
    this.carregando = false,
    this.salvando = false,
    this.testando = false,
    this.salvou = false,
    this.erro,
  });

  IntegracaoMetaState copyWith({
    int? empresaId,
    IntegracaoMeta? configuracao,
    IntegracaoMetaTeste? teste,
    bool? carregando,
    bool? salvando,
    bool? testando,
    bool? salvou,
    Object? erro = _sentinela,
  }) {
    return IntegracaoMetaState(
      empresaId: empresaId ?? this.empresaId,
      configuracao: configuracao ?? this.configuracao,
      teste: teste ?? this.teste,
      carregando: carregando ?? this.carregando,
      salvando: salvando ?? this.salvando,
      testando: testando ?? this.testando,
      salvou: salvou ?? this.salvou,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [
        empresaId,
        configuracao,
        teste,
        carregando,
        salvando,
        testando,
        salvou,
        erro,
      ];
}
