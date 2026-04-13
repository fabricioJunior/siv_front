import 'package:core/equals.dart';

abstract class Terminal implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  int? get id;
  int get empresaId;
  String get nome;
  bool? get inativo;

  factory Terminal.create({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    required int empresaId,
    required String nome,
    bool? inativo,
  }) = _TerminalImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
    criadoEm,
    atualizadoEm,
    id,
    empresaId,
    nome,
    inativo,
  ];
}

class _TerminalImpl implements Terminal {
  @override
  final DateTime? criadoEm;

  @override
  final DateTime? atualizadoEm;

  @override
  final int? id;

  @override
  final int empresaId;

  @override
  final String nome;

  @override
  final bool? inativo;

  const _TerminalImpl({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    required this.empresaId,
    required this.nome,
    this.inativo,
  });

  _TerminalImpl copyWith({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    String? nome,
    bool? inativo,
  }) {
    return _TerminalImpl(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
    );
  }

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
    criadoEm,
    atualizadoEm,
    id,
    empresaId,
    nome,
    inativo,
  ];
}

extension TerminalCopyWith on Terminal {
  Terminal copyWith({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    String? nome,
    bool? inativo,
  }) {
    if (this is _TerminalImpl) {
      return (this as _TerminalImpl).copyWith(
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        id: id,
        empresaId: empresaId,
        nome: nome,
        inativo: inativo,
      );
    }

    return Terminal.create(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
    );
  }
}

//{
//   "criadoEm": "2026-04-08T18:35:54.500Z",
//   "atualizadoEm": "2026-04-08T18:35:54.500Z",
//   "id": 0,
//   "empresaId": 0,
//   "nome": "string",
//   "inativo": true
// }
