import 'package:core/local_data_sourcers/hive/entities_controller.dart';
import 'package:core/produtos_compartilhados/local/dtos/lista_de_produtos_compartilhada_hive_dto.dart';
import 'package:core/produtos_compartilhados/local/dtos/produto_compartilhado_hive_dto.dart';
import 'package:autenticacao/data/local/dtos/credenciais_hive_dto.dart';
import 'package:autenticacao/data/local/dtos/token_hive_dto.dart';
import 'package:autenticacao/data/local/dtos/permissao_do_usuario_hive_dto.dart';
import 'package:estoque/data/local/dtos/produto_estoque_hive_dto.dart';
import 'package:precos/data/local/dtos/preco_da_referencia_hive_dto.dart';
import 'package:precos/data/local/dtos/tabela_de_preco_hive_dto.dart';
import 'package:produtos/data/local/dtos/codigo_hive_dto.dart';

import 'data/infra/local_data_sourcers/dtos/empresa_hive_dto.dart';
import 'data/infra/local_data_sourcers/dtos/licenciado_hive_dto.dart';
import 'data/infra/local_data_sourcers/dtos/terminal_da_sessao_hive_dto.dart';
import 'data/infra/local_data_sourcers/dtos/usuario_hive_dto.dart';

/// typeId global (não por box) de cada `StorageEntity` do app -- nunca
/// reusar um id já alocado por outro tipo. Chamado uma vez no bootstrap
/// (`main.dart`), antes de qualquer box Hive ser aberta.
void inicializarStorageDoApp() {
  inicializarStorage({
    UsuarioHiveDto: 0,
    EmpresaHiveDto: 1,
    LicenciadoHiveDto: 2,
    TerminalDaSessaoHiveDto: 3,
    ProdutoCompartilhadoHiveDto: 4,
    ListaDeProdutosCompartilhadaHiveDto: 5,
    TokenHiveDto: 6,
    PermissaoDoUsuarioHiveDto: 7,
    ProdutoEstoqueHiveDto: 8,
    PrecoDaReferenciaHiveDto: 9,
    TabelaDePrecoHiveDto: 10,
    CodigoHiveDto: 11,
    CredenciaisHiveDto: 12,
  });
}
