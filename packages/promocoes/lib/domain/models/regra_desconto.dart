import 'package:core/equals.dart';

// Compartilhado entre Promocao e Cupom -- mesmo shape de regra de desconto e
// de escopo nos dois modulos do backend (promocao.entity.ts / cupom.entity.ts).
enum TipoDesconto {
  percentual,
  valorFixo,
  precoFixo;

  static TipoDesconto fromString(String? value) {
    switch (value) {
      case 'valor_fixo':
        return TipoDesconto.valorFixo;
      case 'preco_fixo':
        return TipoDesconto.precoFixo;
      case 'percentual':
      default:
        return TipoDesconto.percentual;
    }
  }

  String get value {
    switch (this) {
      case TipoDesconto.valorFixo:
        return 'valor_fixo';
      case TipoDesconto.precoFixo:
        return 'preco_fixo';
      case TipoDesconto.percentual:
        return 'percentual';
    }
  }
}

enum TipoEscopo {
  geral,
  referencias,
  comboKit,
  comboLevePague;

  static TipoEscopo fromString(String? value) {
    switch (value) {
      case 'referencias':
        return TipoEscopo.referencias;
      case 'combo_kit':
        return TipoEscopo.comboKit;
      case 'combo_leve_pague':
        return TipoEscopo.comboLevePague;
      case 'geral':
      default:
        return TipoEscopo.geral;
    }
  }

  String get value {
    switch (this) {
      case TipoEscopo.referencias:
        return 'referencias';
      case TipoEscopo.comboKit:
        return 'combo_kit';
      case TipoEscopo.comboLevePague:
        return 'combo_leve_pague';
      case TipoEscopo.geral:
        return 'geral';
    }
  }
}

// Item do combo (referencia exigida + quantidade), usado quando tipoEscopo=comboKit.
class ItemComboKit extends Equatable {
  final int referenciaId;
  final int quantidadeExigida;

  const ItemComboKit({
    required this.referenciaId,
    required this.quantidadeExigida,
  });

  factory ItemComboKit.fromJson(Map<String, dynamic> json) {
    return ItemComboKit(
      referenciaId: (json['referenciaId'] as num).toInt(),
      quantidadeExigida: (json['quantidadeExigida'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'referenciaId': referenciaId,
        'quantidadeExigida': quantidadeExigida,
      };

  @override
  List<Object?> get props => [referenciaId, quantidadeExigida];

  @override
  bool? get stringify => true;
}
