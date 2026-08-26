import 'package:autenticacao/domain/models/token.dart';
import 'package:core/data_sourcers.dart';

abstract class ITokenLocalDataSource<Dto extends Token>
    implements ILocalDataSource<Dto> {}
