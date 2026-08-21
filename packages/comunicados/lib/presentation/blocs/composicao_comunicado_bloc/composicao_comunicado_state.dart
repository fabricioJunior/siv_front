part of 'composicao_comunicado_bloc.dart';

class ComposicaoComunicadoState extends Equatable {
  final String assunto;
  final String corpoHtml;
  final bool modoHtmlAvancado;
  final FiltroDestinatarioComunicado filtro;
  final int totalDestinatarios;
  final bool contandoDestinatarios;
  final bool enviandoImagem;
  final String? imagemUrl;
  final bool enviando;
  final Comunicado? comunicadoCriado;
  final String? erro;

  const ComposicaoComunicadoState({
    required this.assunto,
    required this.corpoHtml,
    required this.modoHtmlAvancado,
    required this.filtro,
    required this.totalDestinatarios,
    required this.contandoDestinatarios,
    required this.enviandoImagem,
    this.imagemUrl,
    required this.enviando,
    this.comunicadoCriado,
    this.erro,
  });

  factory ComposicaoComunicadoState.initial({
    required FiltroDestinatarioComunicado filtro,
  }) {
    return ComposicaoComunicadoState(
      assunto: '',
      corpoHtml: '',
      modoHtmlAvancado: false,
      filtro: filtro,
      totalDestinatarios: 0,
      contandoDestinatarios: false,
      enviandoImagem: false,
      enviando: false,
    );
  }

  bool get podeEnviar =>
      assunto.trim().isNotEmpty &&
      corpoHtml.trim().isNotEmpty &&
      totalDestinatarios > 0 &&
      !enviando;

  ComposicaoComunicadoState copyWith({
    String? assunto,
    String? corpoHtml,
    bool? modoHtmlAvancado,
    FiltroDestinatarioComunicado? filtro,
    int? totalDestinatarios,
    bool? contandoDestinatarios,
    bool? enviandoImagem,
    String? imagemUrl,
    bool limparImagemUrl = false,
    bool? enviando,
    Comunicado? comunicadoCriado,
    String? erro,
  }) {
    return ComposicaoComunicadoState(
      assunto: assunto ?? this.assunto,
      corpoHtml: corpoHtml ?? this.corpoHtml,
      modoHtmlAvancado: modoHtmlAvancado ?? this.modoHtmlAvancado,
      filtro: filtro ?? this.filtro,
      totalDestinatarios: totalDestinatarios ?? this.totalDestinatarios,
      contandoDestinatarios:
          contandoDestinatarios ?? this.contandoDestinatarios,
      enviandoImagem: enviandoImagem ?? this.enviandoImagem,
      imagemUrl: limparImagemUrl ? null : (imagemUrl ?? this.imagemUrl),
      enviando: enviando ?? this.enviando,
      comunicadoCriado: comunicadoCriado ?? this.comunicadoCriado,
      erro: erro,
    );
  }

  @override
  List<Object?> get props => [
    assunto,
    corpoHtml,
    modoHtmlAvancado,
    filtro,
    totalDestinatarios,
    contandoDestinatarios,
    enviandoImagem,
    imagemUrl,
    enviando,
    comunicadoCriado,
    erro,
  ];
}
