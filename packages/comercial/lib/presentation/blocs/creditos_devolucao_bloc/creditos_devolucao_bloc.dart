import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';
import 'package:core/sessao.dart';
import 'package:empresas/models.dart';
import 'package:empresas/use_cases.dart';

part 'creditos_devolucao_event.dart';
part 'creditos_devolucao_state.dart';

class CreditosDevolucaoBloc
    extends Bloc<CreditosDevolucaoEvent, CreditosDevolucaoState> {
  final BuscarCreditosDevolucao _buscarCreditos;
  final BuscarResumoCreditoDevolucao _buscarResumo;
  final BuscarCreditoDevolucaoMovimentacoes _buscarExtrato;
  final AdicionarCreditoAvulso _adicionar;
  final RemoverCreditoDevolucao _remover;
  final ExpirarCreditoDevolucao _expirar;
  final RecuperarConfigCreditoDevolucao _recuperarConfig;
  final RecuperarEmpresas _recuperarEmpresas;
  final IAcessoGlobalSessao _sessao;
  int _pessoaId = 0;

  CreditosDevolucaoBloc(
    this._buscarCreditos,
    this._buscarResumo,
    this._buscarExtrato,
    this._adicionar,
    this._remover,
    this._expirar,
    this._recuperarConfig,
    this._recuperarEmpresas,
    this._sessao,
  ) : super(const CreditosDevolucaoState()) {
    on<CreditosDevolucaoCarregou>(_onCarregou);
    on<CreditosDevolucaoAdicionou>(
      (e, emit) => _acao(
        emit,
        () => _adicionar(
          pessoaId: _pessoaId,
          valor: e.valor,
          motivo: e.motivo,
          observacao: e.observacao,
          validade: e.validade,
          empresaId: e.empresaId,
        ),
        'Falha ao adicionar o crédito.',
      ),
    );
    on<CreditosDevolucaoRemoveu>(
      (e, emit) => _acao(
        emit,
        () => _remover(
          pessoaId: _pessoaId,
          creditoId: e.creditoId,
          valor: e.valor,
          motivo: e.motivo,
          observacao: e.observacao,
        ),
        'Falha ao remover o crédito.',
      ),
    );
    on<CreditosDevolucaoExpirou>(
      (e, emit) => _acao(
        emit,
        () => _expirar(
          pessoaId: _pessoaId,
          creditoId: e.creditoId,
          motivo: e.motivo,
        ),
        'Falha ao expirar o crédito.',
      ),
    );
  }

  /// Lista, resumo e extrato; config e empresas são opcionais (falha = padrões).
  Future<CreditosDevolucaoState> _carregar(CreditosDevolucaoState base) async {
    final empresaId = _sessao.empresaIdDaSessao;
    final dados = await (
      _buscarCreditos(pessoaId: _pessoaId),
      _buscarResumo(pessoaId: _pessoaId),
      _buscarExtrato(pessoaId: _pessoaId),
    ).wait;
    ConfigCreditoDevolucao? config = base.config;
    var empresas = base.empresas;
    if (empresaId != null && config == null) {
      config = await _recuperarConfig(empresaId).then<ConfigCreditoDevolucao?>(
        (c) => c,
        onError: (_) => null,
      );
      empresas = await _recuperarEmpresas().then<List<Empresa>>(
        (l) => l,
        onError: (_) => const <Empresa>[],
      );
    }
    return base.copyWith(
      status: CreditosDevolucaoStatus.pronto,
      creditos: dados.$1,
      resumo: dados.$2,
      extrato: dados.$3,
      config: config,
      empresas: empresas,
      empresaIdSessao: empresaId,
    );
  }

  Future<void> _onCarregou(
    CreditosDevolucaoCarregou e,
    Emitter<CreditosDevolucaoState> emit,
  ) async {
    _pessoaId = e.pessoaId;
    final recarga = state.status == CreditosDevolucaoStatus.pronto;
    emit(recarga
        ? state.copyWith(executando: true, limparErroAcao: true)
        : state.copyWith(status: CreditosDevolucaoStatus.carregando));
    try {
      emit((await _carregar(state)).copyWith(executando: false));
    } catch (err) {
      final msg =
          mensagemDeErroApi(err, 'Falha ao carregar o crédito de devolução.');
      emit(recarga
          ? state.copyWith(executando: false, erroAcao: msg)
          : state.copyWith(status: CreditosDevolucaoStatus.erro, erro: msg));
    }
  }

  /// Executa a ação e recarrega lista, resumo e extrato; `executando` só cai
  /// no fim, para a tela esperar o resultado (erro ou saldo novo).
  Future<void> _acao(
    Emitter<CreditosDevolucaoState> emit,
    Future<ResultadoAcaoCredito> Function() acao,
    String falha,
  ) async {
    emit(state.copyWith(executando: true, limparErroAcao: true));
    try {
      final r = await acao();
      var novo = state;
      try {
        novo = await _carregar(state);
      } catch (_) {}
      emit(novo.copyWith(
        executando: false,
        saldoAposAcao: r.saldoDisponivel,
        acoesConcluidas: state.acoesConcluidas + 1,
      ));
    } catch (err) {
      emit(state.copyWith(
        executando: false,
        erroAcao: mensagemDeErroApi(err, falha),
      ));
    }
  }
}
