import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

abstract class ILicenciadoDaSessaoLocalDataSource<L extends Licenciado>
    implements ILocalDataSource<L> {}