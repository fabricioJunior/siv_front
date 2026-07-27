import 'package:core/equals.dart';

class ImagemDaReferencia extends Equatable {
  final int id;
  final String url;
  final bool isDefault;
  final bool isPublic;

  const ImagemDaReferencia({
    required this.id,
    required this.url,
    required this.isDefault,
    required this.isPublic,
  });

  @override
  List<Object?> get props => [id, url, isDefault, isPublic];

  @override
  bool? get stringify => true;
}
