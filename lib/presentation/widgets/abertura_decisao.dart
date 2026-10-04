import 'package:siv_front/presentation/bloc/app_bloc/app_bloc.dart';

/// Rota em que o app deve estar quando a abertura termina, ou `null` se não há
/// destino fixo a esperar (erro de inicialização, login em andamento etc.).
String? destinoDaAbertura(StatusAutenticacao status, {String? rotaDeTeste}) =>
    switch (status) {
      StatusAutenticacao.autenticado => rotaDeTeste ?? '/home',
      StatusAutenticacao.naoAutenticao => '/login',
      _ => null,
    };

/// A tela de carregamento deve continuar por cima, mesmo com o conteúdo já
/// montado? Sim enquanto a navegação inicial não chegou ao destino -- senão o
/// usuário vê a tela de login por um instante antes da home (a "piscada").
bool segurarCarga({
  required bool veioDaCarga,
  required StatusAutenticacao status,
  required String? rotaAtual,
  String? rotaDeTeste,
}) {
  if (!veioDaCarga) return false;
  final destino = destinoDaAbertura(status, rotaDeTeste: rotaDeTeste);
  return destino != null && rotaAtual != destino;
}
