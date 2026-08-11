import 'package:core/equals.dart';

abstract class Terminal implements Equatable {
  DateTime? get criadoEm;
  DateTime? get atualizadoEm;
  int? get id;
  int get empresaId;
  String get nome;
  bool? get inativo;
  String get tipo;

  factory Terminal.create({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    required int empresaId,
    required String nome,
    bool? inativo,
    required String tipo,
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
    tipo,
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

  @override
  final String tipo;

  const _TerminalImpl({
    this.criadoEm,
    this.atualizadoEm,
    this.id,
    required this.empresaId,
    required this.nome,
    this.inativo,
    this.tipo = 'fisico',
  });

  _TerminalImpl copyWith({
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? id,
    int? empresaId,
    String? nome,
    bool? inativo,
    String? tipo,
  }) {
    return _TerminalImpl(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
      tipo: tipo ?? this.tipo,
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
    tipo,
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
    String? tipo,
  }) {
    if (this is _TerminalImpl) {
      return (this as _TerminalImpl).copyWith(
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        id: id,
        empresaId: empresaId,
        nome: nome,
        inativo: inativo,
        tipo: tipo,
      );
    }

    return Terminal.create(
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nome: nome ?? this.nome,
      inativo: inativo ?? this.inativo,
      tipo: tipo ?? this.tipo,
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
