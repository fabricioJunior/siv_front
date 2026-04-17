part of 'referencia_midias_bloc.dart';

class MidiaUploadPendente {
  final String id;
  final Imagem imagem;
  final double progresso;
  final String status;

  const MidiaUploadPendente({
    required this.id,
    required this.imagem,
    this.progresso = 0,
    this.status = 'Preparando upload...',
  });

  MidiaUploadPendente copyWith({
    String? id,
    Imagem? imagem,
    double? progresso,
    String? status,
  }) {
    return MidiaUploadPendente(
      id: id ?? this.id,
      imagem: imagem ?? this.imagem,
      progresso: progresso ?? this.progresso,
      status: status ?? this.status,
    );
  }
}

abstract class ReferenciaMidiasState {
  final List<ReferenciaMidia> midias;
  final List<MidiaUploadPendente> uploadsPendentes;
  final bool carregando;

  const ReferenciaMidiasState({
    this.midias = const [],
    this.uploadsPendentes = const [],
    this.carregando = false,
  });
}

class ReferenciaMidiasInicial extends ReferenciaMidiasState {
  const ReferenciaMidiasInicial();
}

class ReferenciaMidiasCarregando extends ReferenciaMidiasState {
  const ReferenciaMidiasCarregando({super.midias, super.uploadsPendentes})
    : super(carregando: true);
}

class ReferenciaMidiasCarregado extends ReferenciaMidiasState {
  const ReferenciaMidiasCarregado(
    List<ReferenciaMidia> midias, {
    super.uploadsPendentes = const [],
    super.carregando = false,
  }) : super(midias: midias);
}

class ReferenciaMidiasErro extends ReferenciaMidiasState {
  final String mensagem;

  const ReferenciaMidiasErro(
    this.mensagem, {
    super.midias,
    super.uploadsPendentes,
    super.carregando,
  });
}

class ReferenciaMidiaAdicionada extends ReferenciaMidiasState {
  const ReferenciaMidiaAdicionada({
    super.midias,
    super.uploadsPendentes,
    super.carregando,
  });
}

class ReferenciaMidiaRemovida extends ReferenciaMidiasState {
  const ReferenciaMidiaRemovida({
    super.midias,
    super.uploadsPendentes,
    super.carregando,
  });
}
