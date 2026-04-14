import 'package:autenticacao/domain/models/terminal_do_usuario.dart';
import 'package:core/data_sourcers.dart';

abstract class ITerminalDaSessaoLocalDataSource<T extends TerminalDoUsuario>
    implements ILocalDataSource<T> {}
