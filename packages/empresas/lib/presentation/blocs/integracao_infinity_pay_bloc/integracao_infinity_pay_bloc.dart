import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa_parametro.dart';
import 'package:empresas/domain/entities/integracao_infinity_pay.dart';
import 'package:empresas/use_cases.dart';

part 'integracao_infinity_pay_event.dart';
part 'integracao_infinity_pay_state.dart';

class IntegracaoInfinityPayBloc
    extends Bloc<IntegracaoInfinityPayEvent, IntegracaoInfinityPayState> {
  final RecuperarParametrosEmpresa recuperarParametros;
  final AtualizarParametrosEmpresa atualizarParametros;
  final String urlBase;

  List<EmpresaParametro> _parametros = const [];

  IntegracaoInfinityPayBloc(
    this.recuperarParametros,
    this.atualizarParametros,
    this.urlBase,
  ) : super(const IntegracaoInfinityPayState()) {
    on<IntegracaoInfinityPayIniciou>(_onIniciou);
    on<IntegracaoInfinityPayAlterou>(
      (e, emit) => _alterar(emit, e.campo, e.valor),
    );
    on<IntegracaoInfinityPayUsouWebhookPadrao>(
      (e, emit) =>
          _alterar(emit, CampoInfinityPay.urlWebhook, state.webhookPadrao),
    );
    on<IntegracaoInfinityPayUsouSiteEmpresa>(
      (e, emit) => _alterar(
        emit,
        CampoInfinityPay.urlRedirect,
        state.editando.urlSiteEmpresa,
      ),
    );
    on<IntegracaoInfinityPayDescartou>(
      (e, emit) => emit(
        state.copyWith(
          editando: state.salvo,
          errosServidor: const {},
          salvou: false,
          mensagem: null,
        ),
      ),
    );
    on<IntegracaoInfinityPaySalvou>(_onSalvou);
  }

  /// `{urlBase}/v1/pagamentos-avulsos/webhook/infinitypay?empresaId={id}`.
  /// A API publica sob o prefixo global `v1`; `urlBase` normalmente não o
  /// inclui (os data sources somam `/v1/...`), mas se vier, não duplica.
  static String montarWebhookPadrao(String urlBase, int empresaId) {
    final base = urlBase
        .trim()
        .replaceAll(RegExp(r'/+$'), '')
        .replaceFirst(RegExp(r'/v1$'), '');
    return '$base/v1/pagamentos-avulsos/webhook/infinitypay?empresaId=$empresaId';
  }

  FutureOr<void> _onIniciou(
    IntegracaoInfinityPayIniciou event,
    Emitter<IntegracaoInfinityPayState> emit,
  ) async {
    emit(
      IntegracaoInfinityPayState(
        etapa: EtapaInfinityPay.carregando,
        empresaId: event.empresaId,
        webhookPadrao: montarWebhookPadrao(urlBase, event.empresaId),
      ),
    );
    try {
      // A API devolve List<EmpresaParametroDto> em execução; copiar para
      // List<EmpresaParametro> evita o erro de tipo no orElse de _paraEnviar.
      _parametros = List<EmpresaParametro>.of(
        await recuperarParametros.call(event.empresaId),
      );
      final c = IntegracaoInfinityPay.fromParametros(_parametros);
      emit(
        state.copyWith(etapa: EtapaInfinityPay.pronto, salvo: c, editando: c),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          etapa: EtapaInfinityPay.falha,
          mensagem: 'Falha ao carregar integrações de pagamento.',
        ),
      );
    }
  }

  void _alterar(
    Emitter<IntegracaoInfinityPayState> emit,
    CampoInfinityPay campo,
    String valor,
  ) {
    if (state.etapa != EtapaInfinityPay.pronto) return;
    emit(
      state.copyWith(
        editando: state.editando.comValor(campo, valor),
        errosServidor: {...state.errosServidor}..remove(campo),
        salvou: false,
      ),
    );
  }

  EmpresaParametro _paraEnviar(int empresaId, CampoInfinityPay c, String v) {
    final base = _parametros.firstWhere(
      (p) => p.chave == c.chave,
      orElse: () => EmpresaParametro.create(
        id: 0,
        empresaId: empresaId,
        chave: c.chave,
        descricao: '',
        tipo: ehParametroBooleanoPorChave(c.chave)
            ? TipoEmpresaParametro.checkbox
            : TipoEmpresaParametro.texto,
        descontinuado: false,
      ),
    );
    return base.ehCheckbox
        ? base.copyWith(valorBooleano: v == 'S')
        : base.copyWith(valorTexto: v);
  }

  FutureOr<void> _onSalvou(
    IntegracaoInfinityPaySalvou event,
    Emitter<IntegracaoInfinityPayState> emit,
  ) async {
    final empresaId = state.empresaId;
    if (empresaId == null || !state.podeSalvar) return;

    final editando = state.editando;
    // Nunca enviar a API Key mascarada.
    final alvo = [
      for (final c in state.sujos)
        if (!(c == CampoInfinityPay.apiKey && editando.apiKey.contains('•'))) c,
    ];
    emit(
      state.copyWith(
        etapa: EtapaInfinityPay.salvando,
        errosServidor: const {},
        salvou: false,
        mensagem: null,
      ),
    );

    final falhas = <CampoInfinityPay, String>{};
    List<EmpresaParametro>? ultima;
    for (final c in alvo) {
      try {
        ultima = await atualizarParametros.call(
          empresaId: empresaId,
          parametros: [_paraEnviar(empresaId, c, editando.valorDe(c))],
        );
      } catch (e, s) {
        addError(e, s);
        falhas[c] = _mensagemDe(e);
      }
    }

    if (ultima != null) _parametros = List<EmpresaParametro>.of(ultima);
    final novoSalvo = ultima == null
        ? state.salvo
        : IntegracaoInfinityPay.fromParametros(ultima);
    // Campos que falharam mantêm o que o usuário digitou.
    var novoEditando = novoSalvo;
    for (final c in falhas.keys) {
      novoEditando = novoEditando.comValor(c, editando.valorDe(c));
    }
    emit(
      state.copyWith(
        etapa: EtapaInfinityPay.pronto,
        salvo: novoSalvo,
        editando: novoEditando,
        errosServidor: falhas,
        salvou: falhas.isEmpty,
        mensagem: null,
      ),
    );
  }

  String _mensagemDe(Object e) {
    final t = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
    return t.isEmpty ? 'Não foi possível salvar este campo.' : t;
  }
}
