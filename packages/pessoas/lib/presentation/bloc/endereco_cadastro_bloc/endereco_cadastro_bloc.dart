import 'package:core/cep.dart';
import 'package:pessoas/models.dart';
import 'package:core/bloc.dart';

part 'endereco_cadastro_event.dart';
part 'endereco_cadastro_state.dart';

class EnderecoCadastroBloc
    extends Bloc<EnderecoCadastroEvent, EnderecoCadastroState> {
  final CepService _cepService;

  EnderecoCadastroBloc({
    required CepService cepService,
  })  : _cepService = cepService,
        super(EnderecoCadastroInicial()) {
    on<EnderecoCadastroIniciou>(_onIniciou);
    on<EnderecoCadastroCepDigitado>(_onCepDigitado);
    on<EnderecoCadastroBuscarCep>(_onBuscarCep);
    on<EnderecoCadastroPreencherManualmente>(_onPreencherManualmente);
    on<EnderecoCadastroLogradouroAlterado>(_onLogradouroAlterado);
    on<EnderecoCadastroNumeroAlterado>(_onNumeroAlterado);
    on<EnderecoCadastroComplementoAlterado>(_onComplementoAlterado);
    on<EnderecoCadastroBairroAlterado>(_onBairroAlterado);
    on<EnderecoCadastroAvancarParaUf>(_onAvancarParaUf);
    on<EnderecoCadastroUfAlterada>(_onUfAlterada);
    on<EnderecoCadastroAvancarParaMunicipio>(_onAvancarParaMunicipio);
    on<EnderecoCadastroMunicipioAlterado>(_onMunicipioAlterado);
    on<EnderecoCadastroAvancarParaTipo>(_onAvancarParaTipo);
    on<EnderecoCadastroTipoAlterado>(_onTipoAlterado);
    on<EnderecoCadastroPrincipalAlterado>(_onPrincipalAlterado);
    on<EnderecoCadastroAvancarParaConfirmacao>(_onAvancarParaConfirmacao);
    on<EnderecoCadastroVoltarEtapa>(_onVoltarEtapa);
    on<EnderecoCadastroConfirmar>(_onConfirmar);
    on<EnderecoCadastroCancelar>(_onCancelar);
  }

  void _onIniciou(
    EnderecoCadastroIniciou event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(EnderecoCadastroInicial());
  }

  void _onCepDigitado(
    EnderecoCadastroCepDigitado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(cep: event.cep));
  }

  Future<void> _onBuscarCep(
    EnderecoCadastroBuscarCep event,
    Emitter<EnderecoCadastroState> emit,
  ) async {
    if (state.cep == null || state.cep!.isEmpty) {
      emit(EnderecoCadastroErroCep(
        mensagem: 'Digite um CEP válido',
        cep: '',
      ));
      return;
    }

    emit(EnderecoCadastroBuscandoCep(cep: state.cep!));

    try {
      final enderecoCep = await _cepService.recuperaEnderecoPeloCep(state.cep!);

      emit(state.copyWith(
        etapa: EtapaCadastroEndereco.dadosBasicos,
        logradouro: enderecoCep.logradouro,
        bairro: enderecoCep.bairro,
        uf: enderecoCep.uf,
        municipio: enderecoCep.localidade,
        preenchimentoManual: false,
      ));
    } catch (e) {
      emit(EnderecoCadastroErroCep(
        mensagem: 'CEP não encontrado. Preencha manualmente.',
        cep: state.cep!,
      ));
    }
  }

  void _onPreencherManualmente(
    EnderecoCadastroPreencherManualmente event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(
      etapa: EtapaCadastroEndereco.dadosBasicos,
      preenchimentoManual: true,
    ));
  }

  void _onLogradouroAlterado(
    EnderecoCadastroLogradouroAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(logradouro: event.logradouro));
  }

  void _onNumeroAlterado(
    EnderecoCadastroNumeroAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(numero: event.numero));
  }

  void _onComplementoAlterado(
    EnderecoCadastroComplementoAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(complemento: event.complemento));
  }

  void _onBairroAlterado(
    EnderecoCadastroBairroAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(bairro: event.bairro));
  }

  void _onAvancarParaUf(
    EnderecoCadastroAvancarParaUf event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    // Se veio do CEP, já tem UF preenchida, pula direto para tipo
    if (state.uf != null &&
        state.uf!.isNotEmpty &&
        !state.preenchimentoManual) {
      emit(state.copyWith(etapa: EtapaCadastroEndereco.tipo));
    } else {
      emit(state.copyWith(etapa: EtapaCadastroEndereco.uf));
    }
  }

  void _onUfAlterada(
    EnderecoCadastroUfAlterada event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(uf: event.uf));
  }

  void _onAvancarParaMunicipio(
    EnderecoCadastroAvancarParaMunicipio event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(etapa: EtapaCadastroEndereco.municipio));
  }

  void _onMunicipioAlterado(
    EnderecoCadastroMunicipioAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(municipio: event.municipio));
  }

  void _onAvancarParaTipo(
    EnderecoCadastroAvancarParaTipo event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(etapa: EtapaCadastroEndereco.tipo));
  }

  void _onTipoAlterado(
    EnderecoCadastroTipoAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(tipo: event.tipo));
  }

  void _onPrincipalAlterado(
    EnderecoCadastroPrincipalAlterado event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(principal: event.principal));
  }

  void _onAvancarParaConfirmacao(
    EnderecoCadastroAvancarParaConfirmacao event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(state.copyWith(etapa: EtapaCadastroEndereco.confirmacao));
  }

  void _onVoltarEtapa(
    EnderecoCadastroVoltarEtapa event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    switch (state.etapa) {
      case EtapaCadastroEndereco.cep:
        // Já está na primeira etapa
        break;
      case EtapaCadastroEndereco.dadosBasicos:
        emit(state.copyWith(etapa: EtapaCadastroEndereco.cep));
        break;
      case EtapaCadastroEndereco.uf:
        emit(state.copyWith(etapa: EtapaCadastroEndereco.dadosBasicos));
        break;
      case EtapaCadastroEndereco.municipio:
        emit(state.copyWith(etapa: EtapaCadastroEndereco.uf));
        break;
      case EtapaCadastroEndereco.tipo:
        // Se veio do CEP automático, volta para dados básicos
        if (!state.preenchimentoManual && state.uf != null) {
          emit(state.copyWith(etapa: EtapaCadastroEndereco.dadosBasicos));
        } else {
          emit(state.copyWith(etapa: EtapaCadastroEndereco.municipio));
        }
        break;
      case EtapaCadastroEndereco.confirmacao:
        emit(state.copyWith(etapa: EtapaCadastroEndereco.tipo));
        break;
    }
  }

  void _onConfirmar(
    EnderecoCadastroConfirmar event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    final endereco = Endereco.create(
      principal: state.principal,
      cep: state.cep ?? '',
      logradouro: state.logradouro ?? '',
      numero: state.numero ?? '',
      complemento: state.complemento ?? '',
      bairro: state.bairro ?? '',
      uf: state.uf ?? '',
      municipio: state.municipio ?? '',
      pais: 'Brasil',
      tipoEndereco: state.tipo!,
    );

    emit(EnderecoCadastroConfirmado(endereco: endereco));
  }

  void _onCancelar(
    EnderecoCadastroCancelar event,
    Emitter<EnderecoCadastroState> emit,
  ) {
    emit(EnderecoCadastroCancelado());
  }
}
