part of 'adicionar_variacoes_bloc.dart';

abstract class AdicionarVariacoesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdicionarVariacoesIniciou extends AdicionarVariacoesEvent {
  final int referenciaId;
  final Set<int> corIdsNaGrade;
  final Set<int> tamanhoIdsNaGrade;
  final Set<int> estampaIdsNaGrade;

  /// Chaves exatas ('$corId|$tamanhoId|$estampaId') já existentes na
  /// grade -- usadas pra calcular o diff de combinações novas.
  final Set<String> chavesNaGrade;

  /// Seleção inicial do rascunho (ex.: cores/tamanhos já contados). Não é a
  /// grade existente -- essa vai em [corIdsNaGrade]/[tamanhoIdsNaGrade].
  final Set<int> coresSelecionadasIniciais;
  final Set<int> tamanhosSelecionadosIniciais;

  AdicionarVariacoesIniciou({
    required this.referenciaId,
    this.corIdsNaGrade = const {},
    this.tamanhoIdsNaGrade = const {},
    this.estampaIdsNaGrade = const {},
    this.chavesNaGrade = const {},
    this.coresSelecionadasIniciais = const {},
    this.tamanhosSelecionadosIniciais = const {},
  });

  @override
  List<Object?> get props => [
    referenciaId,
    corIdsNaGrade,
    tamanhoIdsNaGrade,
    estampaIdsNaGrade,
    chavesNaGrade,
    coresSelecionadasIniciais,
    tamanhosSelecionadosIniciais,
  ];
}

class AdicionarVariacoesCorAlternou extends AdicionarVariacoesEvent {
  final int corId;
  AdicionarVariacoesCorAlternou({required this.corId});
  @override
  List<Object?> get props => [corId];
}

class AdicionarVariacoesTamanhoAlternou extends AdicionarVariacoesEvent {
  final int tamanhoId;
  AdicionarVariacoesTamanhoAlternou({required this.tamanhoId});
  @override
  List<Object?> get props => [tamanhoId];
}

class AdicionarVariacoesEstampaAlternou extends AdicionarVariacoesEvent {
  final int estampaId;
  AdicionarVariacoesEstampaAlternou({required this.estampaId});
  @override
  List<Object?> get props => [estampaId];
}

class AdicionarVariacoesEstampasAtivouAlternou extends AdicionarVariacoesEvent {
  final bool ativo;
  AdicionarVariacoesEstampasAtivouAlternou({required this.ativo});
  @override
  List<Object?> get props => [ativo];
}

enum CampoBuscaVariacoes { cor, tamanho, estampa }

class AdicionarVariacoesBuscaAlterou extends AdicionarVariacoesEvent {
  final CampoBuscaVariacoes campo;
  final String texto;
  AdicionarVariacoesBuscaAlterou({required this.campo, required this.texto});
  @override
  List<Object?> get props => [campo, texto];
}

class AdicionarVariacoesConfirmou extends AdicionarVariacoesEvent {
  /// Código de barras digitado/bipado por combinação (chave via
  /// [chaveComboGrade]), quando a origem escolhida foi "Do fornecedor".
  /// `null` (não informado nesse evento) = gerar pelo SIV, mantendo o
  /// comportamento de sempre. Combinação sem entrada no mapa (usuário não
  /// bipou aquela) é criada sem código de barras, pra bipar depois.
  final Map<String, String>? codigosManuais;

  /// Só considerado quando [codigosManuais] != null: combinação sem entrada
  /// no mapa é criada sem código (padrão, `false`) ou tem o código gerado
  /// pelo SIV na hora (`true`) -- toggle "os que ficarem sem código" da
  /// etapa de bipagem.
  final bool gerarSivParaRestantes;

  AdicionarVariacoesConfirmou({
    this.codigosManuais,
    this.gerarSivParaRestantes = false,
  });

  @override
  List<Object?> get props => [codigosManuais, gerarSivParaRestantes];
}
