import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:core/imagens/cache_imagem_service.dart';
import 'package:produtos/domain/use_cases/atualizar_referencia_midia.dart';
import 'package:produtos/domain/use_cases/criar_referencia_midia.dart';
import 'package:produtos/domain/use_cases/excluir_referencia_midia.dart';
import 'package:produtos/domain/use_cases/recuperar_referencia_midias.dart';
import 'package:produtos/models.dart';
part 'referencia_midias_event.dart';
part 'referencia_midias_state.dart';

class ReferenciaMidiasBloc
    extends Bloc<ReferenciaMidiasEvent, ReferenciaMidiasState> {
  final RecuperarReferenciaMidias _recuperarMidias;
  final CriarReferenciaMidia _criarReferenciaMidia;
  final ExcluirReferenciaMidia _excluirReferenciaMidia;
  final AtualizarReferenciaMidia _atualizarReferenciaMidia;

  final ICacheImagemService _cacheImagemService;

  ReferenciaMidiasBloc(
    this._recuperarMidias,
    this._criarReferenciaMidia,
    this._excluirReferenciaMidia,
    this._atualizarReferenciaMidia,
    this._cacheImagemService,
  ) : super(ReferenciaMidiasInicial()) {
    on<ReferenciasIniciou>(_onReferenciasIniciou);
    on<ReferenciasMidiaAdicinou>(_onReferenciaMidiaAdicinou);
    on<ReferenciaMidiasRemoveu>(_onReferenciaMidiasRemoveu);
    on<ReferenciaMidiasAtualizou>(_onReferenciaMidiasAtualizou);
  }

  List<ReferenciaMidia> _midiasAtuais() =>
      List<ReferenciaMidia>.from(state.midias);

  List<MidiaUploadPendente> _uploadsPendentesAtuais() =>
      List<MidiaUploadPendente>.from(state.uploadsPendentes);

  List<MidiaUploadPendente> _atualizarUploadPendente(
    List<MidiaUploadPendente> uploads,
    String uploadId, {
    double? progresso,
    String? status,
  }) {
    return uploads
        .map((upload) {
          if (upload.id != uploadId) return upload;
          return upload.copyWith(progresso: progresso, status: status);
        })
        .toList(growable: false);
  }

  Future<void> _onReferenciasIniciou(
    ReferenciasIniciou event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(
      ReferenciaMidiasCarregando(
        midias: state.midias,
        uploadsPendentes: state.uploadsPendentes,
      ),
    );
    try {
      final midias = await _recuperarMidias.call(event.referenciaId);
      emit(
        ReferenciaMidiasCarregado(
          midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
    } catch (e, s) {
      emit(
        ReferenciaMidiasErro(
          'Erro ao carregar mídias',
          midias: state.midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onReferenciaMidiaAdicinou(
    ReferenciasMidiaAdicinou event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    var midiasAtuais = _midiasAtuais();
    var uploadsPendentes = _uploadsPendentesAtuais();

    final novosUploads = event.midias
        .asMap()
        .entries
        .map((entry) {
          return MidiaUploadPendente(
            id: 'upload-${DateTime.now().microsecondsSinceEpoch}-${entry.key}',
            imagem: entry.value,
          );
        })
        .toList(growable: false);

    uploadsPendentes = [...uploadsPendentes, ...novosUploads];
    emit(
      ReferenciaMidiasCarregado(
        midiasAtuais,
        uploadsPendentes: uploadsPendentes,
        carregando: true,
      ),
    );

    for (final entry in event.midias.asMap().entries) {
      final imagem = entry.value;
      final upload = novosUploads[entry.key];

      if (imagem.path == null) {
        uploadsPendentes = uploadsPendentes
            .where((item) => item.id != upload.id)
            .toList(growable: false);
        emit(
          ReferenciaMidiasErro(
            'Uma das imagens selecionadas é inválida para envio.',
            midias: midiasAtuais,
            uploadsPendentes: uploadsPendentes,
            carregando: uploadsPendentes.isNotEmpty,
          ),
        );
        continue;
      }

      var ultimoPercentualEmitido = -1;

      try {
        final midiaCriada = await _criarReferenciaMidia.call(
          filePath: imagem.path!,
          referenciaId: event.referenciaId,
          ePrincipal: midiasAtuais.isEmpty && entry.key == 0,
          ePublica: true,
          tipo: TipoReferenciaMidia.imagem,
          field: imagem.field ?? 'file',
          descricao: imagem.descricao,
          cor: imagem.cor ?? event.cor,
          tamanho: imagem.tamanho ?? event.tamanho,
          onSendProgress: (sent, total) {
            if (emit.isDone) return;
            final progresso = total <= 0
                ? 0.0
                : (sent / total).clamp(0.0, 1.0).toDouble();
            final percentualAtual = (progresso * 100).round();

            if (percentualAtual == ultimoPercentualEmitido &&
                percentualAtual < 100) {
              return;
            }

            ultimoPercentualEmitido = percentualAtual;
            uploadsPendentes = _atualizarUploadPendente(
              uploadsPendentes,
              upload.id,
              progresso: progresso,
              status: percentualAtual >= 100
                  ? 'Finalizando envio...'
                  : 'Enviando... $percentualAtual%',
            );

            emit(
              ReferenciaMidiasCarregado(
                midiasAtuais,
                uploadsPendentes: uploadsPendentes,
                carregando: true,
              ),
            );
          },
        );

        if (midiaCriada.ePrincipal) {
          await _cacheImagemService.updateImageInCache(
            event.referenciaId.toString(),
            midiaCriada.url,
          );
        }

        midiasAtuais = [...midiasAtuais, midiaCriada];
        uploadsPendentes = uploadsPendentes
            .where((item) => item.id != upload.id)
            .toList(growable: false);

        if (!emit.isDone) {
          emit(
            ReferenciaMidiasCarregado(
              midiasAtuais,
              uploadsPendentes: uploadsPendentes,
              carregando: uploadsPendentes.isNotEmpty,
            ),
          );
        }
      } catch (e, s) {
        final mensagem = e.toString().replaceFirst('Exception: ', '').trim();
        uploadsPendentes = uploadsPendentes
            .where((item) => item.id != upload.id)
            .toList(growable: false);

        if (!emit.isDone) {
          emit(
            ReferenciaMidiasErro(
              mensagem.isEmpty ? 'Erro ao adicionar mídia' : mensagem,
              midias: midiasAtuais,
              uploadsPendentes: uploadsPendentes,
              carregando: uploadsPendentes.isNotEmpty,
            ),
          );
        }
        addError(e, s);
      }
    }

    try {
      final midiasSincronizadas = await _recuperarMidias.call(
        event.referenciaId,
      );
      if (!emit.isDone) {
        emit(
          ReferenciaMidiasCarregado(
            midiasSincronizadas,
            uploadsPendentes: const [],
          ),
        );
      }
    } catch (e, s) {
      addError(e, s);
      if (!emit.isDone) {
        emit(ReferenciaMidiasCarregado(midiasAtuais));
      }
    }
  }

  Future<void> _onReferenciaMidiasRemoveu(
    ReferenciaMidiasRemoveu event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(
      ReferenciaMidiasCarregando(
        midias: state.midias,
        uploadsPendentes: state.uploadsPendentes,
      ),
    );
    try {
      await _excluirReferenciaMidia.call(
        referenciaId: event.referenciaId,
        id: event.midiaId,
      );
      final midias = await _recuperarMidias.call(event.referenciaId);
      emit(
        ReferenciaMidiasCarregado(
          midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
    } catch (e, s) {
      emit(
        ReferenciaMidiasErro(
          'Erro ao remover mídia',
          midias: state.midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
      addError(e, s);
    }
  }

  Future<void> _onReferenciaMidiasAtualizou(
    ReferenciaMidiasAtualizou event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(
      ReferenciaMidiasCarregando(
        midias: state.midias,
        uploadsPendentes: state.uploadsPendentes,
      ),
    );
    try {
      await _atualizarReferenciaMidia.call(
        ReferenciaMidia.create(
          id: event.midia.id,
          url: event.midia.url,
          referenciaId: event.referenciaId,
          ePrincipal: event.ePrincipal,
          ePublica: event.ePublica,
          descricao: event.midia.descricao,
          tamanho: event.midia.tamanho,
          cor: event.midia.cor,
        ),
      );
      if (event.ePrincipal) {
        await _cacheImagemService.updateImageInCache(
          event.referenciaId.toString(),
          event.midia.url,
        );
      }

      final midias = await _recuperarMidias.call(event.referenciaId);
      emit(
        ReferenciaMidiasCarregado(
          midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
    } catch (e, s) {
      emit(
        ReferenciaMidiasErro(
          'Erro ao atualizar mídia',
          midias: state.midias,
          uploadsPendentes: state.uploadsPendentes,
        ),
      );
      addError(e, s);
    }
  }
}
