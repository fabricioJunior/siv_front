// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:date_format_field/date_format_field.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

abstract class InputFormarts {
  Widget dataFormatInput() => DateFormatField(
      type: DateFormatType.type1,
      onComplete: (date) {
        print(date.toString);
      });
}

// ignore: must_be_immutable
class DateInput extends StatelessWidget {
  dynamic Function(DateTime?) onComplete;
  final DateTime? dataInicial;
  final bool? bloqueado;
  final TextEditingController controller;
  // ignore: use_key_in_widget_constructors
  DateInput({
    required this.onComplete,
    this.dataInicial,
    this.bloqueado,
  }) : controller = TextEditingController(
          text: dataInicial != null
              ? '${dataInicial!.day}/${dataInicial.month}/${dataInicial.year}'
              : null,
        );

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: bloqueado ?? false,
      child: DateFormatField(
        controller: controller,
        onComplete: onComplete,
        type: DateFormatType.type2,
        initialDate: dataInicial,
      ),
    );
  }
}

// ignore: must_be_immutable
class CPFInput extends StatelessWidget {
  final String? valorInicial;
  final bool? bloqueado;
  final void Function(String)? onChanged;
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
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: valorInicial,
      readOnly: bloqueado ?? false,
      onChanged: onChanged,
      inputFormatters: [
        maskFormatter,
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Informe o CPF';
        }
        var cpfValido = CPFValidator.isValid(value);
        if (!cpfValido) {
          return 'CPF inválido, verifique os números digitados';
        }
        return null;
      },
    );
  }
}

class CelularInput extends StatelessWidget {
  final String? valorInicial;
  final void Function(String)? onChanged;
  final bool? bloqueado;
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
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: bloqueado ?? false,
      initialValue: valorInicial,
      onChanged: onChanged,
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
