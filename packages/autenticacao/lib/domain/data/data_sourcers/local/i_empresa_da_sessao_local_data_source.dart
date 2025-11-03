import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

abstract class IEmpresaDaSessaoLocalDataSource<E extends Empresa>
    implements ILocalDataSource<E> {}
