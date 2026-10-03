part of 'importacao_guiada_bloc.dart';

sealed class ImportacaoGuiadaEvent {
  const ImportacaoGuiadaEvent();
}

/// Carrega em que etapa o usuário está (última importação de cada tipo).
class ImportacaoGuiadaIniciou extends ImportacaoGuiadaEvent {
  const ImportacaoGuiadaIniciou();
}

class ImportacaoGuiadaEtapaSelecionada extends ImportacaoGuiadaEvent {
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaEtapaSelecionada(this.etapa);
}

class ImportacaoGuiadaModeloBaixado extends ImportacaoGuiadaEvent {
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaModeloBaixado(this.etapa);
}

class ImportacaoGuiadaArquivoSelecionado extends ImportacaoGuiadaEvent {
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaArquivoSelecionado(this.etapa);
}

class ImportacaoGuiadaTabelaDePrecoAlterada extends ImportacaoGuiadaEvent {
  final int? tabelaDePrecoId;

  /// Etapa que escolheu a tabela (vendas ou preços).
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaTabelaDePrecoAlterada(
    this.tabelaDePrecoId, {
    this.etapa = ImportacaoEtapa.vendas,
  });
}

class ImportacaoGuiadaFuncionarioAlterado extends ImportacaoGuiadaEvent {
  final int? funcionarioId;
  const ImportacaoGuiadaFuncionarioAlterado(this.funcionarioId);
}

class ImportacaoGuiadaEnviou extends ImportacaoGuiadaEvent {
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaEnviou(this.etapa);
}

/// Andamento publicado pelo servidor via WebSocket.
class ImportacaoGuiadaProgressoRecebido extends ImportacaoGuiadaEvent {
  final ImportacaoProgressoEvent progresso;
  const ImportacaoGuiadaProgressoRecebido(this.progresso);
}

/// Busca o resultado detalhado (rejeições) de uma importação que terminou.
class ImportacaoGuiadaDetalhou extends ImportacaoGuiadaEvent {
  final ImportacaoEtapa etapa;
  const ImportacaoGuiadaDetalhou(this.etapa);
}

/// Consulta de segurança enquanto há importação em andamento: se o
/// WebSocket cair, o andamento continua chegando por aqui.
class ImportacaoGuiadaConsultou extends ImportacaoGuiadaEvent {
  const ImportacaoGuiadaConsultou();
}
