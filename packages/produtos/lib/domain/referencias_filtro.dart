import 'package:core/equals.dart';
import 'package:produtos/domain/models/referencia.dart';

/// Filtros escolhidos na lista de Referências. Quem filtra é o servidor (`GET /referencias/busca`); aqui fica só o
/// valor e as regras que as linhas usam para mostrar as etiquetas "Sem NCM" / "Sem peso" (as mesmas do servidor).
class ReferenciasFiltro extends Equatable {
  final String busca;
  final int? categoriaId;
  final bool semNcm;
  final bool semPeso;

  const ReferenciasFiltro({
    this.busca = '',
    this.categoriaId,
    this.semNcm = false,
    this.semPeso = false,
  });

  bool get ativo =>
      busca.trim().isNotEmpty || categoriaId != null || semNcm || semPeso;

  ReferenciasFiltro copyWith({
    String? busca,
    Object? categoriaId = _manter,
    bool? semNcm,
    bool? semPeso,
  }) {
    return ReferenciasFiltro(
      busca: busca ?? this.busca,
      categoriaId: identical(categoriaId, _manter)
          ? this.categoriaId
          : categoriaId as int?,
      semNcm: semNcm ?? this.semNcm,
      semPeso: semPeso ?? this.semPeso,
    );
  }

  static const _manter = Object();

  /// NCM válido tem 8 dígitos; nulo ou fora disso conta como pendência (mesma regra do servidor).
  static bool semNcmDe(Referencia r) =>
      !RegExp(r'^\d{8}$').hasMatch(r.ncm ?? '');

  static bool semPesoDe(Referencia r) => (r.pesoGramas ?? 0) <= 0;

  /// Número que o usuário enxerga: o ID externo (código do sistema de origem) ou, se não houver, o ID interno.
  static String numeroDe(Referencia r) {
    final externo = (r.idExterno ?? '').trim();
    return externo.isNotEmpty ? externo : '${r.id ?? ''}';
  }

  @override
  List<Object?> get props => [busca, categoriaId, semNcm, semPeso];
}
