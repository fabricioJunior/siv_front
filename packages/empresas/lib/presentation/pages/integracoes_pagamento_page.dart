import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/presentation/blocs/integracao_infinity_pay_bloc/integracao_infinity_pay_bloc.dart';
import 'package:empresas/presentation/pages/integracao_infinity_pay_page.dart';
import 'package:flutter/material.dart';

typedef _Bloc = IntegracaoInfinityPayBloc;
typedef _Estado = IntegracaoInfinityPayState;

const _larguraDesktop = 900.0;

class IntegracoesPagamentoPage extends StatelessWidget {
  final int idEmpresa;

  const IntegracoesPagamentoPage({super.key, required this.idEmpresa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<_Bloc>(
      create: (_) => sl<_Bloc>()..add(IntegracaoInfinityPayIniciou(idEmpresa)),
      child: const IntegracoesPagamentoView(),
    );
  }
}

/// Shell: lista de gateways (mobile 1b) ou 3 colunas (desktop 1a).
/// Exige o bloc no contexto.
class IntegracoesPagamentoView extends StatelessWidget {
  const IntegracoesPagamentoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ProtegeSaidaInfinityPay(
      child: Scaffold(
        appBar: AppBar(title: const Text('Empresa / Integrações de pagamento')),
        body: BlocBuilder<_Bloc, _Estado>(
          buildWhen: (a, b) =>
              _grupo(a) != _grupo(b) || a.mensagem != b.mensagem,
          builder: (context, s) {
            if (s.etapa == EtapaInfinityPay.carregando) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (s.etapa == EtapaInfinityPay.falha) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(s.mensagem ?? 'Falha ao carregar.'),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => context.read<_Bloc>().add(
                        IntegracaoInfinityPayIniciou(s.empresaId!),
                      ),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, c) => c.maxWidth >= _larguraDesktop
                  ? const _Desktop()
                  : const _ListaMobile(),
            );
          },
        ),
      ),
    );
  }
}

EtapaInfinityPay _grupo(_Estado s) =>
    s.etapa == EtapaInfinityPay.salvando ? EtapaInfinityPay.pronto : s.etapa;

void _avisoEmBreve(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Em breve nesta tela. Use Parâmetros da empresa.'),
      ),
    );

class _Gateways extends StatelessWidget {
  final bool desktop;

  const _Gateways({required this.desktop});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final t = context.sivTextos;
    return BlocBuilder<_Bloc, _Estado>(
      builder: (context, s) {
        final salvo = s.salvo;
        final e = s.editando;
        final subInfinity = e.handle.isEmpty
            ? (e.habilitada ? 'Falta o handle' : 'Não configurada')
            : '\$${e.handle} · ${e.urlWebhook.isEmpty ? 'sem webhook' : 'webhook ok'}';

        Widget tile({
          required String nome,
          required String sub,
          required Widget selo,
          required VoidCallback onTap,
          bool selecionado = false,
        }) => InkWell(
          key: Key('gateway_$nome'),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cores.superficie,
              border: Border.all(
                color: selecionado ? cores.aco : cores.hairline,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nome, style: t.secao),
                      Text(sub, style: t.apoio),
                    ],
                  ),
                ),
                selo,
                if (!desktop) const Icon(Icons.chevron_right),
              ],
            ),
          ),
        );

        SeloStatus seloSimples(bool ativo) => SeloStatus(
          texto: ativo ? 'ATIVA' : 'DESLIGADA',
          tipo: ativo ? TipoSelo.ok : TipoSelo.neutro,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (desktop) ...[
              Text(
                'GATEWAYS',
                style: t.rotulo.copyWith(
                  color: cores.textoApoio,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 10),
            ],
            tile(
              nome: 'InfinityPay',
              sub: desktop ? 'Pix e cartão por link de pagamento' : subInfinity,
              selo: const SeloStatusInfinityPay(),
              selecionado: desktop,
              onTap: () {
                if (desktop) return;
                final bloc = context.read<_Bloc>();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: const IntegracaoInfinityPayPage(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            tile(
              nome: 'Mercado Pago',
              sub: 'Pix e cartão',
              selo: seloSimples(salvo.mercadoPagoHabilitado),
              onTap: () => _avisoEmBreve(context),
            ),
            const SizedBox(height: 10),
            tile(
              nome: 'OpenPix',
              sub: 'Pix',
              selo: seloSimples(salvo.openPixHabilitado),
              onTap: () => _avisoEmBreve(context),
            ),
          ],
        );
      },
    );
  }
}

class _ListaMobile extends StatelessWidget {
  const _ListaMobile();

  @override
  Widget build(BuildContext context) => const SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: _Gateways(desktop: false),
  );
}

class _Desktop extends StatelessWidget {
  const _Desktop();

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 28, 34, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 280, child: _Gateways(desktop: true)),
          const SizedBox(width: 28),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cores.superficie,
                border: Border.all(color: cores.hairline),
              ),
              child: const Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 24,
                      ),
                      child: IntegracaoInfinityPayForm(),
                    ),
                  ),
                  IntegracaoInfinityPayRodape(compacto: false),
                ],
              ),
            ),
          ),
          const SizedBox(width: 28),
          const SizedBox(
            width: 300,
            child: SingleChildScrollView(child: _Checklist()),
          ),
        ],
      ),
    );
  }
}

enum _Item { ok, aviso, neutro }

class _Checklist extends StatelessWidget {
  const _Checklist();

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final t = context.sivTextos;
    return BlocBuilder<_Bloc, _Estado>(
      builder: (context, s) {
        final e = s.editando;

        Widget linha(String chave, String texto, _Item item) {
          final (icone, cor) = switch (item) {
            _Item.ok => (Icons.check_circle, cores.conferidoTexto),
            _Item.aviso => (Icons.error_outline, cores.parcialTexto),
            _Item.neutro => (Icons.radio_button_unchecked, cores.textoApoio),
          };
          return Padding(
            key: Key('check_$chave'),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Icon(icone, size: 20, color: cor),
                const SizedBox(width: 10),
                Expanded(child: Text(texto, style: t.corpo)),
              ],
            ),
          );
        }

        _Item ok(bool cond, {bool avisaSeFalta = true}) =>
            cond ? _Item.ok : (avisaSeFalta ? _Item.aviso : _Item.neutro);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SivCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pronto para receber?', style: t.secao),
                  const SizedBox(height: 8),
                  linha(
                    'ligada',
                    'Integração ligada',
                    ok(e.habilitada, avisaSeFalta: false),
                  ),
                  linha(
                    'handle',
                    'Handle preenchido',
                    ok(e.handleValido, avisaSeFalta: e.habilitada),
                  ),
                  linha(
                    'webhook',
                    'Webhook configurado',
                    ok(e.urlWebhook.isNotEmpty, avisaSeFalta: e.habilitada),
                  ),
                  linha(
                    'email',
                    'E-mail para estornos',
                    ok(e.emailEstorno.isNotEmpty),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SivCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Onde achar o handle', style: t.secao),
                  const SizedBox(height: 8),
                  Text(
                    'Abra o app InfinitePay. Sua InfiniteTag aparece no canto superior esquerdo. Digite sem o \$.',
                    style: t.apoio,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
