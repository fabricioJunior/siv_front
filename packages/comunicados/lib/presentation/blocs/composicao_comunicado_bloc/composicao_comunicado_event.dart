part of 'composicao_comunicado_bloc.dart';

abstract class ComposicaoComunicadoEvent {}

class ComposicaoAssuntoAlterado extends ComposicaoComunicadoEvent {
  final String assunto;
  ComposicaoAssuntoAlterado(this.assunto);
}

class ComposicaoCorpoAlterado extends ComposicaoComunicadoEvent {
  final String corpoHtml;
  ComposicaoCorpoAlterado(this.corpoHtml);
}

class ComposicaoModoHtmlAvancadoAlterado extends ComposicaoComunicadoEvent {
  final bool modoHtmlAvancado;
  ComposicaoModoHtmlAvancadoAlterado(this.modoHtmlAvancado);
}

class ComposicaoFiltroAlterado extends ComposicaoComunicadoEvent {
  final FiltroDestinatarioComunicado filtro;
  ComposicaoFiltroAlterado(this.filtro);
}

class ComposicaoContarDestinatarios extends ComposicaoComunicadoEvent {}

class ComposicaoImagemSolicitada extends ComposicaoComunicadoEvent {
  final String filePath;
  ComposicaoImagemSolicitada(this.filePath);
}

class ComposicaoImagemConsumida extends ComposicaoComunicadoEvent {}

class ComposicaoEnviar extends ComposicaoComunicadoEvent {
  /// Corpo final a ser enviado -- calculado na tela no momento do envio
  /// (Quill Delta -> HTML, ou texto colado no modo avançado) para não
  /// depender de ordem de processamento entre eventos assíncronos.
  final String corpoHtml;
  ComposicaoEnviar(this.corpoHtml);
}
