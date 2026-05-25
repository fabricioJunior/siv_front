import 'package:core/equals.dart';
import 'package:core/impressora.dart';

abstract class EtiquetaImpressaoItem implements ItemDeImpressao, Equatable {
  String get descricao;
  String get zpl;

  factory EtiquetaImpressaoItem.create({
    required String descricao,
    required String zpl,
  }) = _EtiquetaImpressaoItemImpl;

  @override
  List<Object?> get props => [descricao, zpl];

  @override
  bool? get stringify => true;
}

class _EtiquetaImpressaoItemImpl implements EtiquetaImpressaoItem {
  @override
  final String descricao;

  @override
  final String zpl;

  _EtiquetaImpressaoItemImpl({required this.descricao, required this.zpl});

  _EtiquetaImpressaoItemImpl copyWith({String? descricao, String? zpl}) {
    return _EtiquetaImpressaoItemImpl(
      descricao: descricao ?? this.descricao,
      zpl: zpl ?? this.zpl,
    );
  }

  @override
  List<Object?> get props => [descricao, zpl];

  @override
  bool? get stringify => true;
}

extension EtiquetaImpressaoItemCopyWith on EtiquetaImpressaoItem {
  EtiquetaImpressaoItem copyWith({String? descricao, String? zpl}) {
    if (this is _EtiquetaImpressaoItemImpl) {
      return (this as _EtiquetaImpressaoItemImpl).copyWith(
        descricao: descricao,
        zpl: zpl,
      );
    }

    return EtiquetaImpressaoItem.create(
      descricao: descricao ?? this.descricao,
      zpl: zpl ?? this.zpl,
    );
  }
}
