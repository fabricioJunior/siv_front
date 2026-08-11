import 'package:core/equals.dart';

abstract class Ecommerce implements Equatable {
  int? get id;
  int get empresaId;
  String get titulo;
  String? get subtitulo;
  String? get descricao;
  String? get icone;
  int? get empresaEstoqueId;
  int? get tabelaDePrecoId;
  int? get terminalId;
  int? get formaDePagamentoId;

  factory Ecommerce.create({
    int? id,
    required int empresaId,
    required String titulo,
    String? subtitulo,
    String? descricao,
    String? icone,
    int? empresaEstoqueId,
    int? tabelaDePrecoId,
    int? terminalId,
    int? formaDePagamentoId,
  }) = _EcommerceImpl;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        titulo,
        subtitulo,
        descricao,
        icone,
        empresaEstoqueId,
        tabelaDePrecoId,
        terminalId,
        formaDePagamentoId,
      ];
}

class _EcommerceImpl implements Ecommerce {
  @override
  final int? id;
  @override
  final int empresaId;
  @override
  final String titulo;
  @override
  final String? subtitulo;
  @override
  final String? descricao;
  @override
  final String? icone;
  @override
  final int? empresaEstoqueId;
  @override
  final int? tabelaDePrecoId;
  @override
  final int? terminalId;
  @override
  final int? formaDePagamentoId;

  const _EcommerceImpl({
    this.id,
    required this.empresaId,
    required this.titulo,
    this.subtitulo,
    this.descricao,
    this.icone,
    this.empresaEstoqueId,
    this.tabelaDePrecoId,
    this.terminalId,
    this.formaDePagamentoId,
  });

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [
        id,
        empresaId,
        titulo,
        subtitulo,
        descricao,
        icone,
        empresaEstoqueId,
        tabelaDePrecoId,
        terminalId,
        formaDePagamentoId,
      ];
}
