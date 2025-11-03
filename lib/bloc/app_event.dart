part of 'app_bloc.dart';

abstract class AppEvent {}

class AppIniciou extends AppEvent {}

class AppAutenticou extends AppEvent {
  final Token token;

  AppAutenticou({required this.token});
}

class AppDesautenticou extends AppEvent {}
