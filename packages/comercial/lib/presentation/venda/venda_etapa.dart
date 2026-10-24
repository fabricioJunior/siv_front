import 'package:comercial/presentation/blocs/romaneio_criacao_bloc/romaneio_criacao_bloc.dart';
import 'package:comercial/presentation/blocs/venda_bloc/venda_bloc.dart';
import 'package:core/presentation.dart';
import 'package:flutter/material.dart';

enum VendaEtapa {
  configuracao,
  itens,
  pagamento,
  processando,
  concluida,
  pendencia,
}

/// Etapa exibida: a criação do romaneio (quando existe) manda; sem ela vale o
/// passo do [VendaBloc]. Falha total (sem romaneio) volta ao pagamento.
VendaEtapa etapaDaVenda(VendaState venda, RomaneioCriacaoState? criacao) {
  if (!venda.leituraIniciada) return VendaEtapa.configuracao;
  switch (criacao?.step) {
    case RomaneioCriacaoStep.inicial:
    case RomaneioCriacaoStep.processando:
    case RomaneioCriacaoStep.finalizandoVenda:
    case RomaneioCriacaoStep.carregandoDocumentoFiscal:
      return VendaEtapa.processando;
    case RomaneioCriacaoStep.sucesso:
      return VendaEtapa.concluida;
    case RomaneioCriacaoStep.falha:
      if (criacao!.listaCompartilhada?.idLista != null) {
        return VendaEtapa.pendencia;
      }
    case null:
      break;
  }
  return venda.step == VendaStep.pagamento
      ? VendaEtapa.pagamento
      : VendaEtapa.itens;
}

/// Itens → Pagamento → Concluída.
class VendaIndicadorEtapas extends StatelessWidget {
  final VendaEtapa etapa;

  const VendaIndicadorEtapas({super.key, required this.etapa});

  @override
  Widget build(BuildContext context) {
    final posicao = switch (etapa) {
      VendaEtapa.configuracao || VendaEtapa.itens => 0,
      VendaEtapa.pagamento || VendaEtapa.processando => 1,
      VendaEtapa.concluida || VendaEtapa.pendencia => 2,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: SivTrilhaDeProgresso(
        passos: [
          ('Itens', posicao >= 0),
          ('Pagamento', posicao >= 1),
          (etapa == VendaEtapa.pendencia ? 'Pendência' : 'Concluída',
              posicao >= 2),
        ],
      ),
    );
  }
}
