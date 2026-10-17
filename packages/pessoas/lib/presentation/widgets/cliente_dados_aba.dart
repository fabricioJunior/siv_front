import 'package:core/bloc.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/bloc/pessoa_bloc/pessoa_bloc.dart';
import 'package:pessoas/presentation/bloc/pontos_bloc/pontos_bloc.dart';

import 'cliente_abas.dart';

String _milhar(String inteiro) => inteiro.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

String _moeda(double v) {
  final partes = v.toStringAsFixed(2).split('.');
  return 'R\$ ${_milhar(partes[0])},${partes[1]}';
}

/// Linha de crédito do Resumo: saldo e, quando houver, quanto vence e em
/// quantos dias (montado em routes.dart a partir do resumo de comercial).
typedef ResumoCreditoCliente = ({double saldo, double vencem, int? dias});

String _ou(String? v) => (v?.trim().isEmpty ?? true) ? '-' : v!.trim();

/// Aba Dados (3a/3e): cards Identificação, Contato, Vínculo e Resumo.
/// Exige PessoaBloc, PontosBloc e EnderecosBloc acima na árvore.
class ClienteDadosAba extends StatelessWidget {
  final bool mobile;
  final Future<ResumoCreditoCliente>? saldoCredito;
  final Future<String?>? ultimaCompra;
  final ValueChanged<ClienteAba> aoAbrirAba;

  const ClienteDadosAba({
    super.key,
    required this.mobile,
    required this.aoAbrirAba,
    this.saldoCredito,
    this.ultimaCompra,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PessoaBloc>().state;
    final pj = state.tipoPessoa == TipoPessoa.juridica;
    final vinculo = [
      if (state.eCliente ?? false) 'Cliente',
      if (state.eFornecedor ?? false) 'Fornecedor',
      if (state.eFuncionario ?? false) 'Funcionário',
    ].join(', ');

    final cartoes = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Cartao('IDENTIFICAÇÃO', [
          _campo('Nome', _ou(state.nome)),
          _campo(pj ? 'CNPJ' : 'CPF', _ou(formatarDocumento(state.documento))),
          if (!pj) _campo('Nascimento', formatarData(state.dataDeNascimento)),
          _campo('Tipo', pj ? 'Pessoa jurídica' : 'Pessoa física'),
          if (pj) _campo('Inscrição estadual', _ou(state.inscricaoEstadual)),
          _campo('Código', '#${state.id ?? '-'}'),
        ]),
        const SizedBox(height: 16),
        _Cartao('CONTATO', [
          _campo('Contato', _ou(state.contato)),
          _campo('E-mail', _ou(state.email)),
          _campo('UF', _ou(state.uf)),
        ]),
        const SizedBox(height: 16),
        _Cartao('VÍNCULO', [
          _campo('Vínculo', vinculo.isEmpty ? '-' : vinculo),
        ]),
      ],
    );
    final resumo = _Resumo(
      saldoCredito: saldoCredito,
      ultimaCompra: ultimaCompra,
      aoAbrirAba: aoAbrirAba,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 16 : SivDimensoes.paddingBarraTituloHorizontal,
        vertical: mobile ? 16 : 24,
      ),
      child: mobile
          ? Column(children: [resumo, const SizedBox(height: 16), cartoes])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cartoes),
                const SizedBox(width: 20),
                SizedBox(width: 340, child: resumo),
              ],
            ),
    );
  }
}

Widget _campo(String rotulo, String valor) => Builder(
      builder: (context) => SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: context.sivTextos.apoio
                  .copyWith(color: context.sivColors.textoApoio),
            ),
            Text(valor, style: context.sivTextos.corpo),
          ],
        ),
      ),
    );

Widget _moldura(BuildContext context, Widget child) => Stack(
      children: [
        SivCard(padding: EdgeInsets.zero, child: child),
        ...sivCantosBlueprint(context.sivColors.aco.withValues(alpha: 0.4)),
      ],
    );

class _Cartao extends StatelessWidget {
  final String titulo;
  final List<Widget> campos;

  const _Cartao(this.titulo, this.campos);

  @override
  Widget build(BuildContext context) => _moldura(
        context,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: context.sivTextos.rotulo
                    .copyWith(color: context.sivColors.textoApoio),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: Wrap(spacing: 24, runSpacing: 16, children: campos),
              ),
            ],
          ),
        ),
      );
}

class _Resumo extends StatelessWidget {
  final Future<ResumoCreditoCliente>? saldoCredito;
  final Future<String?>? ultimaCompra;
  final ValueChanged<ClienteAba> aoAbrirAba;

  const _Resumo({
    required this.saldoCredito,
    required this.ultimaCompra,
    required this.aoAbrirAba,
  });

  @override
  Widget build(BuildContext context) {
    final pontos = context.watch<PontosBloc>().state.totalDePontos;
    final enderecos = context.watch<EnderecosBloc>().state.enderecos;
    final principal = enderecos.where((e) => e.principal).firstOrNull;

    return _moldura(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Text(
              'RESUMO',
              style: context.sivTextos.rotulo
                  .copyWith(color: context.sivColors.textoApoio),
            ),
          ),
          if (saldoCredito != null)
            FutureBuilder<ResumoCreditoCliente>(
              future: saldoCredito,
              builder: (_, s) {
                final r = s.data;
                final vence = r != null && r.vencem > 0 && r.dias != null
                    ? '${_moeda(r.vencem)} vencem em '
                        '${r.dias} ${r.dias == 1 ? 'dia' : 'dias'}'
                    : null;
                return _Linha(
                  'Crédito de devolução',
                  r == null ? '-' : _moeda(r.saldo),
                  () => aoAbrirAba(ClienteAba.credito),
                  aviso: vence,
                );
              },
            ),
          _Linha(
            'Pontos',
            '${_milhar(pontos.toStringAsFixed(0))} pts',
            () => aoAbrirAba(ClienteAba.pontos),
          ),
          if (ultimaCompra != null)
            FutureBuilder<String?>(
              future: ultimaCompra,
              builder: (_, s) => _Linha(
                'Última compra',
                s.data ?? '-',
                () => aoAbrirAba(ClienteAba.compras),
              ),
            ),
          _Linha(
            'Endereço principal',
            principal == null
                ? '-'
                : '${principal.logradouro}, ${principal.numero} · ${principal.bairro}',
            () => aoAbrirAba(ClienteAba.enderecos),
            grande: false,
          ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  final String rotulo;
  final String valor;
  final VoidCallback aoPressionar;
  final bool grande;
  final String? aviso;

  const _Linha(this.rotulo, this.valor, this.aoPressionar,
      {this.grande = true, this.aviso});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return InkWell(
      onTap: aoPressionar,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: cores.hairline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rotulo,
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
                  Text(
                    valor,
                    style: grande
                        ? textos.secao.copyWith(fontSize: 19)
                        : textos.corpo,
                  ),
                  if (aviso != null)
                    Text(
                      aviso!,
                      style: textos.apoio.copyWith(color: cores.atencao),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: cores.textoApoio),
          ],
        ),
      ),
    );
  }
}
