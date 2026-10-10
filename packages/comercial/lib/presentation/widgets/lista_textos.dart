import 'package:comercial/domain/models/lista_personalizada.dart';
import 'package:comercial/domain/models/lista_personalizada_resumo.dart';

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

String situacaoTexto(ListaPersonalizadaSituacao s) => switch (s) {
      ListaPersonalizadaSituacao.ativa => 'Ativa',
      ListaPersonalizadaSituacao.agendada => 'Agendada',
      ListaPersonalizadaSituacao.cancelada => 'Cancelada',
      ListaPersonalizadaSituacao.expirada => 'Expirada',
    };

String diaMes(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
