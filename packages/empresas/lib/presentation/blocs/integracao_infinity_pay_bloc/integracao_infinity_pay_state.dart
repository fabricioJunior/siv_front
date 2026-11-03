part of 'integracao_infinity_pay_bloc.dart';

enum EtapaInfinityPay { carregando, pronto, salvando, falha }

enum StatusInfinityPay { ativa, incompleta, desligada }

final _reHandle = RegExp(r'^[A-Za-z0-9_.-]+$');
final _reEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class IntegracaoInfinityPayState extends Equatable {
  final EtapaInfinityPay etapa;
  final int? empresaId;
  final IntegracaoInfinityPay salvo;
  final IntegracaoInfinityPay editando;
  final String webhookPadrao;

  /// Mensagens devolvidas pelo servidor para campos que falharam ao salvar.
  final Map<CampoInfinityPay, String> errosServidor;

  /// true logo após salvar tudo com sucesso; some na próxima edição.
  final bool salvou;
  final String? mensagem;

  const IntegracaoInfinityPayState({
    this.etapa = EtapaInfinityPay.carregando,
    this.empresaId,
    this.salvo = const IntegracaoInfinityPay(),
    this.editando = const IntegracaoInfinityPay(),
    this.webhookPadrao = '',
    this.errosServidor = const {},
    this.salvou = false,
    this.mensagem,
  });

  bool get apiKeyPresente => editando.apiKey.isNotEmpty;

  Set<CampoInfinityPay> get sujos => {
    for (final c in CampoInfinityPay.values)
      if (editando.valorDe(c) != salvo.valorDe(c)) c,
  };

  StatusInfinityPay get status => !editando.habilitada
      ? StatusInfinityPay.desligada
      : editando.handleValido
      ? StatusInfinityPay.ativa
      : StatusInfinityPay.incompleta;

  Map<CampoInfinityPay, String> get erros {
    final e = editando;
    final m = <CampoInfinityPay, String>{};
    if (e.handle.isEmpty) {
      if (e.habilitada) {
        m[CampoInfinityPay.handle] = 'Obrigatório para ligar a integração.';
      }
    } else if (!_reHandle.hasMatch(e.handle)) {
      m[CampoInfinityPay.handle] =
          'Use só letras, números, ponto, hífen ou sublinhado, sem espaços.';
    }
    for (final c in [
      CampoInfinityPay.urlWebhook,
      CampoInfinityPay.urlRedirect,
    ]) {
      final v = e.valorDe(c);
      if (v.isNotEmpty && !_urlHttpsValida(v)) {
        m[c] = 'Use um endereço completo começando com https://';
      }
    }
    if (e.emailEstorno.isNotEmpty && !_reEmail.hasMatch(e.emailEstorno)) {
      m[CampoInfinityPay.emailEstorno] = 'Informe um e-mail válido.';
    }
    final p = e.parcelasSemJuros;
    if (p != null && (p < 0 || p > 12)) {
      m[CampoInfinityPay.parcelasSemJuros] = 'Entre 0 e 12.';
    }
    if (sujos.contains(CampoInfinityPay.apiKey) &&
        e.apiKey.isNotEmpty &&
        !e.apiKey.startsWith('inchk_')) {
      m[CampoInfinityPay.apiKey] = 'A API Key começa com inchk_.';
    }
    return {...m, ...errosServidor};
  }

  Map<CampoInfinityPay, String> get avisos => {
    if (editando.habilitada && editando.urlWebhook.isEmpty)
      CampoInfinityPay.urlWebhook:
          'Sem webhook, o pagamento só é confirmado quando alguém sincroniza o pagamento manualmente.',
    if (editando.emailEstorno.isEmpty)
      CampoInfinityPay.emailEstorno:
          'A InfinityPay não estorna sozinha. Sem e-mail, o conflito de estoque fica só na lista de pendentes de estorno.',
  };

  bool get podeSalvar =>
      etapa == EtapaInfinityPay.pronto && sujos.isNotEmpty && erros.isEmpty;

  static bool _urlHttpsValida(String v) {
    final u = Uri.tryParse(v);
    return v.startsWith('https://') && u != null && u.host.isNotEmpty;
  }

  IntegracaoInfinityPayState copyWith({
    EtapaInfinityPay? etapa,
    int? empresaId,
    IntegracaoInfinityPay? salvo,
    IntegracaoInfinityPay? editando,
    String? webhookPadrao,
    Map<CampoInfinityPay, String>? errosServidor,
    bool? salvou,
    Object? mensagem = _sentinela,
  }) => IntegracaoInfinityPayState(
    etapa: etapa ?? this.etapa,
    empresaId: empresaId ?? this.empresaId,
    salvo: salvo ?? this.salvo,
    editando: editando ?? this.editando,
    webhookPadrao: webhookPadrao ?? this.webhookPadrao,
    errosServidor: errosServidor ?? this.errosServidor,
    salvou: salvou ?? this.salvou,
    mensagem: identical(mensagem, _sentinela)
        ? this.mensagem
        : mensagem as String?,
  );

  @override
  List<Object?> get props => [
    etapa,
    empresaId,
    salvo,
    editando,
    webhookPadrao,
    errosServidor,
    salvou,
    mensagem,
  ];
}

const Object _sentinela = Object();
