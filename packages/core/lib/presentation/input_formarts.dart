// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cpf_cnpj_validator/cnpj_validator.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Campo de data dd/MM/aaaa: só aceita dígitos (máscara) e só chama [onComplete] com data
/// válida (ou null enquanto incompleta/inexistente). Não lança com texto colado ou digitado errado.
class DateInput extends StatefulWidget {
  final dynamic Function(DateTime?) onComplete;
  final DateTime? dataInicial;
  final bool? bloqueado;
  final String? labelText;
  final TextEditingController? externalController;

  const DateInput({
    super.key,
    required this.onComplete,
    this.dataInicial,
    this.bloqueado,
    this.labelText,
    this.externalController,
  });

  /// "dd/MM/aaaa" -> data, ou null se incompleto ou inexistente (ex.: 31/02/2024).
  static DateTime? interpretar(String texto) {
    final m = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$').firstMatch(texto);
    if (m == null) return null;
    final d = int.parse(m[1]!), mes = int.parse(m[2]!), a = int.parse(m[3]!);
    final data = DateTime(a, mes, d);
    return data.day == d && data.month == mes && data.year == a ? data : null;
  }

  static String formatar(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().padLeft(4, '0')}';

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  late final TextEditingController _controller =
      widget.externalController ??
      TextEditingController(
        text: widget.dataInicial != null ? DateInput.formatar(widget.dataInicial!) : null,
      );
  final _mascara = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void dispose() {
    if (widget.externalController == null) _controller.dispose();
    super.dispose();
  }

  Future<void> _escolher() async {
    final atual = DateInput.interpretar(_controller.text) ?? widget.dataInicial;
    final data = await showDatePicker(
      context: context,
      initialDate: atual,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (data == null) return;
    _controller.text = DateInput.formatar(data);
    widget.onComplete(data);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      readOnly: widget.bloqueado ?? false,
      keyboardType: TextInputType.number,
      inputFormatters: [_mascara],
      onChanged: (v) => widget.onComplete(DateInput.interpretar(v)),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: 'dd/mm/aaaa',
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          onPressed: (widget.bloqueado ?? false) ? null : _escolher,
          icon: const Icon(Icons.calendar_month),
        ),
      ),
    );
  }
}

bool cpfEhValido(String value) => CPFValidator.isValid(value);

bool cnpjEhValido(String value) => CNPJValidator.isValid(value);

/// Formata CPF (11 dígitos) ou CNPJ (14 dígitos) para exibição.
/// Se não tiver 11 nem 14 dígitos, retorna o valor original sem alteração.
String formatarDocumento(String? valor) {
  final digitos = (valor ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digitos.length == 11) {
    return MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
    ).maskText(digitos);
  }
  if (digitos.length == 14) {
    return MaskTextInputFormatter(
      mask: '##.###.###/####-##',
      filter: {"#": RegExp(r'[0-9]')},
    ).maskText(digitos);
  }
  return valor ?? '';
}

// ignore: must_be_immutable
class CPFInput extends StatelessWidget {
  final String? valorInicial;
  final bool? bloqueado;
  final bool obrigatorio;
  final String? labelText;
  final void Function(String)? onChanged;
  final TextEditingController? controller;
  var maskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  CPFInput({
    this.valorInicial,
    this.onChanged,
    super.key,
    this.bloqueado,
    this.obrigatorio = true,
    this.labelText,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? valorInicial : null,
      readOnly: bloqueado ?? false,
      decoration: InputDecoration(
        labelText: labelText ?? (obrigatorio ? 'CPF *' : 'CPF'),
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
      inputFormatters: [
        maskFormatter,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return obrigatorio ? 'Informe o CPF' : null;
        }
        if (!cpfEhValido(value)) {
          return 'CPF inválido, verifique os números digitados';
        }
        return null;
      },
    );
  }
}

/// Campo de documento: CPF (pessoa física) ou CNPJ (pessoa jurídica), conforme [juridica].
/// Troca máscara, rótulo e validação; o controller/valor é do chamador (limpe-o ao trocar o tipo).
class DocumentoInput extends StatefulWidget {
  final bool juridica;
  final String? valorInicial;
  final bool? bloqueado;
  final bool obrigatorio;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  const DocumentoInput({
    super.key,
    this.juridica = false,
    this.valorInicial,
    this.bloqueado,
    this.obrigatorio = true,
    this.onChanged,
    this.controller,
  });

  @override
  State<DocumentoInput> createState() => _DocumentoInputState();
}

class _DocumentoInputState extends State<DocumentoInput> {
  final _mascaraCpf = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  final _mascaraCnpj = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  Widget build(BuildContext context) {
    final rotulo = widget.juridica ? 'CNPJ' : 'CPF';
    return TextFormField(
      key: ValueKey('documento_$rotulo'),
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.valorInicial : null,
      readOnly: widget.bloqueado ?? false,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.obrigatorio ? '$rotulo *' : rotulo,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
      inputFormatters: [widget.juridica ? _mascaraCnpj : _mascaraCpf],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return widget.obrigatorio ? 'Informe o $rotulo' : null;
        }
        final valido =
            widget.juridica ? cnpjEhValido(value) : cpfEhValido(value);
        return valido ? null : '$rotulo inválido, verifique os números digitados';
      },
    );
  }
}

// ignore: must_be_immutable
class CelularInput extends StatelessWidget {
  final String? valorInicial;
  final void Function(String)? onChanged;
  final bool? bloqueado;
  final String? labelText;
  final TextEditingController? controller;
  var maskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  CelularInput({
    this.valorInicial,
    this.onChanged,
    super.key,
    this.bloqueado,
    this.labelText,
    this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: bloqueado ?? false,
      controller: controller,
      initialValue: controller == null ? valorInicial : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      inputFormatters: [
        maskFormatter,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o Celular';
        }

        return null;
      },
    );
  }
}
