import 'package:core/remote_data_sourcers.dart';

class PessoasRemoteDataSource extends RemoteDataSourceBase {
  PessoasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => 'v1/pessoas/{id}';
}
