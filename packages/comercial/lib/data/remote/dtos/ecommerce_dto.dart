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
  final List<int> formasDePagamentoIds;
  @override
  final bool apagado;
  @override
  final DateTime? apagadoEm;

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
    this.formasDePagamentoIds = const [],
    this.apagado = false,
    this.apagadoEm,
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
      formasDePagamentoIds: ((json['formasDePagamentoIds'] as List<dynamic>?) ?? const [])
          .map((id) => _toInt(id))
          .whereType<int>()
          .toList(),
      apagado: json['apagado'] == true,
      apagadoEm: DateTime.tryParse(json['apagadoEm']?.toString() ?? ''),
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
      if (formasDePagamentoIds.isNotEmpty) 'formasDePagamentoIds': formasDePagamentoIds,
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
        formasDePagamentoIds,
        apagado,
        apagadoEm,
      ];

  @override
  bool? get stringify => true;
}

int? _toInt(dynamic value) => int.tryParse(value?.toString() ?? '');
