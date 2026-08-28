part of 'estampa_bloc.dart';

abstract class EstampaEvent {}

class EstampaIniciou extends EstampaEvent {
  final int? idEstampa;

  EstampaIniciou({this.idEstampa});
}

class EstampaEditou extends EstampaEvent {
  final String nome;

  EstampaEditou({required this.nome});
}

class EstampaSalvou extends EstampaEvent {}
