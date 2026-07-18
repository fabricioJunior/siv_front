import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';
import 'package:core/impressoras/printers/use_cases/obter_impressora_preferida.dart';
import 'package:core/impressoras/printers/use_cases/salvar_impressora_preferida.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/impressoras/zpl/etiqueta_preview_add_field_modal.dart';
import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_zpl_generator/flutter_zpl_generator.dart';

class EtiquetaPreviewPage extends StatefulWidget {
  const EtiquetaPreviewPage({
    super.key,
    this.overrides,
    this.retornarResultado = false,
  });

  final Map<String, String>? overrides;
  final bool retornarResultado;

  @override
  State<EtiquetaPreviewPage> createState() => _EtiquetaPreviewPageState();
}

class _EtiquetaPreviewPageState extends State<EtiquetaPreviewPage> {
  final Debouncer _previewDebouncer = Debouncer(milliseconds: 250);

  bool _imprimindoTeste = false;
  EtiquetaDpi _dpiSelecionado = EtiquetaDpi.d152;

  double _larguraEtiquetaMm = 54;
  double _alturaEtiquetaMm = 30;
  int _quantidadeVias = 1;
  double _gapEntreViasMm = 2;

  late final TextEditingController _larguraController;
  late final TextEditingController _alturaController;
  late final TextEditingController _quantidadeViasController;
  late final TextEditingController _gapController;
  late final TextEditingController _nomeController;

  String _nomeEtiqueta = 'Etiqueta personalizada';

  final List<ElementoEtiquetaPreview> _elementos = [];

  int get _dotsPorMm => _dpiSelecionado.dotsPorMm;

  double get _larguraTotalImpressaoMm {
    if (_quantidadeVias <= 1) {
      return _larguraEtiquetaMm;
    }

    return (_larguraEtiquetaMm * _quantidadeVias) +
        (_gapEntreViasMm * (_quantidadeVias - 1));
  }

  @override
  void initState() {
    super.initState();
    _aplicarOverrides();

    _larguraController = TextEditingController(
      text: _larguraEtiquetaMm.toStringAsFixed(1),
    );
    _alturaController = TextEditingController(
      text: _alturaEtiquetaMm.toStringAsFixed(1),
    );
    _quantidadeViasController = TextEditingController(
      text: _quantidadeVias.toString(),
    );
    _gapController = TextEditingController(
      text: _gapEntreViasMm.toStringAsFixed(1),
    );
    _nomeController = TextEditingController(text: _nomeEtiqueta);
  }

  @override
  void didUpdateWidget(covariant EtiquetaPreviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (mapEquals(oldWidget.overrides, widget.overrides)) {
      return;
    }

    _aplicarOverrides();
    _sincronizarControles();
  }

  @override
  void dispose() {
    _previewDebouncer.cancel();
    _larguraController.dispose();
    _alturaController.dispose();
    _quantidadeViasController.dispose();
    _gapController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  void _aplicarOverrides() {
    final nomeOverride = widget.overrides?['nomeEtiqueta'];
    if (nomeOverride != null && nomeOverride.trim().isNotEmpty) {
      _nomeEtiqueta = nomeOverride.trim();
    }
    _dpiSelecionado = _overrideDpi('dpi', _dpiSelecionado);
    _larguraEtiquetaMm = _overrideDouble('larguraEtiquetaMm', _larguraEtiquetaMm, 20, 300);
    _alturaEtiquetaMm = _overrideDouble('alturaEtiquetaMm', _alturaEtiquetaMm, 20, 300);

    final quantidadeViasOverride =
        int.tryParse((widget.overrides?['quantidadeVias'] ?? '').trim());
    if (quantidadeViasOverride != null && quantidadeViasOverride > 0) {
      _quantidadeVias = quantidadeViasOverride;
    }

    _gapEntreViasMm = _overrideDouble('gap', _gapEntreViasMm, 0, 50);

    _elementos
      ..clear()
      ..addAll(_buildElementosIniciais());
  }

  List<ElementoEtiquetaPreview> _buildElementosIniciais() {
    final elementos = <ElementoEtiquetaPreview>[];

    for (final campo in TipoCampoEtiqueta.values) {
      final conteudo = _valorTexto(campo.nome, '');
      final temPosicao = (widget.overrides?[campo.chaveX] ?? '').trim().isNotEmpty ||
          (widget.overrides?[campo.chaveY] ?? '').trim().isNotEmpty;

      if (conteudo.isEmpty && !temPosicao) {
        continue;
      }

      elementos.add(
        ElementoEtiquetaPreview.fromCampo(
          campo,
          textoExemplo: conteudo.isEmpty ? campo.exemploPadrao : conteudo,
          xMm: _overrideDouble(campo.chaveX, campo.xPadraoMm, 0, _larguraEtiquetaMm),
          yMm: _overrideDouble(campo.chaveY, campo.yPadraoMm, 0, _alturaEtiquetaMm),
          tamanhoFonteMm: _overrideDouble(
            campo.chaveTamanhoFonte,
            campo.tamanhoFontePadraoMm,
            1,
            20,
          ),
          alturaCodigoBarrasMm: _overrideDouble(
            campo.chaveAlturaCodigo,
            campo.alturaCodigoPadraoMm,
            2,
            _alturaEtiquetaMm,
          ),
          limiteCaracteres: _overrideIntOpcional(campo.chaveLimiteCaracteres),
        ),
      );
    }

    // Texto Fixo nao pertence a TipoCampoEtiqueta (nome livre, gerado dinamicamente) -- reconstroi
    // a partir da lista de nomes salva em overrides['textoFixoNomes'], usando as mesmas chaves
    // convencionais ("${nome}Xmm" etc) ja usadas pelos campos fixos acima.
    final nomesTextoFixo = (widget.overrides?['textoFixoNomes'] ?? '')
        .split(',')
        .map((nome) => nome.trim())
        .where((nome) => nome.isNotEmpty);

    for (final nome in nomesTextoFixo) {
      elementos.add(
        ElementoEtiquetaPreview.textoFixo(
          nome: nome,
          texto: _valorTexto(nome, ''),
          xMm: _overrideDouble('${nome}Xmm', 1, 0, _larguraEtiquetaMm),
          yMm: _overrideDouble('${nome}Ymm', 1, 0, _alturaEtiquetaMm),
          tamanhoFonteMm: _overrideDouble('${nome}TamanhoFonteMm', 2, 1, 20),
        ),
      );
    }

    return elementos;
  }

  String _proximoNomeTextoFixo() {
    final regexTextoFixo = RegExp(r'^textoFixo_(\d+)$');
    var maiorIndice = 0;

    for (final elemento in _elementos) {
      final match = regexTextoFixo.firstMatch(elemento.nome);
      if (match == null) {
        continue;
      }
      final indice = int.tryParse(match.group(1) ?? '') ?? 0;
      if (indice > maiorIndice) {
        maiorIndice = indice;
      }
    }

    return 'textoFixo_${maiorIndice + 1}';
  }

  void _sincronizarControles() {
    _larguraController.text = _larguraEtiquetaMm.toStringAsFixed(1);
    _alturaController.text = _alturaEtiquetaMm.toStringAsFixed(1);
    _quantidadeViasController.text = _quantidadeVias.toString();
    _gapController.text = _gapEntreViasMm.toStringAsFixed(1);
    _nomeController.text = _nomeEtiqueta;
  }

  void _debouncedSetState(VoidCallback action) {
    _previewDebouncer.run(() {
      if (!mounted) {
        return;
      }
      setState(action);
    });
  }

  String _valorTexto(String chave, String padrao) {
    final valor = widget.overrides?[chave];
    if (valor == null || valor.trim().isEmpty) {
      return padrao;
    }
    return valor.trim();
  }

  double _overrideDouble(String chave, double atual, double min, double max) {
    final raw = widget.overrides?[chave];
    if (raw == null || raw.trim().isEmpty) {
      return atual.clamp(min, max);
    }

    final parsed = double.tryParse(raw.replaceAll(',', '.').trim());
    if (parsed == null) {
      return atual.clamp(min, max);
    }

    return parsed.clamp(min, max);
  }

  int? _overrideIntOpcional(String chave) {
    final raw = widget.overrides?[chave];
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return int.tryParse(raw.trim());
  }

  EtiquetaDpi _overrideDpi(String chave, EtiquetaDpi atual) {
    final raw = widget.overrides?[chave];
    if (raw == null || raw.trim().isEmpty) {
      return atual;
    }

    final parsed = int.tryParse(raw.trim());
    if (parsed == null) {
      return atual;
    }

    return EtiquetaDpi.values.firstWhere(
      (item) => item.valor == parsed,
      orElse: () => atual,
    );
  }

  @override
  Widget build(BuildContext context) {
    final generatorPreview = _buildGeneratorParaVias(
      _indicesDasVias(),
      usarIdentificadores: false,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-visualizacao de etiquetas')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;

          if (!isDesktop) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreviewPanel(generatorPreview),
                const SizedBox(height: 16),
                _buildEditorPanel(isNested: true),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildPreviewPanel(generatorPreview)),
                const VerticalDivider(width: 24),
                Expanded(flex: 6, child: _buildEditorPanel()),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _imprimindoTeste || _elementos.isEmpty
                    ? null
                    : () async {
                        await _imprimirEtiquetaTeste();
                      },
                icon: _imprimindoTeste
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.science_outlined),
                label: Text(
                  _imprimindoTeste ? 'Imprimindo teste...' : 'Imprimir teste',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _elementos.isEmpty
                    ? null
                    : () async {
                        if (!context.mounted) {
                          return;
                        }

                        if (widget.retornarResultado) {
                          final zplTemplate = await _buildGeneratorParaVias(
                            _indicesDasVias(),
                            usarIdentificadores: true,
                          ).build();

                          Navigator.of(context).pop(
                            await _buildRetornoPreview(zplCompleto: zplTemplate),
                          );
                          return;
                        }

                        await _buildGeneratorParaVias(
                          _indicesDasVias(),
                          usarIdentificadores: false,
                        ).build();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Comando ZPL gerado com sucesso.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                icon: const Icon(Icons.print_outlined),
                label: Text(
                  widget.retornarResultado ? 'Salvar etiqueta' : 'Gerar etiquetas',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> _indicesDasVias() {
    return List<int>.generate(_quantidadeVias, (index) => index);
  }

  ZplGenerator _buildGeneratorParaVias(
    List<int> ordensVias, {
    required bool usarIdentificadores,
  }) {
    final comandos = <ZplCommand>[];

    for (final ordemVia in ordensVias) {
      final deslocamentoViaMm = ordemVia * (_larguraEtiquetaMm + _gapEntreViasMm);

      for (final elemento in _elementos) {
        final x = mmToDots(elemento.xMm + deslocamentoViaMm, _dotsPorMm);
        final y = mmToDots(elemento.yMm, _dotsPorMm);

        if (elemento.tipoElemento == TipoElemento.codigoDeBarras) {
          final conteudoCodigo = usarIdentificadores
              ? '{${elemento.nome}}'
              : _normalizarEan12(elemento.textoExemplo);

          comandos.add(
            ZplBarcode(
              type: ZplBarcodeType.ean13,
              x: x,
              y: y,
              data: conteudoCodigo,
              height: mmToDots(elemento.alturaCodigoBarrasMm, _dotsPorMm),
            ),
          );
          continue;
        }

        // Texto Fixo nao tem dado de produto pra resolver depois -- o texto digitado E o
        // conteudo final, sempre, mesmo quando usarIdentificadores=true (ZPL salvo no backend).
        final conteudoTexto = usarIdentificadores && !elemento.fixo
            ? '{${elemento.nome}}'
            : _truncar(elemento.textoExemplo, elemento.limiteCaracteres);

        comandos.add(
          ZplText(
            x: x,
            y: y,
            text: conteudoTexto,
            fontHeight: mmToDots(elemento.tamanhoFonteMm, _dotsPorMm),
            fontWidth: mmToDots(elemento.tamanhoFonteMm, _dotsPorMm),
          ),
        );
      }
    }

    return ZplGenerator(
      config: ZplConfiguration(
        printWidth: mmToDots(_larguraTotalImpressaoMm, _dotsPorMm),
        labelLength: mmToDots(_alturaEtiquetaMm, _dotsPorMm),
        printDensity: _dpiSelecionado.zplPrintDensity,
      ),
      commands: comandos,
    );
  }

  String _truncar(String valor, int? limite) {
    if (limite == null || limite <= 0 || valor.length <= limite) {
      return valor;
    }
    return valor.substring(0, limite);
  }

  String _normalizarEan12(String input) {
    final apenasDigitos = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (apenasDigitos.isEmpty) {
      return '000000000000';
    }

    if (apenasDigitos.length >= 12) {
      return apenasDigitos.substring(0, 12);
    }

    return apenasDigitos.padRight(12, '0');
  }

  Future<Map<String, dynamic>> _buildRetornoPreview({
    required String zplCompleto,
  }) async {
    final vias = <Map<String, dynamic>>[];

    for (final ordem in _indicesDasVias()) {
      final zplVia = await _buildGeneratorParaVias(
        [ordem],
        usarIdentificadores: true,
      ).build();
      vias.add({'ordem': ordem, 'zpl': zplVia});
    }

    return {
      'nome': _nomeEtiqueta.trim().isEmpty ? 'Etiqueta personalizada' : _nomeEtiqueta.trim(),
      'altura': _alturaEtiquetaMm,
      'largura': _larguraEtiquetaMm,
      'dpi': _dpiSelecionado.valor,
      'quantidadeVias': _quantidadeVias,
      'gap': _quantidadeVias > 1 ? _gapEntreViasMm : 0,
      'zpl': zplCompleto,
      'elementos': _elementos
          .map(
            (elemento) => {
              'nome': elemento.nome,
              'tipoElemento': elemento.tipoElemento.valor,
              'x': elemento.xMm,
              'y': elemento.yMm,
              if (elemento.fixo) 'texto': elemento.textoExemplo,
              if (elemento.limiteCaracteres != null)
                'limiteCaracteres': elemento.limiteCaracteres,
              // Faltava persistir isso -- editor sempre reabria com tamanho padrao do campo.
              'tamanhoFonteMm': elemento.tamanhoFonteMm,
              'alturaCodigoBarrasMm': elemento.alturaCodigoBarrasMm,
            },
          )
          .toList(growable: false),
      'vias': vias,
    };
  }

  Future<void> _imprimirEtiquetaTeste() async {
    setState(() {
      _imprimindoTeste = true;
    });

    try {
      final zpl = await _buildGeneratorParaVias(
        _indicesDasVias(),
        usarIdentificadores: false,
      ).build();
      if (!mounted) {
        return;
      }

      final printersService = sl<IPrintersService>();
      final impressoras = printersService
          .getAvailablePrinters()
          .where((impressora) => impressora.isAvailable)
          .toList(growable: false);

      if (impressoras.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nenhuma impressora disponivel para teste.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final impressoraSelecionada = await _selecionarImpressora(impressoras);
      if (!mounted || impressoraSelecionada == null) {
        return;
      }

      final sucesso = await printersService.printZpl(impressoraSelecionada, zpl);
      if (sucesso) {
        sl<SalvarImpressoraPreferida>().call(
          tipo: TipoImpressora.etiqueta,
          nomeImpressora: impressoraSelecionada.name,
        );
      }
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sucesso
                ? 'Etiqueta de teste enviada para ${impressoraSelecionada.name}.'
                : 'Falha ao enviar etiqueta de teste para impressao.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao preparar ou enviar a etiqueta de teste.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _imprimindoTeste = false;
        });
      }
    }
  }

  Future<Impressora?> _selecionarImpressora(List<Impressora> impressoras) async {
    final nomePreferido = await sl<ObterImpressoraPreferida>()
        .call(tipo: TipoImpressora.etiqueta);
    final preferida = nomePreferido == null
        ? null
        : impressoras
            .where((impressora) => impressora.name == nomePreferido)
            .toList();
    var selecionada =
        preferida != null && preferida.isNotEmpty ? preferida.first : impressoras.first;

    if (!mounted) return null;

    return showDialog<Impressora>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Selecionar impressora para teste'),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: impressoras
                        .map(
                          (impressora) => RadioListTile<Impressora>(
                            value: impressora,
                            groupValue: selecionada,
                            onChanged: (value) {
                              if (value == null) {
                                return;
                              }

                              setDialogState(() {
                                selecionada = value;
                              });
                            },
                            title: Text(impressora.name),
                            subtitle: Text(
                              '${impressora.model} - ${impressora.location}',
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(selecionada),
                  child: const Text('Imprimir teste'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static const _opcaoTextoFixo = 'Texto Fixo';

  Future<void> _adicionarCampo() async {
    final disponiveis = TipoCampoEtiqueta.values
        .where(
          (campo) => !_elementos.any((elemento) => elemento.nome == campo.nome),
        )
        .toList(growable: false);

    // Texto Fixo nao entra no filtro de "ja adicionado" -- e um componente repetivel (varios
    // textos fixos na mesma etiqueta), diferente dos campos de TipoCampoEtiqueta (unicos).
    final opcoes = [
      const EtiquetaCampoOpcaoModal(
        nome: _opcaoTextoFixo,
        descricao: 'Texto livre digitado por voce, fixo na etiqueta.',
      ),
      ...disponiveis.map(
        (campo) => EtiquetaCampoOpcaoModal(
          nome: campo.nome,
          descricao: campo.descricao,
        ),
      ),
    ];

    final nomeSelecionado = await showEtiquetaAddFieldModal(
      context,
      opcoes: opcoes,
    );

    if (nomeSelecionado == null) {
      return;
    }

    if (nomeSelecionado == _opcaoTextoFixo) {
      _adicionarTextoFixo();
      return;
    }

    TipoCampoEtiqueta? selecionado;
    for (final campo in disponiveis) {
      if (campo.nome == nomeSelecionado) {
        selecionado = campo;
        break;
      }
    }

    if (selecionado == null) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel adicionar o campo selecionado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selecionadoCampo = selecionado;

    setState(() {
      _elementos.add(
        ElementoEtiquetaPreview.fromCampo(
          selecionadoCampo,
          textoExemplo: _valorTexto(
            selecionadoCampo.nome,
            selecionadoCampo.exemploPadrao,
          ),
        ),
      );
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Campo "${selecionadoCampo.nome}" adicionado.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _adicionarTextoFixo() {
    final nome = _proximoNomeTextoFixo();

    setState(() {
      _elementos.add(
        ElementoEtiquetaPreview.textoFixo(nome: nome, texto: ''),
      );
    });

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Texto fixo adicionado. Digite o texto e ajuste a posicao.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPreviewPanel(ZplGenerator generator) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Previa da etiqueta',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_elementos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Adicione ao menos um campo para visualizar a etiqueta.',
                ),
              )
            else
              SizedBox(
                height: 360,
                child: Center(child: ZplPreview(generator: generator)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorPanel({bool isNested = false}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          shrinkWrap: isNested,
          physics: isNested ? const NeverScrollableScrollPhysics() : null,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da etiqueta',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _nomeEtiqueta = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EtiquetaDpi>(
              value: _dpiSelecionado,
              decoration: const InputDecoration(
                labelText: 'DPI da etiqueta',
                border: OutlineInputBorder(),
              ),
              items: EtiquetaDpi.values
                  .map(
                    (dpi) => DropdownMenuItem<EtiquetaDpi>(
                      value: dpi,
                      child: Text('${dpi.valor} DPI (${dpi.dotsPorMm} dots/mm)'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _dpiSelecionado = value;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tamanho da etiqueta (mm)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _NumberInputField(
              label: 'Largura',
              controller: _larguraController,
              min: 20,
              max: 300,
              onChanged: (value) {
                _debouncedSetState(() {
                  _larguraEtiquetaMm = value;
                  for (final elemento in _elementos) {
                    elemento.xMm = elemento.xMm.clamp(0, _larguraEtiquetaMm);
                  }
                });
              },
            ),
            _NumberInputField(
              label: 'Altura',
              controller: _alturaController,
              min: 20,
              max: 300,
              onChanged: (value) {
                _debouncedSetState(() {
                  _alturaEtiquetaMm = value;
                  for (final elemento in _elementos) {
                    elemento.yMm = elemento.yMm.clamp(0, _alturaEtiquetaMm);
                    elemento.alturaCodigoBarrasMm =
                        elemento.alturaCodigoBarrasMm.clamp(2, _alturaEtiquetaMm);
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            _IntegerInputField(
              label: 'Vias',
              controller: _quantidadeViasController,
              min: 1,
              max: 6,
              onChanged: (value) {
                _debouncedSetState(() {
                  _quantidadeVias = value;
                });
              },
            ),
            if (_quantidadeVias > 1)
              _NumberInputField(
                label: 'Gap entre vias',
                controller: _gapController,
                min: 0,
                max: 50,
                onChanged: (value) {
                  _debouncedSetState(() {
                    _gapEntreViasMm = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Campos da etiqueta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _adicionarCampo,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar campo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_elementos.isEmpty)
              const Text('Nenhum campo adicionado ainda.')
            else
              ..._elementos.map(_buildCardElemento),
          ],
        ),
      ),
    );
  }

  Widget _buildCardElemento(ElementoEtiquetaPreview elemento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    elemento.fixo ? 'Texto fixo' : '${elemento.nome} (${elemento.tipoElemento.valor})',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _elementos.removeWhere((e) => e.nome == elemento.nome);
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Remover campo',
                ),
              ],
            ),
            TextFormField(
              key: ValueKey('valor_${elemento.nome}'),
              initialValue: elemento.textoExemplo,
              decoration: InputDecoration(
                labelText: elemento.fixo ? 'Texto' : 'Valor de exemplo',
                border: const OutlineInputBorder(),
              ),
              onChanged: (valor) {
                _debouncedSetState(() {
                  elemento.textoExemplo = valor;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _DecimalInlineField(
                    label: 'X (mm)',
                    value: elemento.xMm,
                    min: 0,
                    max: _larguraEtiquetaMm,
                    onChanged: (valor) {
                      _debouncedSetState(() {
                        elemento.xMm = valor;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _DecimalInlineField(
                    label: 'Y (mm)',
                    value: elemento.yMm,
                    min: 0,
                    max: _alturaEtiquetaMm,
                    onChanged: (valor) {
                      _debouncedSetState(() {
                        elemento.yMm = valor;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (elemento.tipoElemento == TipoElemento.texto)
              _DecimalInlineField(
                label: 'Tamanho fonte (mm)',
                value: elemento.tamanhoFonteMm,
                min: 1,
                max: 20,
                onChanged: (valor) {
                  _debouncedSetState(() {
                    elemento.tamanhoFonteMm = valor;
                  });
                },
              )
            else
              _DecimalInlineField(
                label: 'Altura codigo de barras (mm)',
                value: elemento.alturaCodigoBarrasMm,
                min: 2,
                max: _alturaEtiquetaMm,
                onChanged: (valor) {
                  _debouncedSetState(() {
                    elemento.alturaCodigoBarrasMm = valor;
                  });
                },
              ),
            if (elemento.suportaLimiteCaracteres) ...[
              const SizedBox(height: 8),
              TextFormField(
                key: ValueKey('limite_${elemento.nome}'),
                initialValue: elemento.limiteCaracteres?.toString() ?? '',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Limite de caracteres (opcional)',
                  helperText:
                      'Se o dado do produto for maior, imprime so os N primeiros caracteres.',
                  border: OutlineInputBorder(),
                ),
                onChanged: (valor) {
                  _debouncedSetState(() {
                    elemento.limiteCaracteres = valor.trim().isEmpty
                        ? null
                        : int.tryParse(valor.trim());
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  int mmToDots(double mm, int dotsPorMm) => (mm * dotsPorMm).round();
}

class _NumberInputField extends StatelessWidget {
  const _NumberInputField({
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  double? _toDouble(String value) {
    final normalized = value.replaceAll(',', '.').trim();
    return double.tryParse(normalized);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          decoration: InputDecoration(
            labelText: '$label (mm)',
            hintText: '${min.toStringAsFixed(0)} a ${max.toStringAsFixed(0)}',
            border: const OutlineInputBorder(),
          ),
          onChanged: (raw) {
            final parsed = _toDouble(raw);
            if (parsed == null) {
              return;
            }
            onChanged(parsed.clamp(min, max));
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _IntegerInputField extends StatelessWidget {
  const _IntegerInputField({
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: label,
            hintText: '$min a $max',
            border: const OutlineInputBorder(),
          ),
          onChanged: (raw) {
            final parsed = int.tryParse(raw.trim());
            if (parsed == null) {
              return;
            }
            onChanged(parsed.clamp(min, max));
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _DecimalInlineField extends StatelessWidget {
  const _DecimalInlineField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toStringAsFixed(1),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (raw) {
        final parsed = double.tryParse(raw.replaceAll(',', '.').trim());
        if (parsed == null) {
          return;
        }
        onChanged(parsed.clamp(min, max));
      },
    );
  }
}

class ElementoEtiquetaPreview {
  ElementoEtiquetaPreview({
    required this.nome,
    required this.tipoElemento,
    required this.textoExemplo,
    required this.xMm,
    required this.yMm,
    required this.tamanhoFonteMm,
    required this.alturaCodigoBarrasMm,
    this.fixo = false,
    this.limiteCaracteres,
  });

  factory ElementoEtiquetaPreview.fromCampo(
    TipoCampoEtiqueta campo, {
    required String textoExemplo,
    double? xMm,
    double? yMm,
    double? tamanhoFonteMm,
    double? alturaCodigoBarrasMm,
    int? limiteCaracteres,
  }) {
    return ElementoEtiquetaPreview(
      nome: campo.nome,
      tipoElemento: campo.tipoElemento,
      textoExemplo: textoExemplo,
      xMm: xMm ?? campo.xPadraoMm,
      yMm: yMm ?? campo.yPadraoMm,
      tamanhoFonteMm: tamanhoFonteMm ?? campo.tamanhoFontePadraoMm,
      alturaCodigoBarrasMm: alturaCodigoBarrasMm ?? campo.alturaCodigoPadraoMm,
      limiteCaracteres: limiteCaracteres,
    );
  }

  // Texto Fixo: elemento de nome livre (nao vem de TipoCampoEtiqueta), cujo `textoExemplo` e o
  // conteudo LITERAL final -- nunca vira placeholder {nome} na geracao do ZPL salvo.
  factory ElementoEtiquetaPreview.textoFixo({
    required String nome,
    required String texto,
    double xMm = 1,
    double yMm = 1,
    double tamanhoFonteMm = 2,
  }) {
    return ElementoEtiquetaPreview(
      nome: nome,
      tipoElemento: TipoElemento.texto,
      textoExemplo: texto,
      xMm: xMm,
      yMm: yMm,
      tamanhoFonteMm: tamanhoFonteMm,
      alturaCodigoBarrasMm: 6.25,
      fixo: true,
    );
  }

  final String nome;
  final TipoElemento tipoElemento;
  final bool fixo;
  String textoExemplo;
  double xMm;
  double yMm;
  double tamanhoFonteMm;
  double alturaCodigoBarrasMm;
  // So se aplica a campos DINAMICOS de texto (nao fixo, nao codigoBarras) -- limite de
  // caracteres impresso a partir do dado real do produto, resolvido em tempo de impressao.
  int? limiteCaracteres;

  bool get suportaLimiteCaracteres => !fixo && tipoElemento == TipoElemento.texto;
}

enum TipoCampoEtiqueta {
  titulo,
  preco,
  tamanho,
  descricao,
  cor,
  codigoBarras,
}

extension TipoCampoEtiquetaX on TipoCampoEtiqueta {
  String get nome {
    return switch (this) {
      TipoCampoEtiqueta.titulo => 'titulo',
      TipoCampoEtiqueta.preco => 'preco',
      TipoCampoEtiqueta.tamanho => 'tamanho',
      TipoCampoEtiqueta.descricao => 'descricao',
      TipoCampoEtiqueta.cor => 'cor',
      TipoCampoEtiqueta.codigoBarras => 'codigoBarras',
    };
  }

  String get descricao {
    return switch (this) {
      TipoCampoEtiqueta.titulo => 'Texto maior para destaque.',
      TipoCampoEtiqueta.preco => 'Valor de preco exibido em texto.',
      TipoCampoEtiqueta.tamanho => 'Texto do tamanho do produto.',
      TipoCampoEtiqueta.descricao => 'Descricao do item.',
      TipoCampoEtiqueta.cor => 'Cor do item.',
      TipoCampoEtiqueta.codigoBarras => 'Codigo de barras EAN-12 (renderizado em EAN-13).',
    };
  }

  TipoElemento get tipoElemento {
    return this == TipoCampoEtiqueta.codigoBarras
        ? TipoElemento.codigoDeBarras
        : TipoElemento.texto;
  }

  String get exemploPadrao {
    return switch (this) {
      TipoCampoEtiqueta.titulo => '{titulo}',
      TipoCampoEtiqueta.preco => '{preco}',
      TipoCampoEtiqueta.tamanho => '{tamanho}',
      TipoCampoEtiqueta.descricao => '{descricao}',
      TipoCampoEtiqueta.cor => '{cor}',
      TipoCampoEtiqueta.codigoBarras => '{codigoBarras}',
    };
  }

  double get xPadraoMm {
    return switch (this) {
      TipoCampoEtiqueta.titulo => 14,
      TipoCampoEtiqueta.preco => 1,
      TipoCampoEtiqueta.tamanho => 27,
      TipoCampoEtiqueta.descricao => 1,
      TipoCampoEtiqueta.cor => 1,
      TipoCampoEtiqueta.codigoBarras => 14,
    };
  }

  double get yPadraoMm {
    return switch (this) {
      TipoCampoEtiqueta.titulo => 1,
      TipoCampoEtiqueta.preco => 6.75,
      TipoCampoEtiqueta.tamanho => 6.75,
      TipoCampoEtiqueta.descricao => 11.25,
      TipoCampoEtiqueta.cor => 14.5,
      TipoCampoEtiqueta.codigoBarras => 18.75,
    };
  }

  double get tamanhoFontePadraoMm {
    return this == TipoCampoEtiqueta.titulo ? 4 : 2;
  }

  double get alturaCodigoPadraoMm => 6.25;

  String get chaveX => '${nome}Xmm';
  String get chaveY => '${nome}Ymm';
  String get chaveTamanhoFonte => '${nome}TamanhoFonteMm';
  String get chaveAlturaCodigo => '${nome}AlturaMm';
  String get chaveLimiteCaracteres => '${nome}LimiteCaracteres';
}

enum TipoElemento {
  texto,
  codigoDeBarras,
}

extension TipoElementoX on TipoElemento {
  String get valor {
    return switch (this) {
      TipoElemento.texto => 'texto',
      TipoElemento.codigoDeBarras => 'codigoDeBarras',
    };
  }
}

enum EtiquetaDpi {
  d101,
  d152,
  d203,
  d300,
  d600,
}

extension EtiquetaDpiX on EtiquetaDpi {
  int get valor {
    return switch (this) {
      EtiquetaDpi.d101 => 101,
      EtiquetaDpi.d152 => 152,
      EtiquetaDpi.d203 => 203,
      EtiquetaDpi.d300 => 300,
      EtiquetaDpi.d600 => 600,
    };
  }

  int get dotsPorMm {
    return switch (this) {
      EtiquetaDpi.d101 => 4,
      EtiquetaDpi.d152 => 6,
      EtiquetaDpi.d203 => 8,
      EtiquetaDpi.d300 => 12,
      EtiquetaDpi.d600 => 24,
    };
  }

  ZplPrintDensity get zplPrintDensity {
    return switch (this) {
      EtiquetaDpi.d101 => ZplPrintDensity.half,
      EtiquetaDpi.d152 => ZplPrintDensity.d6,
      EtiquetaDpi.d203 => ZplPrintDensity.d8,
      EtiquetaDpi.d300 => ZplPrintDensity.d12,
      EtiquetaDpi.d600 => ZplPrintDensity.d24,
    };
  }
}
