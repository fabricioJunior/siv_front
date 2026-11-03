import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/integracao_infinity_pay.dart';
import 'package:empresas/presentation/blocs/integracao_infinity_pay_bloc/integracao_infinity_pay_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef _Bloc = IntegracaoInfinityPayBloc;
typedef _Estado = IntegracaoInfinityPayState;

/// Tela 1c (mobile): formulário da InfinityPay. Exige o bloc no contexto.
class IntegracaoInfinityPayPage extends StatelessWidget {
  const IntegracaoInfinityPayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtegeSaidaInfinityPay(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 52,
          title: const Text('InfinityPay'),
          actions: const [SeloStatusInfinityPay(), SizedBox(width: 12)],
        ),
        body: const SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: IntegracaoInfinityPayForm(compacto: true),
                ),
              ),
              IntegracaoInfinityPayRodape(compacto: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirma antes de sair com alterações pendentes.
class ProtegeSaidaInfinityPay extends StatelessWidget {
  final Widget child;

  const ProtegeSaidaInfinityPay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_Bloc, _Estado>(
      buildWhen: (a, b) => a.sujos.isEmpty != b.sujos.isEmpty,
      builder: (context, state) => PopScope(
        canPop: state.sujos.isEmpty,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final bloc = context.read<_Bloc>();
          final navigator = Navigator.of(context);
          final descartar = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Descartar alterações?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('CONTINUAR EDITANDO'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('DESCARTAR'),
                ),
              ],
            ),
          );
          if (descartar != true) return;
          bloc.add(IntegracaoInfinityPayDescartou());
          navigator.pop();
        },
        child: child,
      ),
    );
  }
}

class SeloStatusInfinityPay extends StatelessWidget {
  const SeloStatusInfinityPay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<_Bloc, _Estado>(
      buildWhen: (a, b) => a.status != b.status,
      builder: (context, state) => SeloStatus(
        texto: switch (state.status) {
          StatusInfinityPay.ativa => 'ATIVA',
          StatusInfinityPay.incompleta => 'INCOMPLETA',
          StatusInfinityPay.desligada => 'DESLIGADA',
        },
        tipo: switch (state.status) {
          StatusInfinityPay.ativa => TipoSelo.ok,
          StatusInfinityPay.incompleta => TipoSelo.alerta,
          StatusInfinityPay.desligada => TipoSelo.neutro,
        },
      ),
    );
  }
}

enum TipoSelo { ok, alerta, neutro }

class SeloStatus extends StatelessWidget {
  final String texto;
  final TipoSelo tipo;

  const SeloStatus({super.key, required this.texto, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final c = context.sivColors;
    final (fundo, fg) = switch (tipo) {
      TipoSelo.ok => (c.conferidoFundo, c.conferidoTexto),
      TipoSelo.alerta => (c.parcialFundo, c.parcialTexto),
      TipoSelo.neutro => (c.superficieRecuada, c.textoApoio),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(texto, style: context.sivTextos.rotulo.copyWith(color: fg)),
    );
  }
}

class IntegracaoInfinityPayRodape extends StatelessWidget {
  final bool compacto;

  const IntegracaoInfinityPayRodape({super.key, required this.compacto});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return BlocBuilder<_Bloc, _Estado>(
      builder: (context, s) {
        final erros = s.erros.length;
        final sujos = s.sujos.length;
        final (texto, cor) = s.salvou
            ? ('✓ Configuração salva', cores.conferidoTexto)
            : erros > 0
            ? (
                erros == 1
                    ? '1 campo precisa de ajuste'
                    : '$erros campos precisam de ajuste',
                cores.vinho,
              )
            : sujos > 0
            ? (
                sujos == 1
                    ? '1 alteração não salva'
                    : '$sujos alterações não salvas',
                cores.parcialTexto,
              )
            : ('Tudo salvo', cores.textoApoio);
        final salvando = s.etapa == EtapaInfinityPay.salvando;
        final bloc = context.read<_Bloc>();

        final descartar = SizedBox(
          height: 48,
          child: OutlinedButton(
            onPressed: (sujos > 0 || s.errosServidor.isNotEmpty) && !salvando
                ? () => bloc.add(IntegracaoInfinityPayDescartou())
                : null,
            child: const Text('Descartar'),
          ),
        );
        final salvar = Stack(
          children: [
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: s.podeSalvar
                    ? () => bloc.add(IntegracaoInfinityPaySalvou())
                    : null,
                child: salvando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SALVAR'),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(children: sivCantosBlueprint(cores.aco)),
              ),
            ),
          ],
        );
        final estado = Text(
          texto,
          style: context.sivTextos.corpo.copyWith(
            color: cor,
            fontWeight: FontWeight.w600,
          ),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cores.superficie,
            border: Border(top: BorderSide(color: cores.hairline)),
          ),
          child: compacto
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    estado,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(flex: 1, child: descartar),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: salvar),
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: estado),
                    descartar,
                    const SizedBox(width: 12),
                    SizedBox(width: 160, child: salvar),
                  ],
                ),
        );
      },
    );
  }
}

class IntegracaoInfinityPayForm extends StatefulWidget {
  final bool compacto;

  const IntegracaoInfinityPayForm({super.key, this.compacto = false});

  @override
  State<IntegracaoInfinityPayForm> createState() =>
      _IntegracaoInfinityPayFormState();
}

class _IntegracaoInfinityPayFormState extends State<IntegracaoInfinityPayForm> {
  static const _textuais = [
    CampoInfinityPay.handle,
    CampoInfinityPay.urlWebhook,
    CampoInfinityPay.urlRedirect,
    CampoInfinityPay.reservaMinutos,
    CampoInfinityPay.emailEstorno,
    CampoInfinityPay.apiKey,
    CampoInfinityPay.parcelasSemJuros,
  ];

  final _ctrl = {for (final c in _textuais) c: TextEditingController()};
  final _foco = FocusNode();
  bool _verChave = false;
  bool _copiado = false;
  Timer? _timerCopiado;

  @override
  void initState() {
    super.initState();
    _sincronizar(context.read<_Bloc>().state);
    _foco.addListener(_aoFocarChave);
  }

  @override
  void dispose() {
    _timerCopiado?.cancel();
    _foco.dispose();
    for (final c in _ctrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Ao tocar na API Key mascarada, limpa o campo para digitar uma nova;
  /// ao sair sem digitar, volta ao valor do estado.
  void _aoFocarChave() {
    final s = context.read<_Bloc>().state;
    final c = _ctrl[CampoInfinityPay.apiKey]!;
    if (_foco.hasFocus) {
      if (s.editando.apiKey == s.salvo.apiKey) c.clear();
    } else {
      c.text = s.editando.apiKey;
    }
  }

  void _sincronizar(_Estado s) {
    for (final campo in _textuais) {
      if (campo == CampoInfinityPay.apiKey && _foco.hasFocus) continue;
      final c = _ctrl[campo]!;
      final v = s.editando.valorDe(campo);
      if (c.text != v) {
        c.value = TextEditingValue(
          text: v,
          selection: TextSelection.collapsed(offset: v.length),
        );
      }
    }
  }

  void _alterou(CampoInfinityPay c, String v) =>
      context.read<_Bloc>().add(IntegracaoInfinityPayAlterou(c, v));

  Future<void> _copiar(_Estado s) async {
    final v = s.editando.urlWebhook.isEmpty
        ? s.webhookPadrao
        : s.editando.urlWebhook;
    await Clipboard.setData(ClipboardData(text: v));
    if (!mounted) return;
    setState(() => _copiado = true);
    _timerCopiado?.cancel();
    _timerCopiado = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copiado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_Bloc, _Estado>(
      listenWhen: (a, b) => a.editando != b.editando || a.salvo != b.salvo,
      listener: (context, s) => _sincronizar(s),
      builder: (context, s) {
        final t = context.sivTextos;
        final cores = context.sivColors;
        final e = s.editando;
        final erros = s.erros;
        final avisos = s.avisos;
        final espaco = widget.compacto ? 16.0 : 26.0;

        Widget secao(String titulo) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            titulo,
            style: t.rotulo.copyWith(
              color: cores.textoApoio,
              letterSpacing: 1.4,
            ),
          ),
        );

        Widget campo(
          CampoInfinityPay c,
          String label, {
          String? ajuda,
          String? prefixo,
          String? dica,
          bool habilitado = true,
          bool numerico = false,
          bool obscuro = false,
          Widget? sufixo,
        }) {
          final erro = erros[c];
          final aviso = erro == null ? avisos[c] : null;
          return TextField(
            key: Key('campo_${c.name}'),
            controller: _ctrl[c],
            focusNode: c == CampoInfinityPay.apiKey ? _foco : null,
            enabled: habilitado,
            obscureText: obscuro,
            enableSuggestions: !obscuro,
            autocorrect: false,
            keyboardType: numerico ? TextInputType.number : null,
            inputFormatters: numerico
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            onChanged: (v) => _alterou(c, v),
            decoration: InputDecoration(
              labelText: label,
              hintText: dica,
              prefixText: prefixo,
              suffixIcon: sufixo,
              errorText: erro,
              errorMaxLines: 3,
              helperText: aviso ?? ajuda,
              helperMaxLines: 3,
              helperStyle: aviso != null
                  ? t.apoio.copyWith(color: cores.parcialTexto)
                  : null,
              border: const OutlineInputBorder(),
              constraints: BoxConstraints(minHeight: widget.compacto ? 50 : 56),
            ),
          );
        }

        Widget interruptor({
          required Key chave,
          required String titulo,
          required String sub,
          required bool valor,
          required ValueChanged<bool>? onChanged,
        }) => InkWell(
          key: chave,
          onTap: onChanged == null ? null : () => onChanged(!valor),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: cores.hairline),
              borderRadius: BorderRadius.circular(4),
              color: valor ? cores.selecaoFundo : cores.superficie,
            ),
            child: Row(
              children: [
                Switch(value: valor, onChanged: onChanged),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: t.corpo.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(sub, style: t.apoio),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

        final webhook = e.urlWebhook;
        final reserva = e.reservaMinutos ?? 0;
        final semChave = !s.apiKeyPresente;
        final chaveRemovida = e.apiKey.isEmpty && s.salvo.apiKey.isNotEmpty;

        Widget botao(String rotulo, VoidCallback? onTap) => SizedBox(
          height: 44,
          child: TextButton(onPressed: onTap, child: Text(rotulo)),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.compacto) ...[
              Row(
                children: [
                  Expanded(child: Text('InfinityPay', style: t.titulo)),
                  const SeloStatusInfinityPay(),
                ],
              ),
              const SizedBox(height: 4),
              Text('Pix e cartão por link de pagamento', style: t.apoio),
              SizedBox(height: espaco),
            ],
            interruptor(
              chave: const Key('switch_habilitada'),
              titulo: 'Receber pagamentos pela InfinityPay',
              sub: e.habilitada
                  ? 'Ligada: os links de pagamento são gerados por esta conta.'
                  : 'Desligada: nenhuma cobrança é criada pela InfinityPay.',
              valor: e.habilitada,
              onChanged: (v) =>
                  _alterou(CampoInfinityPay.habilitada, v ? 'S' : 'N'),
            ),
            SizedBox(height: espaco),
            secao('CONTA'),
            const SizedBox(height: 8),
            campo(
              CampoInfinityPay.handle,
              'Handle (InfiniteTag)',
              prefixo: r'$ ',
              ajuda:
                  'Sua InfiniteTag, a identificação no canto superior esquerdo do app InfinitePay. Sem o \$.',
            ),
            SizedBox(height: espaco),
            secao('ENDEREÇOS'),
            const SizedBox(height: 8),
            campo(CampoInfinityPay.urlWebhook, 'Webhook'),
            Wrap(
              spacing: 8,
              children: [
                botao(
                  'Usar endereço padrão desta API',
                  () => context.read<_Bloc>().add(
                    IntegracaoInfinityPayUsouWebhookPadrao(),
                  ),
                ),
                botao(_copiado ? 'Copiado ✓' : 'Copiar', () => _copiar(s)),
              ],
            ),
            if (webhook.isNotEmpty &&
                erros[CampoInfinityPay.urlWebhook] == null)
              Text(
                webhook == s.webhookPadrao
                    ? '✓ Endereço padrão desta API para esta empresa.'
                    : 'Diferente do padrão. Confira se aponta para esta API.',
                style: t.apoio.copyWith(
                  color: webhook == s.webhookPadrao
                      ? cores.conferidoTexto
                      : cores.parcialTexto,
                ),
              ),
            const SizedBox(height: 16),
            campo(
              CampoInfinityPay.urlRedirect,
              'Redirecionamento após o pagamento',
              ajuda: e.urlRedirect.isEmpty
                  ? 'Vazio: o cliente fica na página da InfinityPay depois de pagar (o e-commerce manda o próprio endereço).'
                  : null,
            ),
            botao(
              'Usar o site da empresa',
              e.urlSiteEmpresa.isEmpty
                  ? null
                  : () => context.read<_Bloc>().add(
                      IntegracaoInfinityPayUsouSiteEmpresa(),
                    ),
            ),
            SizedBox(height: espaco),
            secao('OPÇÕES DO CHECKOUT'),
            const SizedBox(height: 8),
            campo(
              CampoInfinityPay.apiKey,
              'API Key',
              obscuro: !_verChave,
              dica: 'inchk_…',
              ajuda: chaveRemovida
                  ? 'Será removida ao salvar.'
                  : 'Toque para digitar uma chave nova.',
              sufixo: IconButton(
                tooltip: _verChave ? 'Ocultar' : 'Mostrar',
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                icon: Icon(_verChave ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _verChave = !_verChave),
              ),
            ),
            if (s.apiKeyPresente)
              Align(
                alignment: Alignment.centerLeft,
                child: botao(
                  'Remover chave',
                  () => _alterou(CampoInfinityPay.apiKey, ''),
                ),
              ),
            const SizedBox(height: 16),
            campo(
              CampoInfinityPay.parcelasSemJuros,
              'Parcelas sem juros',
              numerico: true,
              dica: 'Padrão da conta',
              habilitado: !semChave,
              ajuda: semChave
                  ? 'Exige a API Key'
                  : 'Até quantas parcelas a loja absorve a taxa. Não limita o número de parcelas.',
            ),
            const SizedBox(height: 16),
            interruptor(
              chave: const Key('switch_pix'),
              titulo: 'Oferecer Pix no checkout',
              sub: semChave
                  ? 'Exige a API Key'
                  : 'O cartão fica sempre ligado.',
              valor: e.pixHabilitado,
              onChanged: semChave
                  ? null
                  : (v) =>
                        _alterou(CampoInfinityPay.pixHabilitado, v ? 'S' : 'N'),
            ),
            SizedBox(height: espaco),
            secao('CHECKOUT DO E-COMMERCE'),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  key: const Key('reserva_menos'),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(Icons.remove),
                  onPressed: reserva > 1
                      ? () => _alterou(
                          CampoInfinityPay.reservaMinutos,
                          '${reserva - 1}',
                        )
                      : null,
                ),
                Expanded(
                  child: campo(
                    CampoInfinityPay.reservaMinutos,
                    'Reserva de estoque (minutos)',
                    numerico: true,
                    ajuda:
                        'Tempo que a peça fica separada enquanto o cliente paga.',
                  ),
                ),
                IconButton(
                  key: const Key('reserva_mais'),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(Icons.add),
                  onPressed: reserva < 120
                      ? () => _alterou(
                          CampoInfinityPay.reservaMinutos,
                          '${reserva + 1}',
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            campo(
              CampoInfinityPay.emailEstorno,
              'E-mail do financeiro para estornos',
              ajuda: e.emailEstorno.isEmpty
                  ? null
                  : 'Recebe o aviso quando um pagamento precisa ser estornado à mão.',
            ),
          ],
        );
      },
    );
  }
}
