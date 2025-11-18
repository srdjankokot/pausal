import 'package:flutter/material.dart';
import 'package:pausal_calculator/screens/app/company_profile.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';
import 'package:pausal_calculator/utils.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({
    required this.taxProfile,
    required this.companyProfile,
    required this.onProfilesChanged,
  });

  final TaxProfile taxProfile;
  final CompanyProfile companyProfile;
  final void Function(TaxProfile taxProfile, CompanyProfile companyProfile)
  onProfilesChanged;

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cityController;
  late TextEditingController _pensionController;
  late TextEditingController _healthController;
  late TextEditingController _taxController;
  late TextEditingController _limitController;
  late TextEditingController _rollingLimitController;
  late TextEditingController _rateController;
  late TextEditingController _companyNameController;
  late TextEditingController _companyShortNameController;
  late TextEditingController _companyPibController;
  late TextEditingController _companyAddressController;
  late TextEditingController _companyAccountController;
  late TextEditingController _companyResponsibleController;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.taxProfile.city);
    _pensionController = TextEditingController(
      text: widget.taxProfile.monthlyPension.toStringAsFixed(0),
    );
    _healthController = TextEditingController(
      text: widget.taxProfile.monthlyHealth.toStringAsFixed(0),
    );
    _taxController = TextEditingController(
      text: widget.taxProfile.monthlyTaxPrepayment.toStringAsFixed(0),
    );
    _limitController = TextEditingController(
      text: widget.taxProfile.annualLimit.toStringAsFixed(0),
    );
    _rollingLimitController = TextEditingController(
      text: widget.taxProfile.rollingLimit.toStringAsFixed(0),
    );
    _rateController = TextEditingController(
      text: (widget.taxProfile.additionalTaxRate * 100).toStringAsFixed(1),
    );
    _companyNameController = TextEditingController(
      text: widget.companyProfile.name,
    );
    _companyShortNameController = TextEditingController(
      text: widget.companyProfile.shortName,
    );
    _companyPibController = TextEditingController(
      text: widget.companyProfile.pib,
    );
    _companyAddressController = TextEditingController(
      text: widget.companyProfile.address,
    );
    _companyAccountController = TextEditingController(
      text: widget.companyProfile.accountNumber,
    );
    _companyResponsibleController = TextEditingController(
      text: widget.companyProfile.responsiblePerson,
    );
  }

  @override
  void didUpdateWidget(covariant ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.taxProfile != oldWidget.taxProfile) {
      _cityController.text = widget.taxProfile.city;
      _pensionController.text = widget.taxProfile.monthlyPension
          .toStringAsFixed(0);
      _healthController.text = widget.taxProfile.monthlyHealth.toStringAsFixed(
        0,
      );
      _taxController.text = widget.taxProfile.monthlyTaxPrepayment
          .toStringAsFixed(0);
      _limitController.text = widget.taxProfile.annualLimit.toStringAsFixed(0);
      _rollingLimitController.text = widget.taxProfile.rollingLimit
          .toStringAsFixed(0);
      _rateController.text = (widget.taxProfile.additionalTaxRate * 100)
          .toStringAsFixed(1);
    }
    if (widget.companyProfile != oldWidget.companyProfile) {
      _companyNameController.text = widget.companyProfile.name;
      _companyShortNameController.text = widget.companyProfile.shortName;
      _companyPibController.text = widget.companyProfile.pib;
      _companyAddressController.text = widget.companyProfile.address;
      _companyAccountController.text = widget.companyProfile.accountNumber;
      _companyResponsibleController.text =
          widget.companyProfile.responsiblePerson;
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _pensionController.dispose();
    _healthController.dispose();
    _taxController.dispose();
    _limitController.dispose();
    _rollingLimitController.dispose();
    _rateController.dispose();
    _companyNameController.dispose();
    _companyShortNameController.dispose();
    _companyPibController.dispose();
    _companyAddressController.dispose();
    _companyAccountController.dispose();
    _companyResponsibleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    double parseAmount(String input) {
      return double.parse(input.trim().replaceAll(',', '.'));
    }

    final updatedProfile = widget.taxProfile.copyWith(
      city: _cityController.text.trim(),
      monthlyPension: parseAmount(_pensionController.text),
      monthlyHealth: parseAmount(_healthController.text),
      monthlyTaxPrepayment: parseAmount(_taxController.text),
      annualLimit: parseAmount(_limitController.text),
      rollingLimit: parseAmount(_rollingLimitController.text),
      additionalTaxRate: parseAmount(_rateController.text) / 100,
    );

    final updatedCompany = widget.companyProfile.copyWith(
      name: _companyNameController.text.trim(),
      shortName: _companyShortNameController.text.trim(),
      responsiblePerson: _companyResponsibleController.text.trim(),
      pib: _companyPibController.text.trim(),
      address: _companyAddressController.text.trim(),
      accountNumber: _companyAccountController.text.trim(),
    );

    widget.onProfilesChanged(updatedProfile, updatedCompany);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Podaci sačuvani')));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Podaci o firmi',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _companyNameController,
            decoration: const InputDecoration(
              labelText: 'Naziv firme',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Unesite naziv';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyShortNameController,
            decoration: const InputDecoration(
              labelText: 'Skraćeni naziv (opciono)',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyResponsibleController,
            decoration: const InputDecoration(
              labelText: 'Odgovorno lice',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyPibController,
            decoration: const InputDecoration(
              labelText: 'PIB',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyAddressController,
            decoration: const InputDecoration(
              labelText: 'Adresa',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _companyAccountController,
            decoration: const InputDecoration(
              labelText: 'Broj računa',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Poreski podaci paušala',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Grad',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _pensionController,
            decoration: const InputDecoration(
              labelText: 'PIO doprinos (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _healthController,
            decoration: const InputDecoration(
              labelText: 'Zdravstveno osiguranje (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _taxController,
            decoration: const InputDecoration(
              labelText: 'Akontacija poreza (mesečno)',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _limitController,
            decoration: const InputDecoration(
              labelText: 'Godišnji limit prihoda',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rollingLimitController,
            decoration: const InputDecoration(
              labelText: 'Limit u poslednjih 12 meseci',
              suffixText: 'RSD',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: validatePositiveNumber,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _rateController,
            decoration: const InputDecoration(
              labelText: 'Dodatni porez (u %)',
              suffixText: '%',
              border: OutlineInputBorder(),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              final parsed = double.tryParse(value ?? '');
              if (parsed == null || parsed < 0) {
                return 'Unesite broj veći ili jednak nuli';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Sačuvaj promene'),
            ),
          ),
        ],
      ),
    );
  }
}
