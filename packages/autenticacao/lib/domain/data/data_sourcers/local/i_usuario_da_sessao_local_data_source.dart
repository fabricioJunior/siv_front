import 'package:autenticacao/models.dart';
import 'package:core/data_sourcers.dart';

abstract class IUsuarioDaSessaoLocalDataSource<E extends Usuario>
    implements ILocalDataSource<E> {}
