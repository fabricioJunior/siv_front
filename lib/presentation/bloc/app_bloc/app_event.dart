part of 'app_bloc.dart';

abstract class AppEvent {}

class AppIniciou extends AppEvent {}

class AppAutenticou extends AppEvent {
  final Token token;

  AppAutenticou({required this.token});
}

class AppDesautenticou extends AppEvent {
  // false quando disparado por 401 esporádico (AuthHttpInterceptor) -- nesse caso mantém os dados
  // locais (produtos/estoque/preços/etc), só limpa sessão/token e volta pro login. O wipe total
  // (apagarTodosOsDados) fica só pro logout explícito do usuário, que troca de licenciado.
  final bool apagarDadosLocais;

  AppDesautenticou({this.apagarDadosLocais = true});
}

class AppSelecionouTerminalDaSessao extends AppEvent {
  final TerminalDoUsuario terminal;

  AppSelecionouTerminalDaSessao({required this.terminal});
}

class AppLimpouTerminalDaSessao extends AppEvent {}

class AppSelecionouEmpresaDaSessao extends AppEvent {
  final Empresa empresa;

  AppSelecionouEmpresaDaSessao({required this.empresa});
}

class AppAtualizouCaixaDaSessao extends AppEvent {
  final int terminalId;
  final int? caixaId;

  AppAtualizouCaixaDaSessao({required this.terminalId, required this.caixaId});
}
