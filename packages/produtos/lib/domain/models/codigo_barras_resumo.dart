import 'package:core/equals.dart';

class CodigoBarrasResumo extends Equatable {
  final String codigo;
  final int produtoId;
  final int? referenciaId;

  const CodigoBarrasResumo({
    required this.codigo,
    required this.produtoId,
    this.referenciaId,
  });

  @override
  List<Object?> get props => [codigo, produtoId, referenciaId];

  @override
  bool? get stringify => true;
}
