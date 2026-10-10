import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';
import 'package:core/presentation.dart';

String nomeDaLista(ListaPersonalizadaResumo l) =>
    l.titulo?.isNotEmpty == true ? l.titulo! : l.hash;

String _produtos(int n) => n == 1 ? '1 produto' : '$n produtos';

/// "Por regras" / "Avulsa · N produtos". Em modo regras a contagem pode vir 0
/// do backend (não calculada): então só o modo.
String modoEContagem(ListaPersonalizadaResumo l) {
  if (l.modo == ListaModo.filtro) {
    return l.quantidadeItens > 0
        ? 'Por regras · ${_produtos(l.quantidadeItens)}'
        : 'Por regras';
  }
  return 'Avulsa · ${_produtos(l.quantidadeItens)}';
}

/// Partes da 2ª linha do card (1a): modo, contagem em destaque e período.
/// Ex.: ("Por regras", "142 produtos agora", null) ou
/// ("Avulsa", "24 produtos", "até 30/09").
({String modo, String? contagem, String? periodo}) linhaDoCard(
    ListaPersonalizadaResumo l) {
  final porRegras = l.modo == ListaModo.filtro;
  final modo = l.tipo == ListaTipo.provador
      ? 'Provador'
      : porRegras
          ? 'Por regras'
          : 'Avulsa';
  final contagem = l.quantidadeItens > 0
      ? '${_produtos(l.quantidadeItens)}${porRegras ? ' agora' : ''}'
      : null;
  final fim = l.dataExpiracao;
  final periodo = fim == null
      ? null
      : l.situacao == ListaPersonalizadaSituacao.expirada
          ? 'terminou ${diaMes(fim)}'
          : l.tipo == ListaTipo.provador
              ? 'expira ${diaMes(fim)}'
              : 'até ${diaMes(fim)}';
  return (modo: modo, contagem: contagem, periodo: periodo);
}

String situacaoTexto(ListaPersonalizadaSituacao s) => switch (s) {
      ListaPersonalizadaSituacao.ativa => 'Ativa',
      ListaPersonalizadaSituacao.agendada => 'Agendada',
      ListaPersonalizadaSituacao.cancelada => 'Cancelada',
      ListaPersonalizadaSituacao.expirada => 'Expirada',
    };

SivEtiquetaSituacao etiquetaDaSituacao(ListaPersonalizadaSituacao s) =>
    switch (s) {
      ListaPersonalizadaSituacao.ativa => SivEtiquetaSituacao.emAndamento,
      ListaPersonalizadaSituacao.agendada => SivEtiquetaSituacao.conferido,
      ListaPersonalizadaSituacao.cancelada => SivEtiquetaSituacao.cancelado,
      ListaPersonalizadaSituacao.expirada => SivEtiquetaSituacao.cancelado,
    };

String diaMes(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
