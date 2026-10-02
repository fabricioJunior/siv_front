part of 'referencias_lista_bloc.dart';

abstract class ReferenciasListaEvent extends Equatable {
  const ReferenciasListaEvent();

  @override
  List<Object?> get props => [];
}

/// Primeira carga (sem filtro, ordenação padrão).
class ReferenciasListaIniciou extends ReferenciasListaEvent {
  const ReferenciasListaIniciou();
}

/// Qualquer mudança de busca, categoria, pendência ou ordenação: volta para a página 1.
class ReferenciasListaFiltrou extends ReferenciasListaEvent {
  final ReferenciasFiltro? filtro;
  final ReferenciasOrdenacao? ordenacao;

  const ReferenciasListaFiltrou({this.filtro, this.ordenacao});

  @override
  List<Object?> get props => [filtro, ordenacao];
}

/// Rolou até o fim: busca a próxima página com o mesmo filtro.
class ReferenciasListaCarregouMais extends ReferenciasListaEvent {
  const ReferenciasListaCarregouMais();
}

/// Recarrega a página 1 com o filtro atual (ex.: depois de editar uma referência).
class ReferenciasListaRecarregou extends ReferenciasListaEvent {
  const ReferenciasListaRecarregou();
}

extension ReferenciasOrdenacaoNoServidor on ReferenciasOrdenacao {
  /// Campo e direção que o `GET /referencias/busca` espera.
  (String campo, String direcao) get paraServidor => switch (this) {
    ReferenciasOrdenacao.nomeAsc => ('nome', 'ASC'),
    ReferenciasOrdenacao.nomeDesc => ('nome', 'DESC'),
    ReferenciasOrdenacao.criadoEmAsc => ('criadoEm', 'ASC'),
    ReferenciasOrdenacao.criadoEmDesc => ('criadoEm', 'DESC'),
    ReferenciasOrdenacao.atualizadoEmAsc => ('atualizadoEm', 'ASC'),
    ReferenciasOrdenacao.atualizadoEmDesc => ('atualizadoEm', 'DESC'),
  };
}
