import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/seletores.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/pessoas_bloc/pessoas_bloc.dart';

enum PessoaSeletorModo { unica, multipla }

// ignore: must_be_immutable
class SeletorPessoa extends StatefulWidget implements ISeletor {
  final PessoaSeletorModo modo;
  final List<Pessoa> pessoasSelecionadasIniciais;
  final ValueChanged<List<Pessoa>>? onPessoaChanged;
  final bool retornarSomenteId;
  final Map<String, String>? valorAtual;
  final ValueChanged<Map<String, String>>? onSelecionado;
  final String rotaSelecao;
  final String? titulo;
  final bool onlyView;
  final bool? eCliente;
  final bool? eFuncionario;
  final bool? eFornecedor;
  final bool? clienteOuFuncionario;

  @override
  final List<SelectData>? itemsSelecionadosInicial;

  @override
  final Function(List<SelectData>)? onChanged;

  const SeletorPessoa({
    super.key,
    this.modo = PessoaSeletorModo.unica,
    this.pessoasSelecionadasIniciais = const [],
    this.onPessoaChanged,
    required this.retornarSomenteId,
    this.onSelecionado,
    this.valorAtual,
    this.rotaSelecao = '/selecionar_pessoa',
    this.titulo,
    this.itemsSelecionadosInicial,
    this.onChanged,
    this.onlyView = false,
    this.eCliente,
    this.eFuncionario,
    this.eFornecedor,
    this.clienteOuFuncionario,
  });

  @override
  State<SeletorPessoa> createState() => _SeletorPessoaState();
}

class _SeletorPessoaState extends State<SeletorPessoa> {
  late final PessoasBloc _pessoasBloc;
  late final Debouncer _buscaDebouncer;
  PessoasCarregarSucesso? _ultimoSucesso;

  @override
  void initState() {
    super.initState();
    _buscaDebouncer = Debouncer(milliseconds: 350);
    _pessoasBloc = sl<PessoasBloc>()
      ..add(PessoasIniciou(
        eCliente: widget.eCliente,
        eFuncionario: widget.eFuncionario,
        eFornecedor: widget.eFornecedor,
        clienteOuFuncionario: widget.clienteOuFuncionario,
      ));
  }

  @override
  void dispose() {
    _pessoasBloc.close();
    super.dispose();
  }

  // Só as primeiras pessoas (1 página) ficam pré-carregadas -- sem isso,
  // digitar o nome de alguém fora dessa página nunca encontra ninguém, por
  // mais correto que o texto esteja. Reflete no servidor a cada digitação
  // (com debounce), igual a busca em /selecionar_pessoa já faz.
  void _onBuscaChanged(String busca) {
    _buscaDebouncer.run(() {
      if (!mounted) return;
      _pessoasBloc.add(PessoasIniciou(
        busca: busca.trim().isEmpty ? null : busca.trim(),
        eCliente: widget.eCliente,
        eFuncionario: widget.eFuncionario,
        eFornecedor: widget.eFornecedor,
        clienteOuFuncionario: widget.clienteOuFuncionario,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider<PessoasBloc>.value(
      value: _pessoasBloc,
      child: BlocBuilder<PessoasBloc, PessoasState>(
        builder: (context, state) {
          if (state is PessoasCarregarSucesso) {
            _ultimoSucesso = state;
          }

          // Rebusca (digitação, com debounce) reemite "em progresso" a cada
          // vez -- se isso trocasse a tela inteira por um spinner, o campo
          // de texto seria desmontado a cada letra e perderia o foco.
          // Mantém a última lista carregada com sucesso visível enquanto a
          // busca nova roda; só mostra o spinner de tela cheia no carregamento
          // inicial de verdade (nunca carregou nada ainda).
          final estadoExibido = _ultimoSucesso;
          final buscandoNoServidor =
              state is PessoasCarregarEmProgresso && estadoExibido != null;

          if (estadoExibido == null) {
            if (state is PessoasCarregarFalha) {
              return _mensagem(
                context,
                'Não foi possível carregar as pessoas.',
                theme.colorScheme.error,
              );
            }
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final pessoasIniciais = _resolverPessoasIniciais();
          final idsSelecionados = pessoasIniciais
              .map((pessoa) => pessoa.id)
              .whereType<int>()
              .toSet();

          final pessoasAtivas = estadoExibido.pessoas
              .where((pessoa) => !pessoa.bloqueado)
              .toList();
          final pessoasSelecionadas = [
            ...estadoExibido.pessoas.where(
              (pessoa) =>
                  pessoa.id != null && idsSelecionados.contains(pessoa.id),
            ),
            ...pessoasIniciais.where(
              (pessoaInicial) =>
                  pessoaInicial.id == null ||
                  !estadoExibido.pessoas.any(
                    (pessoa) => _mesmaPessoa(pessoa, pessoaInicial),
                  ),
            ),
          ];
          final pessoasDisponiveis = [
            ...pessoasSelecionadas,
            ...pessoasAtivas.where(
              (pessoa) =>
                  pessoa.id == null || !idsSelecionados.contains(pessoa.id),
            ),
          ];

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SeletorGenerico<Pessoa>(
                toSelectData: _toSelectData,
                itens: pessoasDisponiveis,
                itemLabel: (pessoa) => pessoa.nome,
                itemKey: (pessoa) =>
                    pessoa.id ?? '${pessoa.nome}-${pessoa.documento}',
                modo: widget.modo == PessoaSeletorModo.unica
                    ? SeletorGenericoModo.unica
                    : SeletorGenericoModo.multipla,
                selecionadosIniciais: estadoExibido.pessoaSelecionada != null
                    ? [estadoExibido.pessoaSelecionada!]
                    : pessoasIniciais,
                onChanged: (List<Pessoa> selecionadas) {
                  widget.onPessoaChanged?.call(selecionadas);

                  final dadosSelecionados =
                      selecionadas.map(_toSelectData).toList(growable: false);
                  widget.onChanged?.call(dadosSelecionados);

                  final pessoa = selecionadas.firstOrNull;
                  if (widget.onSelecionado != null) {
                    widget.onSelecionado!.call(_toResultadoMapa(pessoa));
                  }
                },
                onlyView: widget.onlyView,
                titulo: _buildTitulo(),
                hintText: 'Busque por nome, CPF/CNPJ ou ID',
                maxSugestoes: 5,
                onBuscaChanged: _onBuscaChanged,
                chipAvatarBuilder: (context, pessoa) =>
                    const Icon(Icons.person_outline, size: 16),
                sugestaoLeadingBuilder: (context, pessoa) {
                  final colorScheme = Theme.of(context).colorScheme;
                  return CircleAvatar(
                    radius: 14,
                    backgroundColor: colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  );
                },
                sugestaoTrailingBuilder: (context, pessoa) {
                  final documento = pessoa.documento.trim();
                  if (documento.isEmpty) return const SizedBox.shrink();
                  return Text(
                    documento,
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                },
                confirmarEmSeparadores: const [',', ';'],
              ),
              if (buscandoNoServidor)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Buscando no servidor...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _buildTitulo() {
    if (widget.titulo != null && widget.titulo!.isNotEmpty) {
      return widget.titulo!;
    }
    if (widget.onlyView) {
      return widget.titulo ?? 'Pessoa';
    }
    if (widget.titulo == null) {
      return widget.modo == PessoaSeletorModo.unica
          ? 'Selecionar pessoa'
          : 'Selecionar pessoas';
    }

    return widget.modo == PessoaSeletorModo.unica
        ? 'Selecionar pessoa'
        : 'Selecionar pessoas';
  }

  List<Pessoa> _resolverPessoasIniciais() {
    if (widget.pessoasSelecionadasIniciais.isNotEmpty) {
      return widget.pessoasSelecionadasIniciais;
    }

    if ((widget.itemsSelecionadosInicial ?? const []).isNotEmpty) {
      return widget.itemsSelecionadosInicial!
          .map(_pessoaFromSelectData)
          .toList(growable: false);
    }

    final nome = widget.valorAtual?['nome']?.trim() ?? '';
    final documento = widget.valorAtual?['documento']?.trim() ?? '';
    final email = widget.valorAtual?['email']?.trim();
    final telefone = widget.valorAtual?['telefone']?.trim();

    if (nome.isEmpty && documento.isEmpty) {
      return const [];
    }

    return [
      Pessoa.create(
        id: int.tryParse(widget.valorAtual?['id'] ?? ''),
        nome: nome.isNotEmpty ? nome : 'Pessoa selecionada',
        tipoPessoa: TipoPessoa.fisica,
        documento: documento,
        email: email?.isEmpty == true ? null : email,
        tipoContato: TipoContato.telefone,
        contato: telefone?.isEmpty == true ? null : telefone,
        eCliente: true,
        eFornecedor: false,
        eFuncionario: false,
        bloqueado: false,
        generica: false,
      ),
    ];
  }

  Pessoa _pessoaFromSelectData(SelectData item) {
    final data = item.data;
    final id = data['id'] is int
        ? data['id'] as int
        : int.tryParse(data['id']?.toString() ?? '') ??
            (item.id > 0 ? item.id : 0);

    return Pessoa.create(
      id: id > 0 ? id : null,
      nome: item.nome.trim().isNotEmpty
          ? item.nome
          : data['nome']?.toString() ?? 'Pessoa selecionada',
      tipoPessoa: TipoPessoa.fisica,
      documento: data['documento']?.toString() ?? '',
      email: data['email']?.toString(),
      tipoContato: TipoContato.telefone,
      contato:
          data['telefone']?.toString() ?? data['contato']?.toString() ?? '',
      eCliente: true,
      eFornecedor: false,
      eFuncionario: false,
      bloqueado: false,
      generica: data['generica'] == true,
    );
  }

  SelectData _toSelectData(Pessoa pessoa) {
    return SelectData(
      id: pessoa.id ?? 0,
      nome: pessoa.nome,
      data: {
        'id': pessoa.id,
        'nome': pessoa.nome,
        'documento': pessoa.documento,
        'email': pessoa.email,
        'telefone': pessoa.contato,
        'generica': pessoa.generica,
      },
    );
  }

  Map<String, String> _toResultadoMapa(Pessoa? pessoa) {
    if (pessoa == null) {
      return widget.retornarSomenteId
          ? {'id': ''}
          : {
              'id': '',
              'nome': '',
              'documento': '',
              'email': '',
              'telefone': '',
            };
    }

    if (widget.retornarSomenteId) {
      return {'id': pessoa.id?.toString() ?? ''};
    }

    return {
      'id': pessoa.id?.toString() ?? '',
      'nome': pessoa.nome,
      'documento': pessoa.documento,
      'email': pessoa.email ?? '',
      'telefone': pessoa.contato ?? '',
    };
  }

  Widget _mensagem(BuildContext context, String texto, Color cor) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        texto,
        style: theme.textTheme.bodyMedium?.copyWith(color: cor),
      ),
    );
  }

  bool _mesmaPessoa(Pessoa a, Pessoa b) {
    if (a.id != null && b.id != null) {
      return a.id == b.id;
    }
    return a.nome == b.nome && a.documento == b.documento;
  }
}
