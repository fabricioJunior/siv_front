import 'package:json_annotation/json_annotation.dart';
part 'meta_dto.g.dart';

@JsonSerializable()
class MetaDto {
  final int itemCount;
  final int itemsPerPage;
  final int totalPages;
  final int currentPage;

  MetaDto({
    required this.itemCount,
    required this.itemsPerPage,
    required this.totalPages,
    required this.currentPage,
  });

  factory MetaDto.fromJson(Map<String, dynamic> json) =>
      _$MetaDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MetaDtoToJson(this);
}
