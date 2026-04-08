part of 'sync_data_bloc.dart';

enum SyncModulo { codigos, estoque, tabelasDePreco, precosDaReferencia }

enum SyncDataOrigem { home, entradaDeProdutos, manual }

enum SyncModuloStatus { aguardando, sincronizando, concluido, falha }

class SyncModuloState extends Equatable {
  final SyncModulo modulo;
  final SyncModuloStatus status;
  final int paginaAtual;
  final int totalPaginas;
  final int paginasSincronizadas;
  final int totalItens;
  final int itensSincronizados;
  final DateTime? atualizadoEm;
  final String? erro;

  const SyncModuloState({
    required this.modulo,
    this.status = SyncModuloStatus.aguardando,
    this.paginaAtual = 0,
    this.totalPaginas = 0,
    this.paginasSincronizadas = 0,
    this.totalItens = 0,
    this.itensSincronizados = 0,
    this.atualizadoEm,
    this.erro,
  });

  SyncModuloState copyWith({
    SyncModuloStatus? status,
    int? paginaAtual,
    int? totalPaginas,
    int? paginasSincronizadas,
    int? totalItens,
    int? itensSincronizados,
    DateTime? atualizadoEm,
    String? erro,
  }) {
    return SyncModuloState(
      modulo: modulo,
      status: status ?? this.status,
      paginaAtual: paginaAtual ?? this.paginaAtual,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      paginasSincronizadas: paginasSincronizadas ?? this.paginasSincronizadas,
      totalItens: totalItens ?? this.totalItens,
      itensSincronizados: itensSincronizados ?? this.itensSincronizados,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      erro: erro,
    );
  }

  String get nomeModulo {
    switch (modulo) {
      case SyncModulo.codigos:
        return 'Codigos';
      case SyncModulo.estoque:
        return 'Estoque';
      case SyncModulo.tabelasDePreco:
        return 'Tabelas de preço';
      case SyncModulo.precosDaReferencia:
        return 'Preços da referência';
    }
  }

  double? get progresso {
    if (status == SyncModuloStatus.concluido) {
      return 1;
    }
    if (totalPaginas <= 0) {
      return null;
    }

    final paginaVisual = paginaAtual + 1;
    final percentual = paginaVisual / totalPaginas;
    return percentual.clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        modulo,
        status,
        paginaAtual,
        totalPaginas,
        paginasSincronizadas,
        totalItens,
        itensSincronizados,
        atualizadoEm,
        erro,
      ];
}

class SyncDataState extends Equatable {
  final Map<SyncModulo, SyncModuloState> modulos;
  final bool homeJaSincronizada;
  final DateTime? iniciadoEm;
  final DateTime? finalizadoEm;
  final SyncDataOrigem? origemUltimaSincronizacao;

  const SyncDataState({
    this.modulos = const {
      SyncModulo.codigos: SyncModuloState(modulo: SyncModulo.codigos),
      SyncModulo.estoque: SyncModuloState(modulo: SyncModulo.estoque),
      SyncModulo.tabelasDePreco: SyncModuloState(
        modulo: SyncModulo.tabelasDePreco,
      ),
      SyncModulo.precosDaReferencia: SyncModuloState(
        modulo: SyncModulo.precosDaReferencia,
      ),
    },
    this.homeJaSincronizada = false,
    this.iniciadoEm,
    this.finalizadoEm,
    this.origemUltimaSincronizacao,
  });

  SyncDataState copyWith({
    Map<SyncModulo, SyncModuloState>? modulos,
    bool? homeJaSincronizada,
    DateTime? iniciadoEm,
    DateTime? finalizadoEm,
    SyncDataOrigem? origemUltimaSincronizacao,
  }) {
    return SyncDataState(
      modulos: modulos ?? this.modulos,
      homeJaSincronizada: homeJaSincronizada ?? this.homeJaSincronizada,
      iniciadoEm: iniciadoEm ?? this.iniciadoEm,
      finalizadoEm: finalizadoEm,
      origemUltimaSincronizacao:
          origemUltimaSincronizacao ?? this.origemUltimaSincronizacao,
    );
  }

  bool get sincronizando {
    return modulos.values
        .any((modulo) => modulo.status == SyncModuloStatus.sincronizando);
  }

  @override
  List<Object?> get props => [
        modulos,
        homeJaSincronizada,
        iniciadoEm,
        finalizadoEm,
        origemUltimaSincronizacao,
      ];
}
