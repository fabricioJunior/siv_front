enum TipoImpressora { etiqueta, documento }

extension TipoImpressoraX on TipoImpressora {
  String get nomeArquivoPreferencia {
    switch (this) {
      case TipoImpressora.etiqueta:
        return 'impressora_preferida_etiqueta.txt';
      case TipoImpressora.documento:
        return 'impressora_preferida_documento.txt';
    }
  }
}
