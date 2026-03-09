import 'package:core/equals.dart';

abstract class PermissaoDoUsuario implements Equatable {
  int get id;
  int get empresaId;
  int get grupoId;
  String get grupoNome;
  String get componenteId;
  String get componenteNome;
  int get descontinuado;

  bool get estaDescontinuado => descontinuado == 1;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        grupoId,
        grupoNome,
        componenteId,
        componenteNome,
        descontinuado,
      ];

  @override
  bool? get stringify => true;
}

