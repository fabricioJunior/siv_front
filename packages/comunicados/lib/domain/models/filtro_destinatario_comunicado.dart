import 'package:core/equals.dart';

class FiltroDestinatarioComunicado extends Equatable {
  final List<int> empresaIds;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String? origem; // ecommerce, ia_vendas, atendente_humano, loja_fisica_direto
  final String? ativoInativo; // ativo, inativo
  final int? diasJanela;

  const FiltroDestinatarioComunicado({
    required this.empresaIds,
    this.dataInicio,
    this.dataFim,
    this.origem,
    this.ativoInativo,
    this.diasJanela,
  });

  FiltroDestinatarioComunicado copyWith({
    List<int>? empresaIds,
    DateTime? dataInicio,
    bool limparDataInicio = false,
    DateTime? dataFim,
    bool limparDataFim = false,
    String? origem,
    bool limparOrigem = false,
    String? ativoInativo,
    bool limparAtivoInativo = false,
    int? diasJanela,
  }) {
    return FiltroDestinatarioComunicado(
      empresaIds: empresaIds ?? this.empresaIds,
      dataInicio: limparDataInicio ? null : (dataInicio ?? this.dataInicio),
      dataFim: limparDataFim ? null : (dataFim ?? this.dataFim),
      origem: limparOrigem ? null : (origem ?? this.origem),
      ativoInativo: limparAtivoInativo
          ? null
          : (ativoInativo ?? this.ativoInativo),
      diasJanela: diasJanela ?? this.diasJanela,
    );
  }

  String _fmtData(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Corpo para POST (aceita array nativo de `empresaIds`).
  Map<String, dynamic> toBody() {
    return {
      'empresaIds': empresaIds,
      if (dataInicio != null) 'dataInicio': _fmtData(dataInicio!),
      if (dataFim != null) 'dataFim': _fmtData(dataFim!),
      if (origem != null) 'origem': origem,
      if (ativoInativo != null) 'ativoInativo': ativoInativo,
      if (diasJanela != null) 'diasJanela': diasJanela,
    };
  }

  /// Query params para GET. `empresaIds` é enviado como lista separada por
  /// vírgula -- válido pois a sessão sempre opera com uma única empresa
  /// selecionada (sem seletor multi-empresa nesta versão).
  Map<String, String> toQueryParams() {
    return {
      'empresaIds': empresaIds.join(','),
      if (dataInicio != null) 'dataInicio': _fmtData(dataInicio!),
      if (dataFim != null) 'dataFim': _fmtData(dataFim!),
      if (origem != null) 'origem': origem!,
      if (ativoInativo != null) 'ativoInativo': ativoInativo!,
      if (diasJanela != null) 'diasJanela': diasJanela.toString(),
    };
  }

  @override
  List<Object?> get props => [
    empresaIds,
    dataInicio,
    dataFim,
    origem,
    ativoInativo,
    diasJanela,
  ];
}
