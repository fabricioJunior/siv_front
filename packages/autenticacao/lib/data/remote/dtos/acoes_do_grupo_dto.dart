import 'package:autenticacao/domain/models/acoes_do_grupo.dart';

/// Converte a resposta de GET/PUT /componentes-grupos/:id/acoes. Parse
/// manual (sem json_serializable) pra não exigir rodar build_runner.
AcoesDoGrupo acoesDoGrupoFromJson(Map<String, dynamic> json) {
  List<String> strings(dynamic v) =>
      (v as List? ?? const []).map((e) => e as String).toList();

  AcaoDoGrupo acao(Map<String, dynamic> j) => AcaoDoGrupo(
        id: j['id'] as String,
        nome: j['nome'] as String,
        descricao: (j['descricao'] as String?) ?? '',
        requer: strings(j['requer']),
        componentes: strings(j['componentes']),
        estado: EstadoAcaoDoGrupo.values.firstWhere(
          (e) => e.name == j['estado'],
          orElse: () => EstadoAcaoDoGrupo.desligada,
        ),
        faltando: strings(j['faltando']),
      );

  return AcoesDoGrupo(
    grupoId: (json['grupoId'] as num).toInt(),
    componentesAvulsos: strings(json['componentesAvulsos']),
    fluxos: (json['fluxos'] as List)
        .map((f) => f as Map<String, dynamic>)
        .map(
          (f) => FluxoDoGrupo(
            id: f['id'] as String,
            nome: f['nome'] as String,
            descricao: (f['descricao'] as String?) ?? '',
            acoes: (f['acoes'] as List)
                .map((a) => acao(a as Map<String, dynamic>))
                .toList(),
          ),
        )
        .toList(),
  );
}
