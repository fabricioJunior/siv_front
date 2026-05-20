part of 'devolucao_bloc.dart';

class DevolucaoState extends Equatable {
  final bool carregandoRomaneios;
  final bool carregandoItensDoOriginal;
  final bool leituraIniciada;
  final bool processando;
  final List<Romaneio> romaneiosDeVenda;
  final Romaneio? romaneioOriginal;
  final Map<int, double> itensDoRomaneioOriginalPorProduto;
  final String? erro;
  final int? romaneioDevolucaoId;
  final bool fluxoParcial;

  const DevolucaoState({
    this.carregandoRomaneios = false,
    this.carregandoItensDoOriginal = false,
    this.leituraIniciada = false,
    this.processando = false,
    this.romaneiosDeVenda = const [],
    this.romaneioOriginal,
    this.itensDoRomaneioOriginalPorProduto = const {},
    this.erro,
    this.romaneioDevolucaoId,
    this.fluxoParcial = false,
  });

  bool get podeIniciarLeitura =>
      romaneioOriginal != null && itensDoRomaneioOriginalPorProduto.isNotEmpty;

  DevolucaoState copyWith({
    bool? carregandoRomaneios,
    bool? carregandoItensDoOriginal,
    bool? leituraIniciada,
    bool? processando,
    List<Romaneio>? romaneiosDeVenda,
    Object? romaneioOriginal = _sentinela,
    Map<int, double>? itensDoRomaneioOriginalPorProduto,
    Object? erro = _sentinela,
    Object? romaneioDevolucaoId = _sentinela,
    bool? fluxoParcial,
  }) {
    return DevolucaoState(
      carregandoRomaneios: carregandoRomaneios ?? this.carregandoRomaneios,
      carregandoItensDoOriginal:
          carregandoItensDoOriginal ?? this.carregandoItensDoOriginal,
      leituraIniciada: leituraIniciada ?? this.leituraIniciada,
      processando: processando ?? this.processando,
      romaneiosDeVenda: romaneiosDeVenda ?? this.romaneiosDeVenda,
      romaneioOriginal: identical(romaneioOriginal, _sentinela)
          ? this.romaneioOriginal
          : romaneioOriginal as Romaneio?,
      itensDoRomaneioOriginalPorProduto: itensDoRomaneioOriginalPorProduto ??
          this.itensDoRomaneioOriginalPorProduto,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      romaneioDevolucaoId: identical(romaneioDevolucaoId, _sentinela)
          ? this.romaneioDevolucaoId
          : romaneioDevolucaoId as int?,
      fluxoParcial: fluxoParcial ?? this.fluxoParcial,
    );
  }

  @override
  List<Object?> get props => [
        carregandoRomaneios,
        carregandoItensDoOriginal,
        leituraIniciada,
        processando,
        romaneiosDeVenda,
        romaneioOriginal,
        itensDoRomaneioOriginalPorProduto,
        erro,
        romaneioDevolucaoId,
        fluxoParcial,
      ];
}

const Object _sentinela = Object();
