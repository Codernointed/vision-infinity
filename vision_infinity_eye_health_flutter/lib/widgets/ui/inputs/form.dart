import 'package:flutter/material.dart';

class CustomForm extends StatefulWidget {
  final List<Widget> children;
  final void Function(Map<String, dynamic>)? onSubmit;
  final bool autoValidate;
  final Widget? submitButton;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomForm({
    super.key,
    required this.children,
    this.onSubmit,
    this.autoValidate = false,
    this.submitButton,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  final _formKey = GlobalKey<FormState>();
  final bool _isSubmitting = false;


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode:
          widget.autoValidate
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
      child: Padding(
        padding: widget.padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: widget.crossAxisAlignment,
          children: [
            ...widget.children,
            if (widget.submitButton != null) ...[
              const SizedBox(height: 24),
              AbsorbPointer(
                absorbing: _isSubmitting,
                child: widget.submitButton!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CustomFormField extends StatelessWidget {
  final String name;
  final Widget child;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;

  const CustomFormField({
    super.key,
    required this.name,
    required this.child,
    this.validator,
    this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: validator,
      onSaved: onSaved,
      builder: (FormFieldState<String> field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            child,
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
