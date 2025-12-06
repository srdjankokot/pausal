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
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Podešavanje profila',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ažurirajte podatke o vašoj firmi.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Company Info Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PODACI O FIRMI',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _companyNameController,
                                label: 'Naziv firme',
                                isRequired: true,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Unesite naziv';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _companyAddressController,
                                label: 'Adresa firme',
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'Grad',
                                isRequired: true,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextField(
                              controller: _companyNameController,
                              label: 'Naziv firme',
                              isRequired: true,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite naziv';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _companyAddressController,
                              label: 'Adresa firme',
                              isRequired: true,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _cityController,
                              label: 'Grad',
                              isRequired: true,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 24),

              // Legal Identification Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRAVNA IDENTIFIKACIJA',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _companyResponsibleController,
                                label: 'Odgovorno lice',
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _companyPibController,
                                label: 'PIB',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _companyAccountController,
                                label: 'Broj računa',
                                isRequired: true,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextField(
                              controller: _companyResponsibleController,
                              label: 'Odgovorno lice',
                              isRequired: true,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _companyPibController,
                              label: 'PIB',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _companyAccountController,
                              label: 'Broj računa',
                              isRequired: true,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 24),

              // Mandatory Contributions Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OBAVEZNI DOPRINOSI',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _pensionController,
                                label: 'PIO doprinos (mesečno)',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: validatePositiveNumber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _healthController,
                                label: 'Zdravstveno osiguranje',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: validatePositiveNumber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _taxController,
                                label: 'Akontacija poreza (mesečno)',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: validatePositiveNumber,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextField(
                              controller: _pensionController,
                              label: 'PIO doprinos (mesečno)',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: validatePositiveNumber,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _healthController,
                              label: 'Zdravstveno osiguranje',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: validatePositiveNumber,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _taxController,
                              label: 'Akontacija poreza (mesečno)',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: validatePositiveNumber,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Divider(color: Colors.grey[300], thickness: 1),
              const SizedBox(height: 24),

              // Income & Limits Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIHOD I LIMIT',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[500],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _limitController,
                                label: 'Godišnji limit prihoda',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: validatePositiveNumber,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _rollingLimitController,
                                label: 'Limit u poslednjih 12 meseci',
                                isRequired: true,
                                keyboardType: TextInputType.number,
                                validator: validatePositiveNumber,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildTextField(
                              controller: _limitController,
                              label: 'Godišnji limit prihoda',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: validatePositiveNumber,
                            ),
                            const SizedBox(height: 20),
                            _buildTextField(
                              controller: _rollingLimitController,
                              label: 'Limit u poslednjih 12 meseci',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                              validator: validatePositiveNumber,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Save Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Sačuvaj promene',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF111111),
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: 'Ime postojećeg klijenta',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF111111), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
