import 'package:core/equals.dart';

/// Nome de referência contada ou descrição livre (sem referência) de uma contagem.
class ItemContagemEmAndamento extends Equatable {
  final String nome;
  final bool semReferencia;

  const ItemContagemEmAndamento(
      {required this.nome, this.semReferencia = false});

  factory ItemContagemEmAndamento.fromJson(Map<String, dynamic> json) =>
      ItemContagemEmAndamento(
        nome: json['nome'] as String? ?? '',
        semReferencia: json['semReferencia'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [nome, semReferencia];
}

/// Pedido de entrada por contagem ainda aberto, como aparece na lista.
class ContagemEmAndamento extends Equatable {
  final int pedidoId;
  final String fornecedor;
  final String? contador;
  final DateTime criadoEm;

  /// Etapa da trilha: contando, associando, etiquetando ou conferindo.
  final String etapa;

  /// Até 4 nomes, sem repetir: referências primeiro, depois descrições livres.
  final List<ItemContagemEmAndamento> itens;
  final int totalItens;

  const ContagemEmAndamento({
    required this.pedidoId,
    required this.fornecedor,
    required this.criadoEm,
    this.contador,
    this.etapa = 'contando',
    this.itens = const [],
    this.totalItens = 0,
  });

  factory ContagemEmAndamento.fromJson(Map<String, dynamic> json) {
    final itens = ((json['itens'] as List?) ?? const [])
        .map((e) => ItemContagemEmAndamento.fromJson(e as Map<String, dynamic>))
        .toList();
    return ContagemEmAndamento(
      pedidoId: (json['pedidoId'] as num).toInt(),
      fornecedor:
          (json['fornecedor'] as Map<String, dynamic>?)?['nome'] as String? ??
              '',
      contador:
          (json['funcionario'] as Map<String, dynamic>?)?['nome'] as String?,
      criadoEm: DateTime.parse(json['criadoEm'] as String).toLocal(),
      etapa: json['etapa'] as String? ?? 'contando',
      itens: itens,
      totalItens: (json['totalItens'] as num?)?.toInt() ?? itens.length,
    );
  }

  @override
  List<Object?> get props =>
      [pedidoId, fornecedor, contador, criadoEm, etapa, itens, totalItens];
}

class ContagensEmAndamentoPagina extends Equatable {
  final int total;
  final int totalDoFuncionario;
  final List<ContagemEmAndamento> itens;

  const ContagensEmAndamentoPagina({
    this.total = 0,
    this.totalDoFuncionario = 0,
    this.itens = const [],
  });

  factory ContagensEmAndamentoPagina.fromJson(Map<String, dynamic> json) =>
      ContagensEmAndamentoPagina(
        total: (json['total'] as num?)?.toInt() ?? 0,
        totalDoFuncionario: (json['totalDoFuncionario'] as num?)?.toInt() ?? 0,
        itens: ((json['itens'] as List?) ?? const [])
            .map((e) => ContagemEmAndamento.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  @override
  List<Object?> get props => [total, totalDoFuncionario, itens];
}
