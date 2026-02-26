part of 'endereco_cadastro_bloc.dart';

abstract class EnderecoCadastroEvent {}

class EnderecoCadastroIniciou extends EnderecoCadastroEvent {}

// Eventos da etapa CEP
class EnderecoCadastroCepDigitado extends EnderecoCadastroEvent {
  final String cep;
  EnderecoCadastroCepDigitado(this.cep);
}

class EnderecoCadastroBuscarCep extends EnderecoCadastroEvent {}

class EnderecoCadastroPreencherManualmente extends EnderecoCadastroEvent {}

// Eventos da etapa de dados básicos (logradouro, número, complemento, bairro)
class EnderecoCadastroLogradouroAlterado extends EnderecoCadastroEvent {
  final String logradouro;
  EnderecoCadastroLogradouroAlterado(this.logradouro);
}

class EnderecoCadastroNumeroAlterado extends EnderecoCadastroEvent {
  final String numero;
  EnderecoCadastroNumeroAlterado(this.numero);
}

class EnderecoCadastroComplementoAlterado extends EnderecoCadastroEvent {
  final String complemento;
  EnderecoCadastroComplementoAlterado(this.complemento);
}

class EnderecoCadastroBairroAlterado extends EnderecoCadastroEvent {
  final String bairro;
  EnderecoCadastroBairroAlterado(this.bairro);
}

class EnderecoCadastroAvancarParaUf extends EnderecoCadastroEvent {}

// Eventos da etapa UF
class EnderecoCadastroUfAlterada extends EnderecoCadastroEvent {
  final String uf;
  EnderecoCadastroUfAlterada(this.uf);
}

class EnderecoCadastroAvancarParaMunicipio extends EnderecoCadastroEvent {}

// Eventos da etapa Município
class EnderecoCadastroMunicipioAlterado extends EnderecoCadastroEvent {
  final String municipio;
  EnderecoCadastroMunicipioAlterado(this.municipio);
}

class EnderecoCadastroAvancarParaTipo extends EnderecoCadastroEvent {}

// Eventos da etapa Tipo
class EnderecoCadastroTipoAlterado extends EnderecoCadastroEvent {
  final TipoEndereco tipo;
  EnderecoCadastroTipoAlterado(this.tipo);
}

class EnderecoCadastroPrincipalAlterado extends EnderecoCadastroEvent {
  final bool principal;
  EnderecoCadastroPrincipalAlterado(this.principal);
}

class EnderecoCadastroAvancarParaConfirmacao extends EnderecoCadastroEvent {}

// Eventos de navegação
class EnderecoCadastroVoltarEtapa extends EnderecoCadastroEvent {}

class EnderecoCadastroConfirmar extends EnderecoCadastroEvent {}

class EnderecoCadastroCancelar extends EnderecoCadastroEvent {}
