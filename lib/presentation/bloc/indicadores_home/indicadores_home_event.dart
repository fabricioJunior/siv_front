part of 'indicadores_home_bloc.dart';

abstract class IndicadoresHomeEvent {
  const IndicadoresHomeEvent();
}

class IndicadoresHomeCarregou extends IndicadoresHomeEvent {
  final int empresaId;

  const IndicadoresHomeCarregou({required this.empresaId});
}
