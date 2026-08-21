part of 'detalhe_comunicado_bloc.dart';

class DetalheComunicadoState extends Equatable {
  final Comunicado? comunicado;
  final List<ComunicadoDestinatario> destinatarios;
  final int totalDestinatarios;
  final int paginaDestinatarios;
  final String? statusDestinatarios;
  final Set<int> reenviando;
  final String? erro;
  final DetalheComunicadoStep step;

  const DetalheComunicadoState({
    this.comunicado,
    required this.destinatarios,
    required this.totalDestinatarios,
    required this.paginaDestinatarios,
    this.statusDestinatarios,
    required this.reenviando,
    this.erro,
    required this.step,
  });

  const DetalheComunicadoState.initial()
    : comunicado = null,
      destinatarios = const [],
      totalDestinatarios = 0,
      paginaDestinatarios = 1,
      statusDestinatarios = null,
      reenviando = const {},
      erro = null,
      step = DetalheComunicadoStep.inicial;

  DetalheComunicadoState copyWith({
    Comunicado? comunicado,
    List<ComunicadoDestinatario>? destinatarios,
    int? totalDestinatarios,
    int? paginaDestinatarios,
    String? statusDestinatarios,
    bool limparStatusDestinatarios = false,
    Set<int>? reenviando,
    String? erro,
    DetalheComunicadoStep? step,
  }) {
    return DetalheComunicadoState(
      comunicado: comunicado ?? this.comunicado,
      destinatarios: destinatarios ?? this.destinatarios,
      totalDestinatarios: totalDestinatarios ?? this.totalDestinatarios,
      paginaDestinatarios: paginaDestinatarios ?? this.paginaDestinatarios,
      statusDestinatarios: limparStatusDestinatarios
          ? null
          : (statusDestinatarios ?? this.statusDestinatarios),
      reenviando: reenviando ?? this.reenviando,
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [
    comunicado,
    destinatarios,
    totalDestinatarios,
    paginaDestinatarios,
    statusDestinatarios,
    reenviando,
    erro,
    step,
  ];
}

enum DetalheComunicadoStep { inicial, carregando, sucesso, falha }
