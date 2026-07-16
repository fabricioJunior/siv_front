part of 'etiquetas_bloc.dart';

abstract class EtiquetasState extends Equatable {
  final List<Etiqueta> etiquetas;

  const EtiquetasState({this.etiquetas = const []});

  @override
  List<Object?> get props => [etiquetas];
}

class EtiquetasInitial extends EtiquetasState {
  const EtiquetasInitial();
}

class EtiquetasCarregarEmProgresso extends EtiquetasState {
  const EtiquetasCarregarEmProgresso({super.etiquetas});
}

class EtiquetasCarregarSucesso extends EtiquetasState {
  const EtiquetasCarregarSucesso({required super.etiquetas});
}

class EtiquetasCarregarFalha extends EtiquetasState {
  const EtiquetasCarregarFalha({super.etiquetas});
}

class EtiquetasCriarEmProgresso extends EtiquetasState {
  const EtiquetasCriarEmProgresso({required super.etiquetas});
}

class EtiquetasCriarSucesso extends EtiquetasState {
  const EtiquetasCriarSucesso({required super.etiquetas});
}

class EtiquetasCriarFalha extends EtiquetasState {
  const EtiquetasCriarFalha({required super.etiquetas});
}

class EtiquetasEditarEmProgresso extends EtiquetasState {
  const EtiquetasEditarEmProgresso({required super.etiquetas});
}

class EtiquetasEditarSucesso extends EtiquetasState {
  const EtiquetasEditarSucesso({required super.etiquetas});
}

class EtiquetasEditarFalha extends EtiquetasState {
  const EtiquetasEditarFalha({required super.etiquetas});
}

class EtiquetasExcluirEmProgresso extends EtiquetasState {
  const EtiquetasExcluirEmProgresso({required super.etiquetas});
}

class EtiquetasExcluirSucesso extends EtiquetasState {
  const EtiquetasExcluirSucesso({required super.etiquetas});
}

class EtiquetasExcluirFalha extends EtiquetasState {
  const EtiquetasExcluirFalha({required super.etiquetas});
}
