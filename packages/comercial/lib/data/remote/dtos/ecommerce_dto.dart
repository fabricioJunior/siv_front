import 'package:comercial/models.dart';

class EcommerceDto implements Ecommerce {
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

  const EcommerceDto({
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

  factory EcommerceDto.fromJson(Map<String, dynamic> json) {
    return EcommerceDto(
      id: _toInt(json['id']),
      empresaId: _toInt(json['empresaId']) ?? 0,
      titulo: (json['titulo'] ?? '').toString(),
      subtitulo: json['subtitulo']?.toString(),
      descricao: json['descricao']?.toString(),
      icone: json['icone']?.toString(),
      empresaEstoqueId: _toInt(json['empresaEstoqueId']),
      tabelaDePrecoId: _toInt(json['tabelaDePrecoId']),
      terminalId: _toInt(json['terminalId']),
      formaDePagamentoId: _toInt(json['formaDePagamentoId']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empresaId': empresaId,
      'titulo': titulo,
      if (subtitulo != null) 'subtitulo': subtitulo,
      if (descricao != null) 'descricao': descricao,
      if (icone != null) 'icone': icone,
      if (empresaEstoqueId != null) 'empresaEstoqueId': empresaEstoqueId,
      if (tabelaDePrecoId != null) 'tabelaDePrecoId': tabelaDePrecoId,
      if (terminalId != null) 'terminalId': terminalId,
      if (formaDePagamentoId != null) 'formaDePagamentoId': formaDePagamentoId,
    };
  }

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

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');
