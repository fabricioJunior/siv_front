import 'package:core/tema.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/produtos_da_referencia_bloc/produtos_da_referencia_bloc.dart'
    show chaveComboGrade;

// Mesmo visual da grade da tela de Referência (referencia_produtos_tab.dart): colunas
// COR / ESTAMPA / tamanhos, uma linha por cor × estampa.
const _kLarguraCor = 170.0;
const _kLarguraEstampa = 130.0;
const _kLarguraTamanho = 84.0;
const _kLarguraCampo = 64.0;

// ponytail: mesma paleta da tela de Referência (lá é privada). Extrair pra um lugar comum
// quando alguém precisar de uma terceira cópia.
const _kPaletaCores = [
  Color(0xFF8E735B),
  Color(0xFF5980A6),
  Color(0xFF6B8F71),
  Color(0xFFB2555A),
  Color(0xFF9B7EDE),
  Color(0xFFC9A227),
  Color(0xFF4F6D7A),
  Color(0xFFD08159),
];

class GradeQuantidadeEtiquetas extends StatefulWidget {
  final List<Produto> produtos;
  final List<Tamanho> tamanhos;
  final Map<String, Produto> mapaProduto;
  final Map<int, int> quantidades;
  final TextEditingController Function(int produtoId, int valorAtual) controllerDe;
  final void Function(int produtoId, int quantidade) aoAlterar;

  const GradeQuantidadeEtiquetas({
    super.key,
    required this.produtos,
    required this.tamanhos,
    required this.mapaProduto,
    required this.quantidades,
    required this.controllerDe,
    required this.aoAlterar,
  });

  @override
  State<GradeQuantidadeEtiquetas> createState() =>
      _GradeQuantidadeEtiquetasState();
}

class _GradeQuantidadeEtiquetasState extends State<GradeQuantidadeEtiquetas> {
  final _horizontalController = ScrollController();

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  // Uma linha por cor × estampa (mesma cor com estampas diferentes são linhas distintas).
  List<Produto> get _linhas =>
      {
        for (final p in widget.produtos)
          if (p.cor != null) '${p.cor!.id}|${p.estampaId ?? ''}': p,
      }.values.toList()..sort((a, b) {
        final porCor = a.cor!.nome.toLowerCase().compareTo(
          b.cor!.nome.toLowerCase(),
        );
        return porCor != 0
            ? porCor
            : (a.estampa?.nome ?? '').toLowerCase().compareTo(
                (b.estampa?.nome ?? '').toLowerCase(),
              );
      });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final rotulo = textos.rotulo.copyWith(color: cores.textoApoio);
    final linhas = _linhas;
    final larguraConteudo =
        _kLarguraCor +
        _kLarguraEstampa +
        _kLarguraTamanho * widget.tamanhos.length +
        32; // padding horizontal de cabeçalho/linhas

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final largura = larguraConteudo < constraints.maxWidth
                ? constraints.maxWidth
                : larguraConteudo;

            return Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: ScrollConfiguration(
                behavior: const MaterialScrollBehavior().copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  controller: _horizontalController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: largura,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: _kLarguraCor,
                                child: Text('COR', style: rotulo),
                              ),
                              SizedBox(
                                width: _kLarguraEstampa,
                                child: Text('ESTAMPA', style: rotulo),
                              ),
                              ...widget.tamanhos.map(
                                (t) => SizedBox(
                                  width: _kLarguraTamanho,
                                  child: Text(
                                    t.nome,
                                    textAlign: TextAlign.center,
                                    style: rotulo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 1, color: cores.hairline),
                        for (final linha in linhas) _buildLinha(linha, cores, textos),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            'Cada linha = cor × estampa · cada coluna = tamanho · '
            '— = combinação não cadastrada',
            style: textos.apoio.copyWith(color: cores.textoApoio),
          ),
        ),
      ],
    );
  }

  Widget _buildLinha(Produto linha, SivColors cores, SivTextStyles textos) {
    final cor = linha.cor!;
    final ehLiso = linha.estampa == null;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _kLarguraCor,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _kPaletaCores[(cor.id ?? 0) % _kPaletaCores.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        cor.nome,
                        overflow: TextOverflow.ellipsis,
                        style: textos.corpo.copyWith(color: cores.acoEscuro),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: _kLarguraEstampa,
                child: Text(
                  ehLiso ? 'Liso' : linha.estampa!.nome,
                  overflow: TextOverflow.ellipsis,
                  style: textos.corpo.copyWith(
                    color: ehLiso ? cores.textoDesabilitado : cores.acoEscuro,
                  ),
                ),
              ),
              ...widget.tamanhos.map(
                (tamanho) => SizedBox(
                  width: _kLarguraTamanho,
                  child: Center(child: _buildCelula(linha, tamanho, cores)),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: cores.hairline),
      ],
    );
  }

  Widget _buildCelula(Produto linha, Tamanho tamanho, SivColors cores) {
    // Mesma origem de ids do bloc (cor.id / tamanho.id dos objetos), senão a chave não bate.
    final corId = linha.cor?.id;
    final produto = corId == null || tamanho.id == null
        ? null
        : widget.mapaProduto[chaveComboGrade(corId, tamanho.id!, linha.estampaId)];

    if (produto?.id == null) {
      return Text('—', style: TextStyle(color: cores.textoDesabilitado));
    }

    final produtoId = produto!.id!;
    final quantidade = widget.quantidades[produtoId] ?? 0;
    final borda = BorderRadius.circular(SivDimensoes.raio);

    return SizedBox(
      width: _kLarguraCampo,
      child: TextField(
        controller: widget.controllerDe(produtoId, quantidade),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.5, color: cores.acoEscuro),
        decoration: InputDecoration(
          hintText: '0',
          isDense: true,
          // Destaca as combinações que já têm quantidade (mesmo chip da célula de estoque da Referência).
          filled: quantidade > 0,
          fillColor: cores.selecaoFundo,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(
            borderRadius: borda,
            borderSide: BorderSide(
              color: quantidade > 0
                  ? cores.acoProfundo.withValues(alpha: 0.35)
                  : cores.hairline,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borda,
            borderSide: BorderSide(
              color: quantidade > 0
                  ? cores.acoProfundo.withValues(alpha: 0.35)
                  : cores.hairline,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borda,
            borderSide: BorderSide(color: cores.acoProfundo),
          ),
        ),
        onChanged: (valor) =>
            widget.aoAlterar(produtoId, int.tryParse(valor.trim()) ?? 0),
      ),
    );
  }
}
