import 'package:brasil_fields/brasil_fields.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/coordenadas_parser.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/domain/entities/terminal.dart';
import 'package:empresas/presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../blocs/empresa_bloc/empresa_bloc.dart';

enum _SecaoEmpresa {
  dadosPrincipais('Dados principais', Icons.apartment_rounded),
  contatoFiscal('Contato e fiscal', Icons.contact_phone_outlined),
  endereco('Endereço', Icons.location_on_outlined),
  terminais('Terminais', Icons.point_of_sale_outlined),
  parametrosDeVenda('Parâmetros de venda', Icons.tune_outlined),
  notaFiscalEmail('Nota fiscal / e-mail', Icons.mail_outline),
  configFiscal('Config. fiscal', Icons.receipt_long_outlined),
  configEntrega('Config. entrega', Icons.local_shipping_outlined);

  final String label;
  final IconData icone;
  const _SecaoEmpresa(this.label, this.icone);
}

/// Configurações da empresa: sub-navegação vertical fixa + faixa de resumo
/// no topo, substitui a rolagem única longa que existia antes. "Nota fiscal
/// / e-mail", "Config. fiscal" e "Config. entrega" continuam sendo telas
/// próprias (rotas já existentes) -- os itens de sub-nav dessas seções
/// funcionam como atalho pra elas, não duplicam o formulário aqui.
class EmpresaPage extends StatefulWidget {
  final int? idEmpresa;

  const EmpresaPage({super.key, this.idEmpresa});

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  late final EmpresaBloc _bloc;
  late final TerminaisBloc _terminaisBloc;
  final _formKey = GlobalKey<FormState>();
  _SecaoEmpresa _secao = _SecaoEmpresa.dadosPrincipais;

  @override
  void initState() {
    super.initState();
    _bloc = sl<EmpresaBloc>()
      ..add(EmpresaIniciou(idEmpresa: widget.idEmpresa));
    _terminaisBloc = sl<TerminaisBloc>();
    if (widget.idEmpresa != null) {
      _terminaisBloc.add(TerminaisIniciou(empresaId: widget.idEmpresa!));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _terminaisBloc.close();
    SivPageAcoes.limpar();
    super.dispose();
  }

  void _atualizarAcoesDaBarraDeTitulo(EmpresaState state) {
    final editando = state is EmpresaEditarEmProgresso;
    final salvando = state is EmpresaSalvarEmProgresso;

    SivPageAcoes.definir([
      if (editando)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: context.sivColors.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Text('Modo edição', style: context.sivTextos.apoio),
        ),
      const SizedBox(width: 8),
      FilledButton.icon(
        onPressed: !editando || salvando
            ? null
            : () {
                if (_formKey.currentState?.validate() ?? true) {
                  _bloc.add(EmpresaSalvou());
                }
              },
        icon: salvando
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.check, size: 18),
        label: const Text('Salvar empresa'),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<EmpresaBloc>.value(value: _bloc),
        BlocProvider<TerminaisBloc>.value(value: _terminaisBloc),
      ],
      child: BlocConsumer<EmpresaBloc, EmpresaState>(
        listenWhen: (previous, current) => true,
        listener: (context, state) {
          // Entra direto em edição assim que carrega -- a tela não tem mais
          // um modo "visualização" separado (ver indicador na barra de
          // título em vez do antigo FAB de alternância).
          if (state is EmpresaCarregarSucesso) {
            _bloc.add(EmpresaEditou());
          }
          if (state is EmpresaSalvarSucesso) {
            SivAviso.mostrar(context, mensagem: 'Empresa salva.');
          }
          _atualizarAcoesDaBarraDeTitulo(state);
        },
        buildWhen: (previous, current) =>
            previous is! EmpresaEditarEmProgresso,
        builder: (context, state) {
          if (state is EmpresaCarregarEmProgresso ||
              state is EmpresaNaoInicializada) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state is EmpresaCarregarFalha) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Não foi possível carregar a empresa.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _bloc.add(
                        EmpresaIniciou(idEmpresa: widget.idEmpresa),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _conteudo(context, state.empresa);
        },
      ),
    );
  }

  Widget _conteudo(BuildContext context, Empresa? empresa) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _faixaResumo(context, empresa),
        const SizedBox(height: SivDimensoes.gapCards),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: 212, child: _subNav(context)),
              const SizedBox(width: SivDimensoes.gapCards),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: _secaoConteudo(context, empresa),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _faixaResumo(BuildContext context, Empresa? empresa) {
    final textos = context.sivTextos;
    final cores = context.sivColors;

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cores.superficieRecuada,
                  borderRadius: BorderRadius.circular(SivDimensoes.raio),
                ),
                child: Text(
                  empresa?.id?.toString() ?? 'Nova',
                  style: textos.rotulo,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      empresa?.nome.isNotEmpty == true
                          ? empresa!.nome
                          : 'Nova empresa',
                      style: textos.titulo,
                    ),
                    Text(
                      '${empresa?.nomeFantasia.isNotEmpty == true ? empresa!.nomeFantasia : 'Sem nome fantasia'} · ${_cnpjMascarado(empresa?.cnpj)}',
                      style: textos.apoio,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: BlocBuilder<TerminaisBloc, TerminaisState>(
                  builder: (context, state) => _indicador(
                    context,
                    label: 'Terminais',
                    valor: state.terminais.isEmpty && state is! TerminaisCarregarSucesso
                        ? '—'
                        : state.terminais.length.toString(),
                  ),
                ),
              ),
              // TODO: quantidade de usuários vinculados à empresa não está
              // disponível -- não existe endpoint empresa->usuários hoje.
              Expanded(
                child: _indicador(context, label: 'Usuários', valor: '—'),
              ),
              Expanded(
                child: _indicador(
                  context,
                  label: 'Regime tributário',
                  valor: _labelRegime(empresa?.regime),
                ),
              ),
              // TODO: situação da NF-e (ambiente SEFAZ homologação/produção,
              // certificado válido etc) não está disponível na entidade
              // Empresa nem no EmpresaBloc -- falta o contrato dessa
              // informação vir de configuração fiscal.
              Expanded(
                child: _indicador(context, label: 'Situação da NF-e', valor: '—'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicador(BuildContext context, {required String label, required String valor}) {
    final textos = context.sivTextos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textos.rotulo),
        const SizedBox(height: 2),
        Text(valor, style: textos.corpo.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _labelRegime(TipoRegimeEmpresa? regime) => switch (regime) {
        TipoRegimeEmpresa.normal => 'Normal',
        TipoRegimeEmpresa.microEmpresa => 'Micro Empresa',
        TipoRegimeEmpresa.epp => 'EPP',
        TipoRegimeEmpresa.lucroReal => 'Lucro Real',
        TipoRegimeEmpresa.lucroPresumido => 'Lucro Presumido',
        TipoRegimeEmpresa.mei => 'MEI',
        TipoRegimeEmpresa.eireli => 'Eireli',
        TipoRegimeEmpresa.outros => 'Outros',
        null => '—',
      };

  String _cnpjMascarado(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) return 'CNPJ não informado';
    final digitos = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitos.length != 14) return cnpj;
    return '${digitos.substring(0, 2)}.${digitos.substring(2, 5)}.${digitos.substring(5, 8)}/'
        '${digitos.substring(8, 12)}-${digitos.substring(12, 14)}';
  }

  Widget _subNav(BuildContext context) {
    return SivCard(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final secao in _SecaoEmpresa.values)
            _itemSubNav(context, secao),
        ],
      ),
    );
  }

  Widget _itemSubNav(BuildContext context, _SecaoEmpresa secao) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final selecionado = secao == _secao;

    return InkWell(
      onTap: () => setState(() => _secao = secao),
      child: Container(
        color: selecionado ? cores.selecaoFundo : null,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              color: selecionado ? cores.aco : Colors.transparent,
            ),
            const SizedBox(width: 8),
            Icon(secao.icone, size: 18, color: selecionado ? cores.acoProfundo : cores.textoApoio),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                secao.label,
                style: textos.corpo.copyWith(
                  fontWeight: selecionado ? FontWeight.w600 : FontWeight.w400,
                  color: selecionado ? cores.textoPrincipal : cores.textoApoio,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secaoConteudo(BuildContext context, Empresa? empresa) {
    switch (_secao) {
      case _SecaoEmpresa.dadosPrincipais:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _cardDadosPrincipais(context, empresa)),
            const SizedBox(width: SivDimensoes.gapCards),
            SizedBox(
              width: 380,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cardTerminais(context, resumido: true),
                  const SizedBox(height: SivDimensoes.gapCards),
                  _cardParametrosDeVenda(context),
                ],
              ),
            ),
          ],
        );
      case _SecaoEmpresa.contatoFiscal:
        return _cardContatoFiscal(context, empresa);
      case _SecaoEmpresa.endereco:
        return _cardEndereco(context, empresa);
      case _SecaoEmpresa.terminais:
        return _cardTerminais(context, resumido: false);
      case _SecaoEmpresa.parametrosDeVenda:
        return _cardParametrosDeVenda(context);
      case _SecaoEmpresa.notaFiscalEmail:
        return _cardAtalho(
          context,
          titulo: 'Nota fiscal / e-mail',
          descricao: 'Configure o envio automático da nota fiscal por e-mail.',
          rota: '/nota_fiscal_email_empresa',
          empresa: empresa,
        );
      case _SecaoEmpresa.configFiscal:
        return _cardAtalho(
          context,
          titulo: 'Configuração fiscal',
          descricao: 'Ambiente SEFAZ, certificado digital e séries de NF-e.',
          rota: '/configuracao_fiscal',
          empresa: empresa,
        );
      case _SecaoEmpresa.configEntrega:
        return _cardAtalho(
          context,
          titulo: 'Configuração de entrega',
          descricao: 'Regras de frete e entregadores da empresa.',
          rota: '/configuracao_entrega',
          empresa: empresa,
        );
    }
  }

  Widget _cardAtalho(
    BuildContext context, {
    required String titulo,
    required String descricao,
    required String rota,
    required Empresa? empresa,
  }) {
    final habilitado = (empresa?.id ?? 0) > 0;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: context.sivTextos.secao),
          const SizedBox(height: 6),
          Text(descricao, style: context.sivTextos.apoio),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: !habilitado
                ? null
                : () => Navigator.of(context).pushNamed(
                      rota,
                      arguments: {'empresaId': empresa!.id},
                    ),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(habilitado ? 'Abrir tela' : 'Salve a empresa primeiro'),
          ),
        ],
      ),
    );
  }

  Widget _cardDadosPrincipais(BuildContext context, Empresa? empresa) {
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dados principais', style: context.sivTextos.secao),
          const SizedBox(height: 16),
          _campo(
            label: 'Nome',
            valorInicial: empresa?.nome ?? '',
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
            onChanged: (v) => _bloc.add(EmpresaEditou(nome: v)),
            fieldKey: const Key('nome_empresa_text_field'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'Código',
                  valorInicial: empresa?.id?.toString() ?? '',
                  readOnly: true,
                  fieldKey: const Key('codigo_da_empresa_text_field'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _campo(
                  label: 'Nome fantasia',
                  valorInicial: empresa?.nomeFantasia ?? '',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe um nome fantasia' : null,
                  onChanged: (v) => _bloc.add(EmpresaEditou(nomeFantasia: v)),
                  fieldKey: const Key('nome_fantasia_empresa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'CNPJ',
                  valorInicial: empresa?.cnpj ?? '',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o CNPJ' : null,
                  onChanged: (v) => _bloc.add(EmpresaEditou(cnpj: v)),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CnpjInputFormatter(),
                  ],
                  keyboardType: TextInputType.number,
                  fieldKey: const Key('cnpj_empresa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(
                  label: 'Inscrição estadual',
                  valorInicial: empresa?.inscricaoEstadual ?? '',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Informe a inscrição estadual' : null,
                  onChanged: (v) => _bloc.add(EmpresaEditou(inscricaoEstadual: v)),
                  fieldKey: const Key('inscricao_estadual_empresa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'E-mail',
                  valorInicial: empresa?.email ?? '',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o e-mail' : null,
                  onChanged: (v) => _bloc.add(EmpresaEditou(email: v)),
                  keyboardType: TextInputType.emailAddress,
                  fieldKey: const Key('email_empresa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(
                  label: 'Telefone',
                  valorInicial: empresa?.telefone ?? '',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o telefone' : null,
                  onChanged: (v) => _bloc.add(EmpresaEditou(telefone: v)),
                  keyboardType: TextInputType.phone,
                  fieldKey: const Key('telefone_empresa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _campo(
            label: 'Endereço',
            valorInicial: _enderecoResumido(empresa),
            readOnly: true,
            helperText: 'Edite pela sub-seção "Endereço".',
            fieldKey: const Key('endereco_resumo_empresa'),
          ),
        ],
      ),
    );
  }

  String _enderecoResumido(Empresa? empresa) {
    if (empresa == null) return '';
    final partes = [
      if ((empresa.logradouro ?? '').isNotEmpty) '${empresa.logradouro}, ${empresa.numero ?? 's/n'}',
      if ((empresa.bairro ?? '').isNotEmpty) empresa.bairro!,
      if ((empresa.municipio ?? '').isNotEmpty) empresa.municipio!,
      if ((empresa.uf ?? '').isNotEmpty) empresa.uf!,
    ];
    return partes.isEmpty ? 'Endereço não informado' : partes.join(' — ');
  }

  Widget _cardContatoFiscal(BuildContext context, Empresa? empresa) {
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contato e fiscal', style: context.sivTextos.secao),
          const SizedBox(height: 16),
          _campo(
            label: 'Registro municipal',
            valorInicial: empresa?.registroMunicipal ?? '',
            onChanged: (v) => _bloc.add(EmpresaEditou(registroMunicipal: v)),
            fieldKey: const Key('registro_municipal_empresa'),
          ),
          const SizedBox(height: 14),
          _campo(
            label: 'Código de atividade',
            valorInicial: empresa?.codigoDeAtividade ?? '',
            onChanged: (v) => _bloc.add(EmpresaEditou(codigoDeAtividade: v)),
            fieldKey: const Key('codigo_de_atividade_empresa'),
          ),
          const SizedBox(height: 14),
          _campo(
            label: 'Código de natureza jurídica',
            valorInicial: empresa?.codigoDeNaturezaJuridica ?? '',
            onChanged: (v) => _bloc.add(EmpresaEditou(codigoDeNaturezaJuridica: v)),
            fieldKey: const Key('codigo_de_natureza_juridica_empresa'),
          ),
          const SizedBox(height: 14),
          _dropdown<TipoRegimeEmpresa>(
            context,
            label: 'Regime tributário',
            valorInicial: empresa?.regime,
            itens: const {
              TipoRegimeEmpresa.normal: 'Normal',
              TipoRegimeEmpresa.microEmpresa: 'Micro Empresa',
              TipoRegimeEmpresa.epp: 'EPP',
              TipoRegimeEmpresa.lucroReal: 'Lucro Real',
              TipoRegimeEmpresa.lucroPresumido: 'Lucro Presumido',
              TipoRegimeEmpresa.mei: 'MEI',
              TipoRegimeEmpresa.eireli: 'Eireli',
              TipoRegimeEmpresa.outros: 'Outros',
            },
            onChanged: (v) => _bloc.add(EmpresaEditou(regime: v)),
          ),
          const SizedBox(height: 14),
          _dropdown<TipoDeSubstituicaoTributaria>(
            context,
            label: 'Substituição tributária',
            valorInicial: empresa?.substituicaoTributaria,
            itens: const {
              TipoDeSubstituicaoTributaria.calcula: 'Calcula',
              TipoDeSubstituicaoTributaria.naoCalcula: 'Não calcula',
            },
            onChanged: (v) => _bloc.add(EmpresaEditou(substituicaoTributaria: v)),
          ),
        ],
      ),
    );
  }

  Widget _cardEndereco(BuildContext context, Empresa? empresa) {
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Endereço', style: context.sivTextos.secao),
          const SizedBox(height: 4),
          Text('Usado na emissão de notas fiscais (SEFAZ).', style: context.sivTextos.apoio),
          const SizedBox(height: 16),
          _campo(
            label: 'Logradouro',
            valorInicial: empresa?.logradouro ?? '',
            onChanged: (v) => _bloc.add(EmpresaEditou(logradouro: v)),
            fieldKey: const Key('logradouro_empresa'),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'Número',
                  valorInicial: empresa?.numero ?? '',
                  onChanged: (v) => _bloc.add(EmpresaEditou(numero: v)),
                  fieldKey: const Key('numero_empresa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _campo(
                  label: 'Bairro',
                  valorInicial: empresa?.bairro ?? '',
                  onChanged: (v) => _bloc.add(EmpresaEditou(bairro: v)),
                  fieldKey: const Key('bairro_empresa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _campo(
                  label: 'Município',
                  valorInicial: empresa?.municipio ?? '',
                  onChanged: (v) => _bloc.add(EmpresaEditou(municipio: v)),
                  fieldKey: const Key('municipio_empresa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _dropdown<String>(
                  context,
                  label: 'UF',
                  valorInicial: (empresa?.uf?.isEmpty ?? true) ? null : empresa!.uf,
                  itens: {
                    for (var i = 0; i < Estados.listaEstadosSigla.length; i++)
                      Estados.listaEstadosSigla[i]:
                          '${Estados.listaEstadosSigla[i]} — ${Estados.listaEstados[i]}',
                  },
                  onChanged: (v) => _bloc.add(EmpresaEditou(uf: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _campo(
                  label: 'Código IBGE do município',
                  valorInicial: empresa?.codigoMunicipioIbge ?? '',
                  onChanged: (v) => _bloc.add(EmpresaEditou(codigoMunicipioIbge: v)),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(7),
                  ],
                  keyboardType: TextInputType.number,
                  fieldKey: const Key('codigo_municipio_ibge_empresa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(
                  label: 'CEP',
                  valorInicial: empresa?.cep ?? '',
                  onChanged: (v) => _bloc.add(EmpresaEditou(cep: v)),
                  // ponytail: sem CepInputFormatter (brasil_fields) -- conta a
                  // string já mascarada contra o limite de 8 e trava a
                  // digitação cedo demais. Backend só quer os dígitos, manda
                  // cru, sem máscara visual.
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  keyboardType: TextInputType.number,
                  fieldKey: const Key('cep_empresa'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _campo(
            label: 'Coordenadas (copie do Google Maps ou digite lat, lng)',
            valorInicial: empresa?.latitude != null && empresa?.longitude != null
                ? '${empresa!.latitude}, ${empresa.longitude}'
                : '',
            helperText: 'Ex: 2°54\'49.7"S 41°45\'15.6"W ou -2.9138, -41.7543',
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (parseCoordenadas(v) == null) {
                return 'Formato de coordenadas inválido';
              }
              return null;
            },
            onChanged: (v) {
              final coordenadas = parseCoordenadas(v);
              _bloc.add(EmpresaEditou(latitude: coordenadas?.$1, longitude: coordenadas?.$2));
            },
            fieldKey: const Key('coordenadas_empresa'),
          ),
        ],
      ),
    );
  }

  // Card de terminais: `flex: none` (SizedBox com altura do próprio
  // conteúdo) quando embutido na coluna direita de "Dados principais" --
  // nunca `Expanded`/`flex: 1` aqui, senão a última linha da tabela vaza
  // por cima do card de parâmetros abaixo.
  Widget _cardTerminais(BuildContext context, {required bool resumido}) {
    final empresaId = widget.idEmpresa;

    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Text('Terminais', style: context.sivTextos.secao)),
              IconButton(
                tooltip: 'Adicionar terminal',
                onPressed: empresaId == null
                    ? null
                    : () async {
                        final resultado = await TerminalModal.show(
                          context: context,
                          empresaId: empresaId,
                        );
                        if (resultado == true) {
                          _terminaisBloc.add(TerminaisIniciou(empresaId: empresaId));
                        }
                      },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),
          BlocBuilder<TerminaisBloc, TerminaisState>(
            builder: (context, state) {
              if (empresaId == null) {
                return Text(
                  'Salve a empresa pra gerenciar terminais.',
                  style: context.sivTextos.apoio,
                );
              }
              if (state is TerminaisCarregarEmProgresso) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator.adaptive()),
                );
              }
              if (state.terminais.isEmpty) {
                return Text('Nenhum terminal cadastrado.', style: context.sivTextos.apoio);
              }

              final terminais = resumido ? state.terminais.take(4).toList() : state.terminais;

              return SivTabela(
                colunas: const [
                  SivTabelaColuna(titulo: 'NOME', flex: 2),
                  // TODO: Terminal não tem campo de impressora vinculada
                  // hoje -- coluna mostra "-" até esse dado existir.
                  SivTabelaColuna(titulo: 'IMPRESSORA'),
                  SivTabelaColuna(titulo: 'STATUS'),
                ],
                quantidadeLinhas: terminais.length,
                linhaBuilder: (context, i) => _linhaTerminal(context, terminais[i]),
                rodape: resumido && state.terminais.length > terminais.length
                    ? '+${state.terminais.length - terminais.length} terminais'
                    : '${terminais.length} terminal(is)',
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _linhaTerminal(BuildContext context, Terminal terminal) {
    final inativo = terminal.inativo == true;
    final estilo = context.sivTextos.corpo.copyWith(
      color: inativo ? context.sivColors.textoDesabilitado : null,
    );
    return [
      Text(terminal.nome, style: estilo),
      Text('-', style: estilo),
      Text(inativo ? 'Inativo' : 'Ativo', style: estilo),
    ];
  }

  // Card com os 4 controles pedidos pro redesign. Nenhum deles tem campo
  // correspondente hoje em Empresa/EmpresaParametro -- CD_PRECO_PADRAO é o
  // parâmetro mais próximo de "tabela de preço padrão", mas monta um
  // SivComboBox exigiria a lista de tabelas de preço (fora do escopo desta
  // etapa/pacote). Fica só de UI, sem persistir, até o contrato existir.
  // TODO: exigir cliente na venda, desconto máximo do vendedor e imprimir
  // romaneio ao finalizar não têm campo no backend.
  Widget _cardParametrosDeVenda(BuildContext context) {
    return const _ParametrosDeVendaCard();
  }
}

class _ParametrosDeVendaCard extends StatefulWidget {
  const _ParametrosDeVendaCard();

  @override
  State<_ParametrosDeVendaCard> createState() => _ParametrosDeVendaCardState();
}

class _ParametrosDeVendaCardState extends State<_ParametrosDeVendaCard> {
  bool _exigirCliente = false;
  bool _imprimirRomaneio = true;
  int? _tabelaSelecionada;

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;

    return SivCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Parâmetros de venda', style: textos.secao),
          const SizedBox(height: 4),
          Text(
            'Salvos junto com a empresa quando o backend expuser esses campos.',
            style: textos.apoio,
          ),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Exigir cliente na venda'),
            value: _exigirCliente,
            onChanged: (v) => setState(() => _exigirCliente = v),
          ),
          const SizedBox(height: 4),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Desconto máximo do vendedor (%)',
              helperText: 'Acima disso, exige senha do gerente.',
              suffixText: '%',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 14),
          Text('Tabela de preço padrão', style: textos.rotulo),
          const SizedBox(height: 6),
          SivComboBox<int>(
            selecionado: _tabelaSelecionada,
            itens: const [
              SivComboBoxItem(valor: 1, label: 'Tabela padrão'),
              SivComboBoxItem(valor: 2, label: 'Tabela promocional'),
            ],
            onSelecionado: (v) => setState(() => _tabelaSelecionada = v),
          ),
          const SizedBox(height: 4),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Imprimir romaneio ao finalizar'),
            value: _imprimirRomaneio,
            onChanged: (v) => setState(() => _imprimirRomaneio = v),
          ),
        ],
      ),
    );
  }
}

Widget _campo({
  required String label,
  required String valorInicial,
  bool readOnly = false,
  FormFieldValidator<String>? validator,
  ValueChanged<String>? onChanged,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  String? helperText,
  Key? fieldKey,
}) {
  return TextFormField(
    key: fieldKey,
    readOnly: readOnly,
    controller: TextEditingController.fromValue(TextEditingValue(text: valorInicial)),
    validator: validator,
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    keyboardType: keyboardType,
    decoration: InputDecoration(labelText: label, helperText: helperText, helperMaxLines: 2),
  );
}

Widget _dropdown<T>(
  BuildContext context, {
  required String label,
  required T? valorInicial,
  required Map<T, String> itens,
  required ValueChanged<T?> onChanged,
}) {
  return DropdownButtonFormField<T>(
    initialValue: valorInicial,
    items: [
      for (final entrada in itens.entries)
        DropdownMenuItem(value: entrada.key, child: Text(entrada.value)),
    ],
    onChanged: onChanged,
    decoration: InputDecoration(labelText: label),
  );
}
