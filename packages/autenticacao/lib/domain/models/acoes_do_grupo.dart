import 'package:core/equals.dart';

/// Situação de uma ação (ex: "Fazer venda") em um grupo de acesso.
/// - [ligada]: o admin ligou e o grupo tem todas as permissões da ação;
/// - [incompleta]: o admin ligou mas falta alguma permissão (ex: alguém
///   tirou na lista individual) -- `faltando` diz quais;
/// - [desligada]: não ligada.
enum EstadoAcaoDoGrupo { ligada, incompleta, desligada }

class AcaoDoGrupo extends Equatable {
  final String id;
  final String nome;
  final String descricao;

  /// Ids de outras ações que precisam estar ligadas junto.
  final List<String> requer;

  /// Códigos das permissões que a ação exige.
  final List<String> componentes;
  final EstadoAcaoDoGrupo estado;

  /// Códigos das permissões da ação que o grupo ainda não tem.
  final List<String> faltando;

  const AcaoDoGrupo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.requer,
    required this.componentes,
    required this.estado,
    required this.faltando,
  });

  @override
  List<Object?> get props =>
      [id, nome, descricao, requer, componentes, estado, faltando];
}

class FluxoDoGrupo extends Equatable {
  final String id;
  final String nome;
  final String descricao;
  final List<AcaoDoGrupo> acoes;

  const FluxoDoGrupo({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.acoes,
  });

  int get acoesLigadas =>
      acoes.where((a) => a.estado != EstadoAcaoDoGrupo.desligada).length;

  @override
  List<Object?> get props => [id, nome, descricao, acoes];
}

class AcoesDoGrupo extends Equatable {
  final int grupoId;
  final List<FluxoDoGrupo> fluxos;

  /// Permissões do grupo que nenhuma ação ligada cobre (marcadas na lista
  /// de permissões individuais).
  final List<String> componentesAvulsos;

  const AcoesDoGrupo({
    required this.grupoId,
    required this.fluxos,
    required this.componentesAvulsos,
  });

  @override
  List<Object?> get props => [grupoId, fluxos, componentesAvulsos];
}
