part of 'leitor_bloc.dart';

const Object _campoNaoInformado = Object();

enum LeitorAvisoTipo { codigoDuplicado }

class LeitorItemContado extends Equatable {
  final String codigoDeBarras;
  final String descricao;
  final int quantidadeLida;
  final int estoqueDisponivel;
  final Map<String, dynamic> dados;

  const LeitorItemContado({
    required this.codigoDeBarras,
    required this.descricao,
    required this.quantidadeLida,
    required this.estoqueDisponivel,
    required this.dados,
  });

  factory LeitorItemContado.fromData(LeitorData data) {
    return LeitorItemContado(
      codigoDeBarras: data.codigoDeBarras,
      descricao: data.descricao,
      quantidadeLida: 0,
      estoqueDisponivel: data.quantidade,
      dados: Map<String, dynamic>.from(data.dados),
    );
  }

  LeitorItemContado copyWith({
    String? codigoDeBarras,
    String? descricao,
    int? quantidadeLida,
    int? estoqueDisponivel,
    Map<String, dynamic>? dados,
  }) {
    return LeitorItemContado(
      codigoDeBarras: codigoDeBarras ?? this.codigoDeBarras,
      descricao: descricao ?? this.descricao,
      quantidadeLida: quantidadeLida ?? this.quantidadeLida,
      estoqueDisponivel: estoqueDisponivel ?? this.estoqueDisponivel,
      dados: dados ?? this.dados,
    );
  }

  @override
  List<Object?> get props => [
        codigoDeBarras,
        descricao,
        quantidadeLida,
        estoqueDisponivel,
        dados,
      ];
}

class LeitorState extends Equatable {
  final bool controlarQuantidade;
  final bool processando;
  final List<LeitorItemContado> itens;
  final LeitorItemContado? ultimoProdutoLido;
  final String? ultimoCodigoInformado;
  final bool ultimoCodigoLidoValido;
  final String? erro;
  final String? aviso;
  final LeitorAvisoTipo? avisoTipo;
  final int tokenUltimoProduto;
  final int tokenErro;
  final int tokenAviso;

  const LeitorState({
    required this.controlarQuantidade,
    required this.processando,
    required this.itens,
    required this.ultimoProdutoLido,
    required this.ultimoCodigoInformado,
    required this.ultimoCodigoLidoValido,
    required this.erro,
    required this.aviso,
    required this.avisoTipo,
    required this.tokenUltimoProduto,
    required this.tokenErro,
    required this.tokenAviso,
  });

  factory LeitorState.initial({bool controlarQuantidade = false}) {
    return LeitorState(
      controlarQuantidade: controlarQuantidade,
      processando: false,
      itens: const [],
      ultimoProdutoLido: null,
      ultimoCodigoInformado: null,
      ultimoCodigoLidoValido: false,
      erro: null,
      aviso: null,
      avisoTipo: null,
      tokenUltimoProduto: 0,
      tokenErro: 0,
      tokenAviso: 0,
    );
  }

  int get quantidadeTotalLida => itens.fold<int>(
        0,
        (total, item) => total + item.quantidadeLida,
      );

  LeitorState copyWith({
    bool? controlarQuantidade,
    bool? processando,
    List<LeitorItemContado>? itens,
    Object? ultimoProdutoLido = _campoNaoInformado,
    Object? ultimoCodigoInformado = _campoNaoInformado,
    bool? ultimoCodigoLidoValido,
    Object? erro = _campoNaoInformado,
    Object? aviso = _campoNaoInformado,
    Object? avisoTipo = _campoNaoInformado,
    int? tokenUltimoProduto,
    int? tokenErro,
    int? tokenAviso,
  }) {
    return LeitorState(
      controlarQuantidade: controlarQuantidade ?? this.controlarQuantidade,
      processando: processando ?? this.processando,
      itens: itens ?? this.itens,
      ultimoProdutoLido: identical(ultimoProdutoLido, _campoNaoInformado)
          ? this.ultimoProdutoLido
          : ultimoProdutoLido as LeitorItemContado?,
      ultimoCodigoInformado:
          identical(ultimoCodigoInformado, _campoNaoInformado)
              ? this.ultimoCodigoInformado
              : ultimoCodigoInformado as String?,
      ultimoCodigoLidoValido:
          ultimoCodigoLidoValido ?? this.ultimoCodigoLidoValido,
      erro: identical(erro, _campoNaoInformado) ? this.erro : erro as String?,
      aviso:
          identical(aviso, _campoNaoInformado) ? this.aviso : aviso as String?,
      avisoTipo: identical(avisoTipo, _campoNaoInformado)
          ? this.avisoTipo
          : avisoTipo as LeitorAvisoTipo?,
      tokenUltimoProduto: tokenUltimoProduto ?? this.tokenUltimoProduto,
      tokenErro: tokenErro ?? this.tokenErro,
      tokenAviso: tokenAviso ?? this.tokenAviso,
    );
  }

  @override
  List<Object?> get props => [
        controlarQuantidade,
        processando,
        itens,
        ultimoProdutoLido,
        ultimoCodigoInformado,
        ultimoCodigoLidoValido,
        erro,
        aviso,
        avisoTipo,
        tokenUltimoProduto,
        tokenErro,
        tokenAviso,
      ];
}
