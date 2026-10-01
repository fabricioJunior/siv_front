/// Só este usuário (login) importa dados; o backend aplica a mesma regra
/// (ver `ImportacaoAcesso` no apollo-api), então esconder a tela aqui é só
/// conveniência.
const loginDeImportacao = 'apollo';

bool usuarioPodeImportar(String? login) => login == loginDeImportacao;
