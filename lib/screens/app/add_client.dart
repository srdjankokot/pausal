import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/client.dart';

class AddClientSheet extends StatefulWidget {
  const AddClientSheet({
    super.key,
    required this.onSubmit,
    this.initialClient,
    this.onDelete,
  });

  final Client? initialClient;
  final void Function(Client client) onSubmit;
  final VoidCallback? onDelete;

  @override
  State<AddClientSheet> createState() => _AddClientSheetState();
}

class _AddClientSheetState extends State<AddClientSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _pibController;
  late final TextEditingController _addressController;

  bool get _isEditing => widget.initialClient != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialClient?.name ?? '',
    );
    _pibController = TextEditingController(
      text: widget.initialClient?.pib ?? '',
    );
    _addressController = TextEditingController(
      text: widget.initialClient?.address ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pibController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final client = Client(
      id:
          widget.initialClient?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      pib: _pibController.text.trim(),
      address: _addressController.text.trim(),
    );

    widget.onSubmit(client);
    Navigator.of(context).pop(client);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final titleText = _isEditing ? 'Izmena klijenta' : 'Novi klijent';

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titleText,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Naziv klijenta',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Unesite naziv klijenta';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pibController,
                decoration: const InputDecoration(
                  labelText: 'PIB',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresa',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (widget.onDelete != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        widget.onDelete?.call();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Obriši'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                    ),
                    const Spacer(),
                  ] else
                    const Spacer(),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Sačuvaj'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
