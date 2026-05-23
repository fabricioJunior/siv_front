part of 'devolucao_bloc.dart';

class DevolucaoState extends Equatable {
  final bool carregandoRomaneios;
  final bool carregandoBuscaRomaneios;
  final bool carregandoItensDoOriginal;
  final bool leituraIniciada;
  final bool processando;
  final List<Romaneio> romaneiosDeVenda;
  final List<Romaneio> romaneiosBuscaDeVenda;
  final String termoBuscaRomaneios;
  final Romaneio? romaneioOriginal;
  final Map<int, double> itensDoRomaneioOriginalPorProduto;
  final String? erro;
  final String? erroBuscaRomaneios;
  final int? romaneioDevolucaoId;
  final bool fluxoParcial;

  const DevolucaoState({
    this.carregandoRomaneios = false,
    this.carregandoBuscaRomaneios = false,
    this.carregandoItensDoOriginal = false,
    this.leituraIniciada = false,
    this.processando = false,
    this.romaneiosDeVenda = const [],
    this.romaneiosBuscaDeVenda = const [],
    this.termoBuscaRomaneios = '',
    this.romaneioOriginal,
    this.itensDoRomaneioOriginalPorProduto = const {},
    this.erro,
    this.erroBuscaRomaneios,
    this.romaneioDevolucaoId,
    this.fluxoParcial = false,
  });

  bool get podeIniciarLeitura =>
      romaneioOriginal != null && itensDoRomaneioOriginalPorProduto.isNotEmpty;

  DevolucaoState copyWith({
    bool? carregandoRomaneios,
    bool? carregandoBuscaRomaneios,
    bool? carregandoItensDoOriginal,
    bool? leituraIniciada,
    bool? processando,
    List<Romaneio>? romaneiosDeVenda,
    List<Romaneio>? romaneiosBuscaDeVenda,
    String? termoBuscaRomaneios,
    Object? romaneioOriginal = _sentinela,
    Map<int, double>? itensDoRomaneioOriginalPorProduto,
    Object? erro = _sentinela,
    Object? erroBuscaRomaneios = _sentinela,
    Object? romaneioDevolucaoId = _sentinela,
    bool? fluxoParcial,
  }) {
    return DevolucaoState(
      carregandoRomaneios: carregandoRomaneios ?? this.carregandoRomaneios,
      carregandoBuscaRomaneios:
        carregandoBuscaRomaneios ?? this.carregandoBuscaRomaneios,
      carregandoItensDoOriginal:
          carregandoItensDoOriginal ?? this.carregandoItensDoOriginal,
      leituraIniciada: leituraIniciada ?? this.leituraIniciada,
      processando: processando ?? this.processando,
      romaneiosDeVenda: romaneiosDeVenda ?? this.romaneiosDeVenda,
      romaneiosBuscaDeVenda:
        romaneiosBuscaDeVenda ?? this.romaneiosBuscaDeVenda,
      termoBuscaRomaneios: termoBuscaRomaneios ?? this.termoBuscaRomaneios,
      romaneioOriginal: identical(romaneioOriginal, _sentinela)
          ? this.romaneioOriginal
          : romaneioOriginal as Romaneio?,
      itensDoRomaneioOriginalPorProduto: itensDoRomaneioOriginalPorProduto ??
          this.itensDoRomaneioOriginalPorProduto,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
      erroBuscaRomaneios: identical(erroBuscaRomaneios, _sentinela)
        ? this.erroBuscaRomaneios
        : erroBuscaRomaneios as String?,
      romaneioDevolucaoId: identical(romaneioDevolucaoId, _sentinela)
          ? this.romaneioDevolucaoId
          : romaneioDevolucaoId as int?,
      fluxoParcial: fluxoParcial ?? this.fluxoParcial,
    );
  }

  @override
  List<Object?> get props => [
        carregandoRomaneios,
      carregandoBuscaRomaneios,
        carregandoItensDoOriginal,
        leituraIniciada,
        processando,
        romaneiosDeVenda,
      romaneiosBuscaDeVenda,
      termoBuscaRomaneios,
        romaneioOriginal,
        itensDoRomaneioOriginalPorProduto,
        erro,
      erroBuscaRomaneios,
        romaneioDevolucaoId,
        fluxoParcial,
      ];
}

const Object _sentinela = Object();
