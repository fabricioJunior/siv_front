import 'package:core/equals.dart';

abstract class TerminalDoUsuario implements Equatable {
  int get id;
  int get idEmpresa;
  String get nome;

  factory TerminalDoUsuario.create({
    required int id,
    required int idEmpresa,
    required String nome,
  }) = _TerminalDoUsuarioImpl;

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}

class _TerminalDoUsuarioImpl implements TerminalDoUsuario {
  @override
  final int id;
  @override
  final int idEmpresa;
  @override
  final String nome;

  const _TerminalDoUsuarioImpl({
    required this.id,
    required this.idEmpresa,
    required this.nome,
  });

  _TerminalDoUsuarioImpl copyWith({
    int? id,
    int? idEmpresa,
    String? nome,
  }) {
    return _TerminalDoUsuarioImpl(
      id: id ?? this.id,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      nome: nome ?? this.nome,
    );
  }

  @override
  List<Object?> get props => [id, idEmpresa, nome];

  @override
  bool? get stringify => true;
}

extension TerminalDoUsuarioCopyWith on TerminalDoUsuario {
  TerminalDoUsuario copyWith({
    int? id,
    int? idEmpresa,
    String? nome,
  }) {
    if (this is _TerminalDoUsuarioImpl) {
      return (this as _TerminalDoUsuarioImpl).copyWith(
        id: id,
        idEmpresa: idEmpresa,
        nome: nome,
      );
    }

    return TerminalDoUsuario.create(
      id: id ?? this.id,
      idEmpresa: idEmpresa ?? this.idEmpresa,
      nome: nome ?? this.nome,
    );
  }
}
