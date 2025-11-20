import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pausal_calculator/screens/app/add_client.dart';
import 'package:pausal_calculator/screens/app/add_entry_sheet.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/client_share.dart';
import 'package:pausal_calculator/screens/app/company_profile.dart';
import 'package:pausal_calculator/screens/app/connect_sheet_placeholder.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/tabs/client/client_tab.dart';
import 'package:pausal_calculator/screens/app/tabs/ledger/ledger_tab.dart';
import 'package:pausal_calculator/screens/app/tabs/overview/overview_tab.dart';
import 'package:pausal_calculator/screens/app/tabs/seetings/settings_tab.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';
import 'package:pausal_calculator/screens/spreadsheet_config.dart';
import 'package:pausal_calculator/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../constants/app_constants.dart';
import '../../services/google_auth_service.dart';
import '../../services/google_picker_service.dart';
import '../../services/google_sheets_service.dart';
import '../../storage/sync_metadata_storage.dart';

class PausalHome extends StatefulWidget {
  const PausalHome({super.key});

  @override
  State<PausalHome> createState() => _PausalHomeState();
}

class _PausalHomeState extends State<PausalHome> {
  int _currentIndex = 0;

  String? _spreadsheetId;
  String _expensesSheetName = 'Expenses';
  String _clientsSheetName = 'Clients';
  String _profileSheetName = 'Profile';
  String? _googleUserEmail;
  bool _isConnecting = false;

  bool get _isConnected => _sheetsService != null;

  bool _ensureConnected() {
    if (_isConnected) {
      return true;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Povežite Google Sheets pre nego što dodate podatke.'),
        ),
      );
    }
    return false;
  }

  String? _extractSpreadsheetId(String? raw) {
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final urlPattern = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final urlMatch = urlPattern.firstMatch(trimmed);
    if (urlMatch != null) {
      return urlMatch.group(1);
    }
    final idPattern = RegExp(r'^[a-zA-Z0-9-_]{10,}$');
    if (idPattern.hasMatch(trimmed)) {
      return trimmed;
    }
    return null;
  }

  CompanyProfile _companyProfile = const CompanyProfile(
    name: '',
    shortName: '',
    responsiblePerson: '',
    pib: '',
    address: '',
    accountNumber: '',
  );

  List<Client> _clients = [];

  List<LedgerEntry> _entries = [];

  TaxProfile _profile = const TaxProfile(
    city: '',
    monthlyPension: 0,
    monthlyHealth: 0,
    monthlyTaxPrepayment: 0,
    annualLimit: 6000000,
    rollingLimit: 8000000,
    additionalTaxRate: 0,
  );

  final GoogleAuthService _authService = GoogleAuthService(
    webClientId: kGoogleWebClientId,
  );
  GoogleSheetsService? _sheetsService;
  GoogleUser? _googleUser;
  bool _isSyncing = false;
  bool _isUploading = false;
  final Set<SheetSyncTarget> _pendingSyncTargets = <SheetSyncTarget>{};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      Future.microtask(_restoreSessionSilently);
    }
  }

  @override
  void dispose() {
    _sheetsService?.close();
    super.dispose();
  }

  void _addEntry(LedgerEntry entry) {
    if (!_ensureConnected()) return;
    setState(() {
      _entries.add(entry);
      _entries.sort((a, b) => b.date.compareTo(a.date));
    });
    _pushDataToSheets({SheetSyncTarget.entries});
  }

  void _updateEntry(LedgerEntry updated) {
    if (!_ensureConnected()) return;
    setState(() {
      final index = _entries.indexWhere((entry) => entry.id == updated.id);
      if (index != -1) {
        _entries[index] = updated;
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
    });
    _pushDataToSheets({SheetSyncTarget.entries});
  }

  void _removeEntry(String id) {
    if (!_ensureConnected()) return;
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
    _pushDataToSheets({SheetSyncTarget.entries});
  }

  void _updateProfiles({
    TaxProfile? taxProfile,
    CompanyProfile? companyProfile,
  }) {
    if (taxProfile == null && companyProfile == null) {
      return;
    }
    if (!_ensureConnected()) return;
    setState(() {
      if (taxProfile != null) {
        _profile = taxProfile;
      }
      if (companyProfile != null) {
        _companyProfile = companyProfile;
      }
    });
    _pushDataToSheets({SheetSyncTarget.profile});
  }

  void _updateBothProfiles(
    TaxProfile taxProfile,
    CompanyProfile companyProfile,
  ) {
    _updateProfiles(taxProfile: taxProfile, companyProfile: companyProfile);
  }

  void _addClient(Client client) {
    if (!_ensureConnected()) return;
    setState(() {
      _clients.add(client);
      _clients.sort((a, b) => a.name.compareTo(b.name));
    });
    _pushDataToSheets({SheetSyncTarget.clients});
  }

  void _updateClient(Client updated) {
    if (!_ensureConnected()) return;
    setState(() {
      final index = _clients.indexWhere((client) => client.id == updated.id);
      if (index != -1) {
        _clients[index] = updated;
        _clients.sort((a, b) => a.name.compareTo(b.name));
      }
    });
    _pushDataToSheets({SheetSyncTarget.clients});
  }

  void _removeClient(String id) {
    if (!_ensureConnected()) return;
    setState(() {
      _clients.removeWhere((client) => client.id == id);
      for (var i = 0; i < _entries.length; i++) {
        final entry = _entries[i];
        if (entry.clientId == id) {
          _entries[i] = entry.copyWith(clientId: null);
        }
      }
    });
    _pushDataToSheets({SheetSyncTarget.clients, SheetSyncTarget.entries});
  }

  void _pushDataToSheets(Set<SheetSyncTarget> targets) {
    if (targets.isEmpty) {
      return;
    }
    _pendingSyncTargets.addAll(targets);
    _uploadPendingSheets();
  }

  void _uploadPendingSheets() {
    final service = _sheetsService;
    if (service == null || _pendingSyncTargets.isEmpty || _isUploading) {
      return;
    }

    final targetsToUpload = Set<SheetSyncTarget>.from(_pendingSyncTargets);
    _pendingSyncTargets.clear();
    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    } else {
      _isUploading = true;
    }
    Future.microtask(() async {
      try {
        await service.uploadAll(
          entries: targetsToUpload.contains(SheetSyncTarget.entries)
              ? _entries.map((entry) => entry.toJson()).toList()
              : null,
          clients: targetsToUpload.contains(SheetSyncTarget.clients)
              ? _clients.map((client) => client.toJson()).toList()
              : null,
          companyProfile: targetsToUpload.contains(SheetSyncTarget.profile)
              ? _companyProfile.toJson()
              : null,
          taxProfile: targetsToUpload.contains(SheetSyncTarget.profile)
              ? _profile.toJson()
              : null,
        );
      } catch (error, stack) {
        debugPrint('Google Sheets sync failed: $error');
        debugPrint('$stack');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Neuspešna sinhronizacija sa Google Sheets.'),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        } else {
          _isUploading = false;
        }
        if (_pendingSyncTargets.isNotEmpty) {
          _uploadPendingSheets();
        }
      }
    });
  }

  Future<void> _restoreSessionSilently() async {
    SyncMetadata? metadata;
    try {
      metadata = await SyncMetadataStorage.load();
    } catch (error, stack) {
      debugPrint('Failed to load sync metadata: $error');
      debugPrint('$stack');
    }

    if (!mounted) {
      return;
    }

    if (metadata == null) {
      setState(() {
        _isConnecting = false;
      });
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    _spreadsheetId = metadata.spreadsheetId;
    _expensesSheetName = metadata.expensesSheet;
    _clientsSheetName = metadata.clientsSheet;
    _profileSheetName = metadata.profileSheet;

    try {
      final user = await _authService.signInSilently().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (user == null) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      final client = await _authService.getAuthenticatedClient().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (client == null) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      final service = GoogleSheetsService(
        client: client,
        spreadsheetId: _spreadsheetId!,
        expensesSheet: _expensesSheetName,
        clientsSheet: _clientsSheetName,
        profileSheet: _profileSheetName,
      );

      await service.ensureStructure();

      final remoteEntries = await service.fetchEntries();
      final remoteClients = await service.fetchClients();
      final remoteProfiles = await service.fetchProfiles();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _googleUser = user;
        _googleUserEmail = user.email;
        _sheetsService = service;
        _entries =
            remoteEntries
                .map(
                  (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        _clients =
            remoteClients
                .map((map) => Client.fromJson(Map<String, dynamic>.from(map)))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        final companyData = remoteProfiles['company'];
        if (companyData != null && companyData.isNotEmpty) {
          _companyProfile = CompanyProfile.fromJson(
            Map<String, dynamic>.from(companyData),
          );
        }
        final taxData = remoteProfiles['tax'];
        if (taxData != null && taxData.isNotEmpty) {
          _profile = TaxProfile.fromJson(Map<String, dynamic>.from(taxData));
        }
      });
    } catch (error, stack) {
      debugPrint('Silent session restore failed: $error');
      debugPrint('$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Automatsko povezivanje Google Sheets naloga nije uspelo.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Client? _findClient(String? id) {
    if (id == null) {
      return null;
    }
    try {
      return _clients.firstWhere((client) => client.id == id);
    } catch (_) {
      return null;
    }
  }

  void _openEntrySheet({LedgerEntry? entry}) {
    if (!_ensureConnected()) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AddEntrySheet(
          initialEntry: entry,
          onSubmit: entry == null ? _addEntry : _updateEntry,
          onDelete: entry == null ? null : () => _removeEntry(entry.id),
          clients: _clients,
          existingEntries: _entries,
          onCreateClient: _addClient,
        );
      },
    );
  }

  void _openClientSheet({Client? client}) {
    if (!_ensureConnected()) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return AddClientSheet(
          initialClient: client,
          onSubmit: client == null ? _addClient : _updateClient,
          onDelete: client == null ? null : () => _removeClient(client.id),
        );
      },
    );
  }

  Future<void> _printInvoice(LedgerEntry entry) async {
    final client = _findClient(entry.clientId);
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodajte klijenta pre štampe fakture.')),
      );
      return;
    }

    final pdfData = await buildInvoicePdf(
      entry,
      client,
      _companyProfile,
      _profile,
    );
    await Printing.layoutPdf(
      onLayout: (_) async => pdfData,
      name: '${sanitizeFileName(entry.title)}.pdf',
    );
  }

  Future<void> _shareInvoice(LedgerEntry entry) async {
    final client = _findClient(entry.clientId);
    if (client == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dodajte klijenta pre slanja fakture.')),
      );
      return;
    }

    final pdfData = await buildInvoicePdf(
      entry,
      client,
      _companyProfile,
      _profile,
    );
    final fileName = '${sanitizeFileName(entry.title)}.pdf';
    final shareFile = XFile.fromData(
      pdfData,
      name: fileName,
      mimeType: 'application/pdf',
    );
    await Share.shareXFiles(
      [shareFile],
      subject: entry.title,
      text:
          'Faktura ${entry.invoiceNumber?.isNotEmpty == true ? entry.invoiceNumber : entry.title} za ${client.name} iznosi ${formatCurrency(entry.amount)}.\nUplata na račun: ${_companyProfile.accountNumber}.',
    );
  }

  Future<void> _connectGoogleSheets() async {
    if (_isSyncing) {
      return;
    }
    setState(() {
      _isSyncing = true;
      _isConnecting = true;
    });
    GoogleSheetsService? service;
    try {
      final user = await _authService.signIn();
      if (user == null) {
        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }

      final config = await _promptForSpreadsheetConfig();
      if (config == null) {
        await _authService.signOut();
        if (mounted) {
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }
      final client = await _authService.getAuthenticatedClient().timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (client == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Greška pri autentifikaciji Google naloga.'),
            ),
          );
          setState(() {
            _isSyncing = false;
            _isConnecting = false;
          });
        }
        return;
      }

      _sheetsService?.close();
      final expensesSheet = config.expensesSheet;
      final clientsSheet = config.clientsSheet;
      final profileSheet = config.profileSheet;
      final spreadsheetId = config.createNew
          ? await GoogleSheetsService.createSpreadsheet(
              client: client,
              title: config.spreadsheetTitle!,
              expensesSheet: expensesSheet,
              clientsSheet: clientsSheet,
              profileSheet: profileSheet,
            )
          : config.spreadsheetId!;

      service = GoogleSheetsService(
        client: client,
        spreadsheetId: spreadsheetId,
        expensesSheet: expensesSheet,
        clientsSheet: clientsSheet,
        profileSheet: profileSheet,
      );

      await service.ensureStructure();

      final remoteEntries = await service.fetchEntries();
      final remoteClients = await service.fetchClients();
      final remoteProfiles = await service.fetchProfiles();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _entries =
            remoteEntries
                .map(
                  (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
                )
                .toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        _clients =
            remoteClients
                .map((map) => Client.fromJson(Map<String, dynamic>.from(map)))
                .toList()
              ..sort((a, b) => a.name.compareTo(b.name));
        _googleUser = user;
        _googleUserEmail = user.email;
        _sheetsService = service;
        _spreadsheetId = spreadsheetId;
        _expensesSheetName = expensesSheet;
        _clientsSheetName = clientsSheet;
        _profileSheetName = profileSheet;
        _isSyncing = false;
        _isConnecting = false;
        final companyData = remoteProfiles['company'];
        if (companyData != null && companyData.isNotEmpty) {
          _companyProfile = CompanyProfile.fromJson(
            Map<String, dynamic>.from(companyData),
          );
        }
        final taxData = remoteProfiles['tax'];
        if (taxData != null && taxData.isNotEmpty) {
          _profile = TaxProfile.fromJson(Map<String, dynamic>.from(taxData));
        }
      });
      await SyncMetadataStorage.save(
        spreadsheetId: spreadsheetId,
        expensesSheet: expensesSheet,
        clientsSheet: clientsSheet,
        profileSheet: profileSheet,
      );
      if (config.createNew) {
        _pushDataToSheets(SheetSyncTarget.values.toSet());
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            config.createNew
                ? 'Kreiran je novi Google Sheet (${spreadsheetId}).'
                : 'Google Sheets sinhronizacija aktivirana (${spreadsheetId}).',
          ),
        ),
      );
    } catch (error, stack) {
      debugPrint('Failed to connect Google Sheets: $error');
      debugPrint('$stack');
      service?.close();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Neuspešno povezivanje sa Google Sheets.'),
          ),
        );
        setState(() {
          _isSyncing = false;
          _isConnecting = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      } else {
        _isConnecting = false;
      }
    }
  }

  Future<void> _disconnectGoogleSheets() async {
    // _sheetsService?.close();
    await _authService.signOut();
    await SyncMetadataStorage.clear();
    setState(() {
      _googleUser = null;
      _googleUserEmail = null;
      _sheetsService = null;
      _isConnecting = false;
      _isSyncing = false;
      _spreadsheetId = null;
      _expensesSheetName = 'Expenses';
      _clientsSheetName = 'Clients';
      _profileSheetName = 'Profile';
      _entries = [];
      _clients = [];
    });
  }

  Future<SpreadsheetConfig?> _promptForSpreadsheetConfig() async {
    final idController = TextEditingController(text: _spreadsheetId ?? '');
    final titleController = TextEditingController(text: 'Paušal kalkulator');
    final expensesController = TextEditingController(text: _expensesSheetName);
    final clientsController = TextEditingController(text: _clientsSheetName);
    final profileController = TextEditingController(text: _profileSheetName);
    final formKey = GlobalKey<FormState>();
    bool createNew = _spreadsheetId == null || _spreadsheetId!.isEmpty;
    String? pickedSpreadsheetName =
        (_spreadsheetId != null && _spreadsheetId!.isNotEmpty)
        ? _spreadsheetId
        : null;
    bool isPickingSpreadsheet = false;
    var isDialogMounted = true;

    final result =
        await showDialog<SpreadsheetConfig>(
          context: context,
          builder: (dialogContext) {
            return StatefulBuilder(
              builder: (dialogContext, setDialogState) {
                Future<void> launchPicker() async {
                  if (!kIsWeb) {
                    return;
                  }
                  if (kGooglePickerApiKey.isEmpty) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Google Picker API ključ nije konfigurisan.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  final token = await _authService.getActiveAccessToken();
                  if (token == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Greška pri autentifikaciji Google naloga.',
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  if (!isDialogMounted) {
                    return;
                  }
                  setDialogState(() {
                    isPickingSpreadsheet = true;
                  });
                  final pickerService = GooglePickerService(
                    apiKey: kGooglePickerApiKey,
                  );
                  try {
                    final selection = await pickerService.pickSpreadsheet(
                      oauthToken: token,
                    );
                    if (selection != null && isDialogMounted) {
                      setDialogState(() {
                        pickedSpreadsheetName = selection.name;
                        idController.text = selection.id;
                      });
                    }
                  } catch (error, stack) {
                    debugPrint('Failed to open Google Picker: $error');
                    debugPrint('$stack');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nije moguće učitati Google Picker. Pokušajte ponovo.',
                          ),
                        ),
                      );
                    }
                  } finally {
                    if (isDialogMounted) {
                      setDialogState(() {
                        isPickingSpreadsheet = false;
                      });
                    }
                  }
                }

                return AlertDialog(
                  title: const Text('Povezivanje sa Google Sheet-om'),
                  content: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            value: createNew,
                            title: const Text('Kreiraj novi Google Sheet'),
                            subtitle: const Text(
                              'Aplikacija će automatski kreirati dokument i radne listove.',
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                createNew = value;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          if (createNew)
                            TextFormField(
                              controller: titleController,
                              decoration: const InputDecoration(
                                labelText: 'Naziv dokumenta',
                                hintText: 'Paušal kalkulator',
                              ),
                              validator: (value) {
                                if (!createNew) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Unesite naziv dokumenta';
                                }
                                return null;
                              },
                            )
                          else if (kIsWeb)
                            TextFormField(
                              controller: idController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Google Sheet dokument',
                                hintText: 'Izaberite Google Sheets dokument',
                                helperText: pickedSpreadsheetName == null
                                    ? 'Kliknite na ikonu desno kako biste izabrali dokument.'
                                    : 'Odabrano: $pickedSpreadsheetName',
                                suffixIcon: IconButton(
                                  tooltip: 'Izaberi iz Google Drive-a',
                                  onPressed:
                                      isPickingSpreadsheet ||
                                          kGooglePickerApiKey.isEmpty
                                      ? null
                                      : () {
                                          FocusScope.of(
                                            dialogContext,
                                          ).unfocus();
                                          unawaited(launchPicker());
                                        },
                                  icon: isPickingSpreadsheet
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.folder_open),
                                ),
                              ),
                              onTap:
                                  isPickingSpreadsheet ||
                                      kGooglePickerApiKey.isEmpty
                                  ? null
                                  : () {
                                      FocusScope.of(dialogContext).unfocus();
                                      unawaited(launchPicker());
                                    },
                              validator: (value) {
                                if (createNew) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Izaberite Google Sheet dokument';
                                }
                                return null;
                              },
                            )
                          else
                            TextFormField(
                              controller: idController,
                              decoration: const InputDecoration(
                                labelText: 'Spreadsheet URL ili ID',
                                hintText:
                                    'https://docs.google.com/... ili 1A2B3C...',
                              ),
                              validator: (value) {
                                if (createNew) {
                                  return null;
                                }
                                if (_extractSpreadsheetId(value) == null) {
                                  return 'Unesite pun URL ili ID Google Sheets dokumenta';
                                }
                                return null;
                              },
                            ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: expensesController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za troškove',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: clientsController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za klijente',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: profileController,
                            decoration: const InputDecoration(
                              labelText: 'Sheet za profil',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text('Otkaži'),
                    ),
                    FilledButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() != true) {
                          return;
                        }
                        final expensesSheet =
                            expensesController.text.trim().isEmpty
                            ? 'Expenses'
                            : expensesController.text.trim();
                        final clientsSheet =
                            clientsController.text.trim().isEmpty
                            ? 'Clients'
                            : clientsController.text.trim();
                        final profileSheet =
                            profileController.text.trim().isEmpty
                            ? 'Profile'
                            : profileController.text.trim();
                        final parsedId = _extractSpreadsheetId(
                          idController.text,
                        );
                        final config = createNew
                            ? SpreadsheetConfig(
                                createNew: true,
                                spreadsheetTitle: titleController.text.trim(),
                                expensesSheet: expensesSheet,
                                clientsSheet: clientsSheet,
                                profileSheet: profileSheet,
                              )
                            : SpreadsheetConfig(
                                createNew: false,
                                spreadsheetId: parsedId!,
                                expensesSheet: expensesSheet,
                                clientsSheet: clientsSheet,
                                profileSheet: profileSheet,
                              );
                        Navigator.of(dialogContext).pop(config);
                      },
                      child: const Text('Poveži'),
                    ),
                  ],
                );
              },
            );
          },
        ).whenComplete(() {
          isDialogMounted = false;
        });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isWideLayout = mediaQuery.size.width >= 900;
    final isRailExtended = mediaQuery.size.width >= 1200;
    final theme = Theme.of(context);

    final screens = _isConnected
        ? [
            OverviewTab(
              entries: _entries,
              profile: _profile,
              clients: _clients,
            ),
            LedgerTab(
              entries: _entries,
              clients: _clients,
              onRemove: _removeEntry,
              onEdit: (entry) => _openEntrySheet(entry: entry),
              onShareInvoice: _shareInvoice,
              onPrintInvoice: _printInvoice,
              findClient: _findClient,
            ),
            ClientsTab(
              clients: _clients,
              entries: _entries,
              onAddClient: () => _openClientSheet(),
              onEditClient: (client) => _openClientSheet(client: client),
              onDeleteClient: _removeClient,
            ),
            SettingsTab(
              taxProfile: _profile,
              companyProfile: _companyProfile,
              onProfilesChanged: _updateBothProfiles,
              isConnected: true,
              isSyncing: _isSyncing || _isConnecting,
              spreadsheetId: _spreadsheetId,
              expensesSheet: _expensesSheetName,
              clientsSheet: _clientsSheetName,
              profileSheet: _profileSheetName,
              userEmail: _googleUserEmail,
              onConnectSheets: _connectGoogleSheets,
              onDisconnectSheets: _disconnectGoogleSheets,
            ),
          ]
        : [
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
            ),
            SettingsTab(
              taxProfile: _profile,
              companyProfile: _companyProfile,
              onProfilesChanged: _updateBothProfiles,
              isConnected: false,
              isSyncing: _isSyncing || _isConnecting,
              spreadsheetId: _spreadsheetId,
              expensesSheet: _expensesSheetName,
              clientsSheet: _clientsSheetName,
              profileSheet: _profileSheetName,
              userEmail: _googleUserEmail,
              onConnectSheets: _connectGoogleSheets,
              onDisconnectSheets: _disconnectGoogleSheets,
            ),
          ];

    Widget? floatingActionButton;
    if (_isConnected) {
      if (_currentIndex == 0 || _currentIndex == 1) {
        floatingActionButton = FloatingActionButton.extended(
          onPressed: () => _openEntrySheet(),
          icon: const Icon(Icons.add),
          label: const Text('Nova stavka'),
        );
      } else if (_currentIndex == 2) {
        floatingActionButton = FloatingActionButton.extended(
          onPressed: () => _openClientSheet(),
          icon: const Icon(Icons.person_add),
          label: const Text('Novi klijent'),
        );
      }
    }

    final scaffold = Scaffold(
      body: isWideLayout
          ? Row(
              children: [
                NavigationRail(
                  extended: isRailExtended,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                  },
                  labelType: isRailExtended
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  leading: const SizedBox(height: 8),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard),
                      label: Text('Pregled'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long_outlined),
                      selectedIcon: Icon(Icons.receipt_long),
                      label: Text('Knjiga'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.people_alt_outlined),
                      selectedIcon: Icon(Icons.people),
                      label: Text('Klijenti'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: screens),
                ),
              ],
            )
          : IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: isWideLayout
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Pregled',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Knjiga',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Klijenti',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Profil',
                ),
              ],
            ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: isWideLayout
          ? FloatingActionButtonLocation.endFloat
          : FloatingActionButtonLocation.centerFloat,
    );

    return Stack(
      children: [
        scaffold,
        if (_isUploading)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                alignment: Alignment.center,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Snimam podatke u Google Sheets…',
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Molimo sačekajte dok se sinhronizacija ne završi.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}





