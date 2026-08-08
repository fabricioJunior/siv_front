import 'package:core/equals.dart';

// Item enviado na apuracao (POST /v1/desconto-elegibilidade/apurar) -- espelha
// ItemElegibilidadeDto do backend (apps/api/.../desconto-elegibilidade/dto).
class ItemApuracaoElegibilidade extends Equatable {
  final int referenciaId;
  final int produtoId;
  final int quantidade;
  final double valorUnitario;

  const ItemApuracaoElegibilidade({
    required this.referenciaId,
    required this.produtoId,
    required this.quantidade,
    required this.valorUnitario,
  });

  Map<String, dynamic> toJson() => {
        'referenciaId': referenciaId,
        'produtoId': produtoId,
        'quantidade': quantidade,
        'valorUnitario': valorUnitario,
      };

  @override
  List<Object?> get props =>
      [referenciaId, produtoId, quantidade, valorUnitario];
}

// Espelha OpcaoElegivelResponse do backend.
class OpcaoElegivel extends Equatable {
  final String tipo; // 'promocao' | 'cupom'
  final int id;
  final String nome;
  final double valorDesconto;
  final double valorFinalUnitario;

  const OpcaoElegivel({
    required this.tipo,
    required this.id,
    required this.nome,
    required this.valorDesconto,
    required this.valorFinalUnitario,
  });

  factory OpcaoElegivel.fromJson(Map<String, dynamic> json) {
    return OpcaoElegivel(
      tipo: json['tipo'] as String,
      id: (json['id'] as num).toInt(),
      nome: json['nome'] as String,
      valorDesconto: (json['valorDesconto'] as num).toDouble(),
      valorFinalUnitario: (json['valorFinalUnitario'] as num).toDouble(),
    );
  }

  bool get ehCupom => tipo == 'cupom';

  @override
  List<Object?> get props =>
      [tipo, id, nome, valorDesconto, valorFinalUnitario];
}

// Espelha ItemElegibilidadeResponse do backend.
class ItemElegibilidade extends Equatable {
  final int referenciaId;
  final List<OpcaoElegivel> opcoesElegiveis;

  const ItemElegibilidade({
    required this.referenciaId,
    required this.opcoesElegiveis,
  });

  factory ItemElegibilidade.fromJson(Map<String, dynamic> json) {
    final opcoes = json['opcoesElegiveis'] as List<dynamic>? ?? const [];
    return ItemElegibilidade(
      referenciaId: (json['referenciaId'] as num).toInt(),
      opcoesElegiveis: opcoes
          .map((o) => OpcaoElegivel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [referenciaId, opcoesElegiveis];
}

// Espelha ElegibilidadeResponse do backend.
class ResultadoElegibilidade extends Equatable {
  final List<ItemElegibilidade> itens;
  final String? cupomInvalido;

  const ResultadoElegibilidade({
    required this.itens,
    this.cupomInvalido,
  });

  factory ResultadoElegibilidade.fromJson(Map<String, dynamic> json) {
    final itens = json['itens'] as List<dynamic>? ?? const [];
    return ResultadoElegibilidade(
      itens: itens
          .map((i) => ItemElegibilidade.fromJson(i as Map<String, dynamic>))
          .toList(),
      cupomInvalido: json['cupomInvalido'] as String?,
    );
  }

  @override
  List<Object?> get props => [itens, cupomInvalido];
}
