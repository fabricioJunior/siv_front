import 'package:autenticacao/models.dart' show TerminalDoUsuario;
import 'package:autenticacao/presentation/bloc/login_bloc/login_bloc.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/presentation/blocs/empresas_bloc/empresas_bloc.dart';
import 'package:flutter/material.dart';

/// Etapas 2 e 3 do fluxo de acesso (empresa + terminal), na mesma tela: um
/// grid de empresas à esquerda e um painel de terminais à direita, que
/// aparece assim que uma empresa é escolhida.
class SelecionarEmpresaPage extends StatefulWidget {
  const SelecionarEmpresaPage({super.key});

  @override
  State<SelecionarEmpresaPage> createState() => _SelecionarEmpresaPageState();
}

class _SelecionarEmpresaPageState extends State<SelecionarEmpresaPage> {
  final EmpresasBloc _bloc = sl<EmpresasBloc>();
  final LoginBloc _loginBloc = sl<LoginBloc>();
  final TextEditingController _buscaController = TextEditingController();
  String _busca = '';

  Empresa? _empresaSelecionada;
  List<TerminalDoUsuario>? _terminaisDaEmpresa;
  bool _carregandoTerminais = false;
  TerminalDoUsuario? _terminalSelecionado;

  @override
  void initState() {
    super.initState();
    _bloc.add(EmpresasIniciou());
  }

  @override
  void dispose() {
    _buscaController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocProvider<EmpresasBloc>.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: cores.papel,
        appBar: AppBar(title: const Text('Selecionar empresa')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _indicadorDeEtapas(context),
                const SizedBox(height: 16),
                Text('Escolha a empresa para continuar', style: textos.titulo),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mostrarPainel =
                          _empresaSelecionada != null && constraints.maxWidth >= 900;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _gridDeEmpresas(context)),
                          if (mostrarPainel) ...[
                            const SizedBox(width: 20),
                            SizedBox(width: 400, child: _painelDeTerminais(context)),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _indicadorDeEtapas(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    Widget etapa(String texto, bool ativo) => Text(
          texto,
          style: textos.rotulo.copyWith(
            color: ativo ? cores.acoEscuro : cores.textoDesabilitado,
          ),
        );

    return Row(
      children: [
        etapa('LICENCIADO', false),
        Text('  ·  ', style: textos.rotulo.copyWith(color: cores.textoDesabilitado)),
        etapa('EMPRESA', _empresaSelecionada == null),
        Text('  ·  ', style: textos.rotulo.copyWith(color: cores.textoDesabilitado)),
        etapa('TERMINAL', _empresaSelecionada != null),
      ],
    );
  }

  Widget _gridDeEmpresas(BuildContext context) {
    final cores = context.sivColors;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _buscaController,
          decoration: const InputDecoration(
            labelText: 'Buscar por nome ou CNPJ',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) => setState(() => _busca = value.trim()),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: BlocBuilder<EmpresasBloc, EmpresasState>(
            bloc: _bloc,
            builder: (context, state) {
              if (state is EmpresasCarregarEmProgresso ||
                  state is EmpresasNaoInicializado) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }

              if (state is EmpresasCarregarFalha) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 40, color: cores.vinho),
                        const SizedBox(height: 12),
                        Text(
                          'Não foi possível carregar as empresas disponíveis.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _bloc.add(EmpresasIniciou()),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final empresas = state is EmpresasCarregarSucesso
                  ? state.empresas
                  : <Empresa>[];
              final filtradas = _filtrarEmpresas(empresas);

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: SivDimensoes.gapCards,
                  crossAxisSpacing: SivDimensoes.gapCards,
                  childAspectRatio: 2.4,
                ),
                itemCount: filtradas.length + 1,
                itemBuilder: (context, index) {
                  if (index == filtradas.length) {
                    return _cardCadastrarEmpresa(context);
                  }
                  return _empresaCard(context, filtradas[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _empresaCard(BuildContext context, Empresa empresa) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final selecionada = _empresaSelecionada?.id == empresa.id;

    return Material(
      color: cores.superficie,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: InkWell(
        key: Key('selecionar_empresa_item_${empresa.id}'),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: () => _selecionarEmpresa(empresa),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
            border: Border.all(
              color: selecionada ? cores.acoEscuro : cores.hairline,
              width: selecionada ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            empresa.nome,
                            style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selecionada)
                          Icon(Icons.check_circle, color: cores.acoEscuro, size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      empresa.cnpj,
                      style: textos.apoio.copyWith(color: cores.textoApoio),
                    ),
                    if ((empresa.municipio ?? '').isNotEmpty)
                      Text(
                        empresa.municipio!,
                        style: textos.apoio.copyWith(color: cores.textoApoio),
                        overflow: TextOverflow.ellipsis,
                      ),
                    // TODO: contagem de terminais, caixas abertos e último
                    // acesso não existem em `Empresa` (empresas/domain/entities/empresa.dart)
                    // hoje -- exibir aqui quando o backend expuser esses dados.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cardCadastrarEmpresa(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return InkWell(
      key: const Key('selecionar_empresa_cadastrar_button'),
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      onTap: () async {
        await Navigator.of(context).pushNamed('/empresa');
        _bloc.add(EmpresasIniciou());
      },
      child: DottedBorder(
        color: cores.hairline,
        radius: SivDimensoes.raio,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_business_outlined, color: cores.aco),
              const SizedBox(height: 6),
              Text('Cadastrar empresa', style: textos.apoio.copyWith(color: cores.aco)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _painelDeTerminais(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final empresa = _empresaSelecionada!;

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Terminal', style: textos.secao),
          const SizedBox(height: 2),
          Text(
            empresa.nome,
            style: textos.apoio.copyWith(color: cores.textoApoio),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          if (_carregandoTerminais)
            const Center(child: CircularProgressIndicator.adaptive())
          else if ((_terminaisDaEmpresa ?? const []).isEmpty)
            Text(
              'Nenhum terminal disponível para esta empresa.',
              style: textos.corpo.copyWith(color: cores.textoApoio),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_terminaisDaEmpresa ?? const [])
                  .map((terminal) => _terminalTile(context, terminal))
                  .toList(),
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            width: double.infinity,
            child: FilledButton(
              key: const Key('selecionar_empresa_entrar_button'),
              style: FilledButton.styleFrom(
                backgroundColor: cores.acoEscuro,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
              ),
              onPressed: _terminalSelecionado == null && (_terminaisDaEmpresa ?? const []).isNotEmpty
                  ? null
                  : () => _confirmarEntrada(empresa),
              child: Text(
                _terminalSelecionado != null
                    ? 'Entrar na ${empresa.nome} · Terminal ${_terminalSelecionado!.nome}'
                    : 'Entrar na ${empresa.nome}',
                style: textos.rotulo.copyWith(
                  color: cores.textoSobreEscuroTitulo,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _terminalTile(BuildContext context, TerminalDoUsuario terminal) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final selecionado = _terminalSelecionado?.id == terminal.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selecionado ? cores.selecaoFundo : cores.superficieRecuada,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        child: InkWell(
          key: Key('selecionar_empresa_terminal_${terminal.id}'),
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          onTap: () => setState(() => _terminalSelecionado = terminal),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              border: Border.all(
                color: selecionado ? cores.acoEscuro : cores.hairline,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.point_of_sale_outlined, color: cores.aco, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(terminal.nome, style: textos.corpo),
                  // TODO: impressora e estado (caixa aberto/valor, livre,
                  // em uso por outro usuário) não estão em `TerminalDoUsuario`
                  // (packages/autenticacao/lib/domain/models/terminal_do_usuario.dart)
                  // hoje -- exibir quando o campo existir.
                ),
                if (selecionado)
                  Icon(Icons.check_circle, color: cores.acoEscuro, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selecionarEmpresa(Empresa empresa) async {
    setState(() {
      _empresaSelecionada = empresa;
      _terminaisDaEmpresa = null;
      _terminalSelecionado = null;
      _carregandoTerminais = true;
    });

    final idEmpresa = empresa.id;
    final terminais = idEmpresa == null
        ? const <TerminalDoUsuario>[]
        : await _loginBloc.buscarTerminaisParaEmpresa(idEmpresa);

    if (!mounted || _empresaSelecionada?.id != empresa.id) return;

    setState(() {
      _terminaisDaEmpresa = terminais;
      _terminalSelecionado = terminais.length == 1 ? terminais.first : null;
      _carregandoTerminais = false;
    });
  }

  void _confirmarEntrada(Empresa empresa) {
    Navigator.of(context).pop({
      'idEmpresa': empresa.id,
      'nomeEmpresa': empresa.nome,
      if (_terminalSelecionado != null) 'idTerminal': _terminalSelecionado!.id,
      if (_terminalSelecionado != null) 'nomeTerminal': _terminalSelecionado!.nome,
    });
  }

  List<Empresa> _filtrarEmpresas(List<Empresa> empresas) {
    final termo = _busca.toLowerCase();
    if (termo.isEmpty) return empresas;

    return empresas.where((empresa) {
      final nome = empresa.nome.toLowerCase();
      final cnpj = empresa.cnpj.toLowerCase();
      return nome.contains(termo) || cnpj.contains(termo);
    }).toList();
  }
}

/// Borda tracejada simples pro card "Cadastrar empresa" -- não há
/// dependência de pacote externo pra isso hoje, então desenha via
/// [CustomPainter] mesmo.
class DottedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;

  const DottedBorder({
    super.key,
    required this.child,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DottedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}
