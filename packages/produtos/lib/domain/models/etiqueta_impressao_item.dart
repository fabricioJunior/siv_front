import 'package:core/equals.dart';
import 'package:core/impressora.dart';

abstract class EtiquetaImpressaoItem implements ItemDeImpressao, Equatable {
  @override
  String get descricao;
  @override
  String get zpl;
  String get referencia;
  String get cor;
  String get tamanho;
  int get viaOrdem;

  factory EtiquetaImpressaoItem.create({
    required String descricao,
    required String zpl,
    required String referencia,
    required String cor,
    required String tamanho,
    required int viaOrdem,
  }) = _EtiquetaImpressaoItemImpl;

  @override
  List<Object?> get props => [
    descricao,
    zpl,
    referencia,
    cor,
    tamanho,
    viaOrdem,
  ];

  @override
  bool? get stringify => true;
}

class _EtiquetaImpressaoItemImpl implements EtiquetaImpressaoItem {
  @override
  final String descricao;

  @override
  final String zpl;

  @override
  final String referencia;

  @override
  final String cor;

  @override
  final String tamanho;

  @override
  final int viaOrdem;

  _EtiquetaImpressaoItemImpl({
    required this.descricao,
    required this.zpl,
    required this.referencia,
    required this.cor,
    required this.tamanho,
    required this.viaOrdem,
  });

  _EtiquetaImpressaoItemImpl copyWith({
    String? descricao,
    String? zpl,
    String? referencia,
    String? cor,
    String? tamanho,
    int? viaOrdem,
  }) {
    return _EtiquetaImpressaoItemImpl(
      descricao: descricao ?? this.descricao,
      zpl: zpl ?? this.zpl,
      referencia: referencia ?? this.referencia,
      cor: cor ?? this.cor,
      tamanho: tamanho ?? this.tamanho,
      viaOrdem: viaOrdem ?? this.viaOrdem,
    );
  }

  @override
  List<Object?> get props => [
    descricao,
    zpl,
    referencia,
    cor,
    tamanho,
    viaOrdem,
  ];

  @override
  bool? get stringify => true;
}

extension EtiquetaImpressaoItemCopyWith on EtiquetaImpressaoItem {
  EtiquetaImpressaoItem copyWith({
    String? descricao,
    String? zpl,
    String? referencia,
    String? cor,
    String? tamanho,
    int? viaOrdem,
  }) {
    if (this is _EtiquetaImpressaoItemImpl) {
      return (this as _EtiquetaImpressaoItemImpl).copyWith(
        descricao: descricao,
        zpl: zpl,
        referencia: referencia,
        cor: cor,
        tamanho: tamanho,
        viaOrdem: viaOrdem,
      );
    }

    return EtiquetaImpressaoItem.create(
      descricao: descricao ?? this.descricao,
      zpl: zpl ?? this.zpl,
      referencia: referencia ?? this.referencia,
      cor: cor ?? this.cor,
      tamanho: tamanho ?? this.tamanho,
      viaOrdem: viaOrdem ?? this.viaOrdem,
    );
  }
}
