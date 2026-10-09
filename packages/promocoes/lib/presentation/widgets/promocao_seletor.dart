import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:promocoes/models.dart';
import 'package:promocoes/use_cases.dart';

class PromocoesVigentesCubit extends Cubit<List<Promocao>> {
  final RecuperarPromocoes _recuperar;

  PromocoesVigentesCubit(this._recuperar) : super(const []);

  Future<void> carregar() async {
    try {
      emit(
        (await _recuperar.call(ativa: true, vigente: true))
            .where((p) => p.id != null)
            .toList(),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }
}

/// Seleção múltipla de promoções vigentes.
// ignore: must_be_immutable
class PromocaoSeletor extends StatefulWidget implements ISeletor {
  final List<int> idsSelecionadosIniciais;
  final String titulo;

  @override
  final Function(List<SelectData>)? onChanged;

  const PromocaoSeletor({
    super.key,
    this.idsSelecionadosIniciais = const [],
    this.onChanged,
    this.titulo = 'Promoções',
  });

  @override
  State<PromocaoSeletor> createState() => _PromocaoSeletorState();

  @override
  List<SelectData> get itemsSelecionadosInicial => const [];
}

class _PromocaoSeletorState extends State<PromocaoSeletor> {
  late final PromocoesVigentesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = PromocoesVigentesCubit(sl<RecuperarPromocoes>())..carregar();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PromocoesVigentesCubit, List<Promocao>>(
      bloc: _cubit,
      builder: (context, promocoes) {
        if (promocoes.isEmpty) {
          return Text(
            'Nenhuma promoção vigente.',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return SeletorGenerico<Promocao>(
          key: ValueKey(promocoes.length),
          itens: promocoes,
          itemLabel: (p) => p.nome,
          itemKey: (p) => p.id,
          modo: SeletorGenericoModo.multipla,
          selecionadosIniciais: promocoes
              .where((p) => widget.idsSelecionadosIniciais.contains(p.id))
              .toList(),
          onChanged: (sel) => widget.onChanged?.call(
            sel
                .map((p) => SelectData(id: p.id!, nome: p.nome, data: const {}))
                .toList(),
          ),
          titulo: widget.titulo,
          hintText: 'Digite para buscar uma promoção',
          maxSugestoes: 5,
          chipAvatarBuilder: (_, __) =>
              const Icon(Icons.local_offer_outlined, size: 16),
          confirmarEmSeparadores: const [',', ';'],
          toSelectData: (p) => SelectData(id: p.id!, nome: p.nome, data: const {}),
        );
      },
    );
  }
}
