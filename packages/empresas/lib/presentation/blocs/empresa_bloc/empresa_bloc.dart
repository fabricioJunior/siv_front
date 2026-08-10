import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:empresas/domain/entities/empresa.dart';
import 'package:empresas/domain/usecases/criar_empresa.dart';
import 'package:empresas/domain/usecases/recuperar_empresa.dart';
import 'package:empresas/domain/usecases/salvar_empresa.dart';

part 'empresa_state.dart';
part 'empresa_event.dart';

class EmpresaBloc extends Bloc<EmpresaEvent, EmpresaState> {
  final CriarEmpresa _criarEmpresa;
  final SalvarEmpresa _salvarEmpresa;
  final RecuperarEmpresa _recuperarEmpresa;

  EmpresaBloc(
    this._criarEmpresa,
    this._recuperarEmpresa,
    this._salvarEmpresa,
  ) : super(EmpresaNaoInicializada()) {
    on<EmpresaIniciou>(_onEmpresaIniciou);
    on<EmpresaEditou>(_onEmpresaEditou);
    on<EmpresaSalvou>(_onEmpresaSalvou);
  }
  Future<void> _onEmpresaIniciou(
    EmpresaIniciou event,
    Emitter<EmpresaState> emit,
  ) async {
    if (event.idEmpresa == null) {
      emit(EmpresaEditarEmProgresso());
      return;
    }
    try {
      emit(EmpresaCarregarEmProgresso());
      var empresa = await _recuperarEmpresa.call(event.idEmpresa!);
      emit(EmpresaCarregarSucesso(empresa: empresa!));
    } catch (e, s) {
      emit(EmpresaCarregarFalha());
      addError(e, s);
    }
  }

  Future<void> _onEmpresaEditou(
    EmpresaEditou event,
    Emitter<EmpresaState> emit,
  ) async {
    try {
      // Entra em modo edição a partir de QUALQUER estado anterior (ex: acabou de carregar uma
      // empresa existente) -- e já aplica o campo editado nesta mesma emissão. Antes, a primeira
      // edição de uma empresa existente só trocava pro modo edição (via fromEmpresa) e descartava
      // o valor do evento; o campo editado só "pegava" na segunda tentativa. Muito visível em
      // seletores (um toque só, sem digitação contínua pra mascarar o drop).
      final atual = state is EmpresaEditarEmProgresso
          ? state as EmpresaEditarEmProgresso
          : EmpresaEditarEmProgresso.fromEmpresa(state.empresa);

      final empresaAtualizada = atual.empresa?.copyWith(
        id: event.id,
        cnpj: event.cnpj,
        codigoDeAtividade: event.codigoDeAtividade,
        codigoDeNaturezaJuridica: event.codigoDeNaturezaJuridica,
        email: event.email,
        inscricaoEstadual: event.inscricaoEstadual,
        nome: event.nome,
        nomeFantasia: event.nomeFantasia,
        regime: event.regime,
        registroMunicipal: event.registroMunicipal,
        substituicaoTributaria: event.substituicaoTributaria,
        telefone: event.telefone,
        uf: event.uf,
        logradouro: event.logradouro,
        numero: event.numero,
        bairro: event.bairro,
        codigoMunicipioIbge: event.codigoMunicipioIbge,
        municipio: event.municipio,
        cep: event.cep,
        latitude: event.latitude,
        longitude: event.longitude,
      );

      emit(
        atual.copyWith(
          id: event.id,
          cnpj: event.cnpj,
          codigoDeAtividade: event.codigoDeAtividade,
          codigoDeNaturezaJuridica: event.codigoDeNaturezaJuridica,
          email: event.email,
          inscricaoEstadual: event.inscricaoEstadual,
          nome: event.nome,
          nomeFantasia: event.nomeFantasia,
          regime: event.regime,
          registroMunicipal: event.registroMunicipal,
          substituicaoTributaria: event.substituicaoTributaria,
          telefone: event.telefone,
          uf: event.uf,
          logradouro: event.logradouro,
          numero: event.numero,
          bairro: event.bairro,
          codigoMunicipioIbge: event.codigoMunicipioIbge,
          municipio: event.municipio,
          cep: event.cep,
          latitude: event.latitude,
          longitude: event.longitude,
          empresa: empresaAtualizada,
        ),
      );
    } catch (e, s) {
      addError(e, s);
    }
  }

  Future<void> _onEmpresaSalvou(
    EmpresaSalvou event,
    Emitter<EmpresaState> emit,
  ) async {
    try {
      var editState = state;
      emit(EmpresaSalvarEmProgresso());

      if (editState is EmpresaEditarEmProgresso) {
        if (editState.empresa != null) {
          var empresa = await _salvarEmpresa.call(empresa: editState.empresa!);
          emit(EmpresaSalvarSucesso(empresa: empresa));
        } else {
          var empresa = await _criarEmpresa.call(
            cnpj: editState.cnpj!,
            codigoDeAtividade: editState.codigoDeAtividade,
            codigoDeNaturezaJuridica: editState.codigoDeNaturezaJuridica,
            email: editState.email!,
            inscricaoEstadual: editState.inscricaoEstadual,
            nome: editState.nome!,
            nomeFantasia: editState.nomeFantasia!,
            regime: editState.regime,
            registroMunicipal: editState.registroMunicipal,
            substituicaoTributaria: editState.substituicaoTributaria,
            telefone: editState.telefone,
            uf: editState.uf,
            logradouro: editState.logradouro,
            numero: editState.numero,
            bairro: editState.bairro,
            codigoMunicipioIbge: editState.codigoMunicipioIbge,
            municipio: editState.municipio,
            cep: editState.cep,
            latitude: editState.latitude,
            longitude: editState.longitude,
          );
          emit(EmpresaSalvarSucesso(empresa: empresa));
        }
      }
    } catch (e, s) {
      addError(e, s);
      emit(EmpresaSalvarFalha());
    }
  }
}
