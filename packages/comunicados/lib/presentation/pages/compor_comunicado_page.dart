import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/presentation/blocs/composicao_comunicado_bloc/composicao_comunicado_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/imagens/selecionar_imagem.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/sessao.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

const _origensDisponiveis = [
  (null, 'Todas as origens'),
  ('ecommerce', 'E-commerce'),
  ('ia_vendas', 'IA de vendas'),
  ('atendente_humano', 'Atendente humano'),
  ('loja_fisica_direto', 'Loja física'),
];

class ComporComunicadoPage extends StatefulWidget {
  const ComporComunicadoPage({super.key});

  @override
  State<ComporComunicadoPage> createState() => _ComporComunicadoPageState();
}

class _ComporComunicadoPageState extends State<ComporComunicadoPage> {
  late final ComposicaoComunicadoBloc _bloc;
  final _quillController = QuillController.basic();
  final _assuntoController = TextEditingController();
  final _corpoAvancadoController = TextEditingController();
  final _diasJanelaController = TextEditingController(text: '90');
  final _corpoDebouncer = Debouncer(milliseconds: 500);

  bool _modoHtmlAvancado = false;
  DateTime? _dataInicio;
  DateTime? _dataFim;
  String? _origem;
  String? _ativoInativo;

  @override
  void initState() {
    super.initState();
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    _bloc = sl<ComposicaoComunicadoBloc>(
      param1: FiltroDestinatarioComunicado(
        empresaIds: empresaId != null ? [empresaId] : const [],
      ),
    );
    _quillController.addListener(_onCorpoQuillAlterado);
    _bloc.add(ComposicaoContarDestinatarios());
  }

  @override
  void dispose() {
    _quillController.removeListener(_onCorpoQuillAlterado);
    _quillController.dispose();
    _assuntoController.dispose();
    _corpoAvancadoController.dispose();
    _diasJanelaController.dispose();
    _corpoDebouncer.cancel();
    _bloc.close();
    super.dispose();
  }

  void _onCorpoQuillAlterado() {
    _corpoDebouncer.run(() {
      if (!mounted || _modoHtmlAvancado) return;
      _bloc.add(ComposicaoCorpoAlterado(_gerarHtmlDoQuill()));
    });
  }

  String _gerarHtmlDoQuill() {
    final ops = _quillController.document
        .toDelta()
        .toJson()
        .cast<Map<String, dynamic>>();
    return QuillDeltaToHtmlConverter(ops, ConverterOptions.forEmail()).convert();
  }

  void _atualizarFiltro() {
    final empresaId = sl<IAcessoGlobalSessao>().empresaIdDaSessao;
    final diasJanela = int.tryParse(_diasJanelaController.text.trim());
    _bloc.add(
      ComposicaoFiltroAlterado(
        FiltroDestinatarioComunicado(
          empresaIds: empresaId != null ? [empresaId] : const [],
          dataInicio: _dataInicio,
          dataFim: _dataFim,
          origem: _origem,
          ativoInativo: _ativoInativo,
          diasJanela: _ativoInativo != null ? diasJanela : null,
        ),
      ),
    );
  }

  Future<void> _selecionarData({required bool inicio}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (inicio ? _dataInicio : _dataFim) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked == null) return;
    setState(() {
      if (inicio) {
        _dataInicio = picked;
      } else {
        _dataFim = picked;
      }
    });
    _atualizarFiltro();
  }

  Future<void> _inserirImagem() async {
    final imagens = await showSelecionarImagemModal(context);
    final imagem = (imagens != null && imagens.isNotEmpty) ? imagens.first : null;
    if (imagem?.path == null || !mounted) return;
    _bloc.add(ComposicaoImagemSolicitada(imagem!.path!));
  }

  void _inserirImagemNoEditor(String url) {
    final index = _quillController.selection.baseOffset;
    final length =
        _quillController.selection.extentOffset - _quillController.selection.baseOffset;
    _quillController.replaceText(
      index < 0 ? 0 : index,
      length < 0 ? 0 : length,
      BlockEmbed.image(url),
      null,
    );
  }

  Future<void> _confirmarEnvio(int totalDestinatarios) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Enviar comunicado'),
        content: Text(
          'Este comunicado será enviado para $totalDestinatarios destinatário(s). '
          'Esta ação não pode ser desfeita. Deseja continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      final corpoHtml = _modoHtmlAvancado
          ? _corpoAvancadoController.text
          : _gerarHtmlDoQuill();
      _bloc.add(ComposicaoEnviar(corpoHtml));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ComposicaoComunicadoBloc>.value(
      value: _bloc,
      child: BlocConsumer<ComposicaoComunicadoBloc, ComposicaoComunicadoState>(
        listenWhen: (previous, current) =>
            previous.erro != current.erro ||
            previous.imagemUrl != current.imagemUrl ||
            previous.comunicadoCriado != current.comunicadoCriado,
        listener: (context, state) {
          if (state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!), backgroundColor: Colors.red),
            );
          }
          if (state.imagemUrl != null) {
            _inserirImagemNoEditor(state.imagemUrl!);
            _bloc.add(ComposicaoImagemConsumida());
          }
          if (state.comunicadoCriado != null) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Novo comunicado')),
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _assuntoController,
                  decoration: const InputDecoration(
                    labelText: 'Assunto',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => _bloc.add(ComposicaoAssuntoAlterado(v)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Corpo do e-mail',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Row(
                      children: [
                        const Text('Colar HTML direto', style: TextStyle(fontSize: 12)),
                        Switch(
                          value: _modoHtmlAvancado,
                          onChanged: (v) {
                            setState(() => _modoHtmlAvancado = v);
                            _bloc.add(ComposicaoModoHtmlAvancadoAlterado(v));
                            _bloc.add(
                              ComposicaoCorpoAlterado(
                                v ? _corpoAvancadoController.text : _gerarHtmlDoQuill(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                if (_modoHtmlAvancado) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: const Text(
                      'Modo avançado: cole HTML diretamente. Alternar de volta pro editor '
                      'visual pode não recuperar a formatação.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _corpoAvancadoController,
                    maxLines: 14,
                    decoration: const InputDecoration(
                      hintText: '<html>...</html>',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _bloc.add(ComposicaoCorpoAlterado(v)),
                  ),
                ] else ...[
                  QuillSimpleToolbar(
                    controller: _quillController,
                    config: QuillSimpleToolbarConfig(
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                          icon: state.enviandoImagem
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.image_outlined),
                          tooltip: 'Inserir imagem',
                          onPressed: state.enviandoImagem ? null : _inserirImagem,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: QuillEditor.basic(
                      controller: _quillController,
                      config: QuillEditorConfig(
                        padding: const EdgeInsets.all(8),
                        embedBuilders: FlutterQuillEmbeds.defaultEditorBuilders(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Destinatários',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(
                          _dataInicio != null
                              ? 'De: ${formatarData(_dataInicio)}'
                              : 'Última compra a partir de',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => _selecionarData(inicio: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 14),
                        label: Text(
                          _dataFim != null
                              ? 'Até: ${formatarData(_dataFim)}'
                              : 'Última compra até',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () => _selecionarData(inicio: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String?>(
                  value: _origem,
                  decoration: const InputDecoration(
                    labelText: 'Origem da última compra',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: _origensDisponiveis
                      .map(
                        (op) => DropdownMenuItem(value: op.$1, child: Text(op.$2)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setState(() => _origem = v);
                    _atualizarFiltro();
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String?>(
                        value: _ativoInativo,
                        decoration: const InputDecoration(
                          labelText: 'Ativo / Inativo',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('Sem filtro')),
                          DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                          DropdownMenuItem(value: 'inativo', child: Text('Inativo')),
                        ],
                        onChanged: (v) {
                          setState(() => _ativoInativo = v);
                          _atualizarFiltro();
                        },
                      ),
                    ),
                    if (_ativoInativo != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _diasJanelaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Dias',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onChanged: (_) => _atualizarFiltro(),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (state.contandoDestinatarios)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      const Icon(Icons.people_outline, size: 16, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Text(
                      '${state.totalDestinatarios} destinatário(s) encontrado(s)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  icon: state.enviando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Enviar'),
                  onPressed: state.podeEnviar
                      ? () => _confirmarEnvio(state.totalDestinatarios)
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
