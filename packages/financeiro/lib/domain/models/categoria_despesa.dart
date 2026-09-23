import 'package:core/equals.dart';

class CategoriaDespesa extends Equatable {
  final int? id;
  final int? empresaId;
  final String nome;
  final bool inativa;

  const CategoriaDespesa({
    this.id,
    this.empresaId,
    required this.nome,
    this.inativa = false,
  });

  CategoriaDespesa copyWith({
    int? id,
    int? empresaId,
    String? nome,
    bool? inativa,
  }) {
    return CategoriaDespesa(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativa: inativa ?? this.inativa,
    );
  }

  @override
  List<Object?> get props => [id, empresaId, nome, inativa];

  @override
  bool? get stringify => true;
}
