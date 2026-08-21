part of 'comunicados_bloc.dart';

class ComunicadosState extends Equatable {
  final List<Comunicado> items;
  final int total;
  final int pagina;
  final String? status;
  final String? erro;
  final ComunicadosStep step;

  const ComunicadosState({
    required this.items,
    required this.total,
    required this.pagina,
    this.status,
    this.erro,
    required this.step,
  });

  const ComunicadosState.initial()
    : items = const [],
      total = 0,
      pagina = 1,
      status = null,
      erro = null,
      step = ComunicadosStep.inicial;

  ComunicadosState copyWith({
    List<Comunicado>? items,
    int? total,
    int? pagina,
    String? status,
    bool limparStatus = false,
    String? erro,
    ComunicadosStep? step,
  }) {
    return ComunicadosState(
      items: items ?? this.items,
      total: total ?? this.total,
      pagina: pagina ?? this.pagina,
      status: limparStatus ? null : (status ?? this.status),
      erro: erro,
      step: step ?? this.step,
    );
  }

  @override
  List<Object?> get props => [items, total, pagina, status, erro, step];
}

enum ComunicadosStep { inicial, carregando, sucesso, falha }
