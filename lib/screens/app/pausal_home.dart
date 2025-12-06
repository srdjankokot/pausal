import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import '../../l10n/app_localizations.dart';
import '../../services/google_auth_service.dart';
import '../../services/google_picker_service.dart';
import '../../services/google_sheets_service.dart';
import '../../storage/sync_metadata_storage.dart';

class PausalHome extends StatefulWidget {
  final void Function(Locale)? onLanguageChange;

  const PausalHome({super.key, this.onLanguageChange});

  @override
  State<PausalHome> createState() => _PausalHomeState();
}

class _PausalHomeState extends State<PausalHome> {
  int _currentIndex = 0;
  bool _isSidebarCollapsed = false;

  String? _spreadsheetId;
  String _expensesSheetName = 'Expenses';
  String _clientsSheetName = 'Clients';
  String _profileSheetName = 'Profile';
  String? _googleUserEmail;
  bool _isConnecting = false;
  bool _isCheckingStructure = false;
  double _structureProgress = 0;
  String _structureStatus = '';

  bool get _isConnected => _sheetsService != null;

  bool _ensureConnected() {
    if (_isConnected) {
      return true;
    }
    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.connectBeforeData),
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

  void _setStructureProgress(String status, double progress) {
    if (!mounted) return;
    setState(() {
      _isCheckingStructure = true;
      _structureStatus = status;
      _structureProgress = progress.clamp(0, 1);
    });
  }

  void _resetStructureProgress() {
    if (!mounted) return;
    setState(() {
      _isCheckingStructure = false;
      _structureStatus = '';
      _structureProgress = 0;
    });
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.syncFailed),
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
      final user = await _authService.restorePersistedUser().timeout(
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.sessionExpired),
            ),
          );
          setState(() {
            _isConnecting = false;
          });
        }
        return;
      }

      print(client);

      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      final service = GoogleSheetsService(
        client: client,
        spreadsheetId: _spreadsheetId!,
        expensesSheet: _expensesSheetName,
        clientsSheet: _clientsSheetName,
        profileSheet: _profileSheetName,
      );

      _setStructureProgress(l10n.checkingStructure, 0.2);
      await service.ensureStructure(
        onSheet: (sheetName, progress) {
          _setStructureProgress(
            l10n.checkingSheetStructure(sheetName),
            progress,
          );
        },
      );
      _setStructureProgress(l10n.loadingInvoices, 0.6);
      final remoteEntries = await service.fetchEntries();
      _setStructureProgress(l10n.loadingClients, 0.75);
      final remoteClients = await service.fetchClients();
      _setStructureProgress(l10n.loadingProfile, 0.9);
      final remoteProfiles = await service.fetchProfiles();
      _setStructureProgress(l10n.syncCompleted, 1);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _resetStructureProgress();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _googleUser = user;
        _googleUserEmail = user.email;
        _sheetsService = service;
        _entries = remoteEntries
            .map(
              (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _clients = remoteClients
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.autoConnectFailed),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
      _resetStructureProgress();
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addClientBeforePrint)),
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
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addClientBeforeSend)),
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

    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    await Share.shareXFiles(
      [shareFile],
      subject: entry.title,
      text: l10n.invoiceShareText(
        entry.invoiceNumber?.isNotEmpty == true ? entry.invoiceNumber! : entry.title,
        client.name,
        formatCurrency(entry.amount),
        _companyProfile.accountNumber,
      ),
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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.authError),
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

      if (!mounted) {
        service.close();
        return;
      }

      final l10n = AppLocalizations.of(context)!;
      _setStructureProgress(l10n.checkingStructure, 0.2);
      await service.ensureStructure(
        onSheet: (sheetName, progress) {
          _setStructureProgress(
            l10n.checkingSheetStructure(sheetName),
            progress,
          );
        },
      );
      _setStructureProgress(l10n.structureConfirmed, 0.6);
      final remoteEntries = await service.fetchEntries();
      _setStructureProgress(l10n.loadingClients, 0.75);
      final remoteClients = await service.fetchClients();
      _setStructureProgress(l10n.loadingProfile, 0.9);
      final remoteProfiles = await service.fetchProfiles();
      _setStructureProgress(l10n.syncCompleted, 1);
      await Future<void>.delayed(const Duration(milliseconds: 200));
      _resetStructureProgress();

      if (!mounted) {
        service.close();
        return;
      }

      setState(() {
        _entries = remoteEntries
            .map(
              (map) => LedgerEntry.fromJson(Map<String, dynamic>.from(map)),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        _clients = remoteClients
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

      if (!mounted) return;
      final l10nSuccess = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            config.createNew
                ? l10nSuccess.sheetCreatedSuccess(spreadsheetId)
                : l10nSuccess.sheetConnectedSuccess(spreadsheetId),
          ),
        ),
      );
    } catch (error, stack) {
      debugPrint('Failed to connect Google Sheets: $error');
      debugPrint('$stack');
      service?.close();
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.connectFailed),
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
      _resetStructureProgress();
    }
  }

  Future<void> _disconnectGoogleSheets() async {
    try {
      final sheetsService = _sheetsService;
      _sheetsService = null;
      sheetsService?.close();
      await _authService.signOut();
      await SyncMetadataStorage.clear();
    } catch (error, stack) {
      debugPrint('Error during sign out: $error');
      debugPrint('$stack');
    } finally {
      // Always update state to ensure UI reflects logged-out state
      if (mounted) {
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
    }
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

    if (!mounted) return null;
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<SpreadsheetConfig>(
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
                    SnackBar(
                      content: Text(l10n.pickerApiKeyNotConfigured),
                    ),
                  );
                }
                return;
              }
              final token = await _authService.getActiveAccessToken();
              if (token == null) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.authError),
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
                    SnackBar(
                      content: Text(l10n.pickerLoadError),
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
              title: Text(l10n.connectDialogTitle),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: createNew,
                        title: Text(l10n.createNewSheet),
                        subtitle: Text(l10n.createNewSheetSubtitle),
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
                          decoration: InputDecoration(
                            labelText: l10n.documentName,
                            hintText: l10n.documentNameHint,
                          ),
                          validator: (value) {
                            if (!createNew) {
                              return null;
                            }
                            if (value == null || value.trim().isEmpty) {
                              return l10n.enterDocumentName;
                            }
                            return null;
                          },
                        )
                      else if (kIsWeb)
                        TextFormField(
                          controller: idController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: l10n.googleSheetDocument,
                            hintText: l10n.selectGoogleSheetDocument,
                            helperText: pickedSpreadsheetName == null
                                ? l10n.clickToSelectDocument
                                : l10n.selected(pickedSpreadsheetName!),
                            suffixIcon: IconButton(
                              tooltip: l10n.selectFromDrive,
                              onPressed: isPickingSpreadsheet ||
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
                          onTap: isPickingSpreadsheet ||
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
                              return l10n.selectGoogleSheetDocument;
                            }
                            return null;
                          },
                        )
                      else
                        TextFormField(
                          controller: idController,
                          decoration: InputDecoration(
                            labelText: l10n.spreadsheetUrlOrId,
                            hintText: l10n.spreadsheetUrlHint,
                          ),
                          validator: (value) {
                            if (createNew) {
                              return null;
                            }
                            if (_extractSpreadsheetId(value) == null) {
                              return l10n.enterFullUrlOrId;
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: expensesController,
                        decoration: InputDecoration(
                          labelText: l10n.sheetForExpenses,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: clientsController,
                        decoration: InputDecoration(
                          labelText: l10n.sheetForClients,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: profileController,
                        decoration: InputDecoration(
                          labelText: l10n.sheetForProfile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (formKey.currentState?.validate() != true) {
                      return;
                    }
                    final expensesSheet = expensesController.text.trim().isEmpty
                        ? 'Expenses'
                        : expensesController.text.trim();
                    final clientsSheet = clientsController.text.trim().isEmpty
                        ? 'Clients'
                        : clientsController.text.trim();
                    final profileSheet = profileController.text.trim().isEmpty
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
                  child: Text(l10n.connect),
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
    final l10n = AppLocalizations.of(context)!;

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
              onOpenApp: () => Navigator.pushNamed(context, '/about'),
            ),
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
              onOpenApp: () => Navigator.pushNamed(context, '/about'),
            ),
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
              onOpenApp: () => Navigator.pushNamed(context, '/about'),
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
        floatingActionButton = _buildPrimaryFab(
          label: l10n.fabNewEntry,
          icon: Icons.add,
          onPressed: _openEntrySheet,
          heroTag: 'entryFab',
        );
      } else if (_currentIndex == 2) {
        floatingActionButton = _buildPrimaryFab(
          label: l10n.fabNewClient,
          icon: Icons.person_add,
          onPressed: _openClientSheet,
          heroTag: 'clientFab',
        );
      }
    }

    final scaffold = Scaffold(
      
      // appBar: isWideLayout ? null : AppBar(
      //   title: const Text(''),
      //   actions: [
      //     // Language selector (only shown on mobile)
      //     PopupMenuButton<Locale>(
      //       tooltip: 'Language / Jezik',
      //       icon: const Icon(Icons.language),
      //       onSelected: (locale) => widget.onLanguageChange?.call(locale),
      //       itemBuilder: (context) => [
      //         const PopupMenuItem(
      //           value: Locale('sr', ''),
      //           child: Text('🇷🇸 Srpski'),
      //         ),
      //         const PopupMenuItem(
      //           value: Locale('en', ''),
      //           child: Text('🇬🇧 English'),
      //         ),
      //       ],
      //     ),
      //     const SizedBox(width: 8),
      //   ],
      // ),
      body: isWideLayout
          ? Row(
              children: [
                Container(
                  width: _isSidebarCollapsed ? 92 : 240,
                  color: const Color(0xFF1E293B),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _isSidebarCollapsed ? 12 : 20,
                        ),
                        child: Row(
                          children: [

                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  'assets/images/pausal_logo.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            if (!_isSidebarCollapsed) ...[
                              const SizedBox(width: 12),
                              const Text(
                                'Pausal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                            ],
                            if (_isSidebarCollapsed) const Spacer(),
                            IconButton(
                              tooltip: _isSidebarCollapsed ? 'Proširi meni' : 'Sakrij meni',
                              onPressed: () {
                                setState(() {
                                  _isSidebarCollapsed = !_isSidebarCollapsed;
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              visualDensity: VisualDensity.compact,
                              icon: Transform.rotate(
                                angle: _isSidebarCollapsed ? 3.14159 : 0,
                                child: SvgPicture.asset(
                                  'assets/images/menu_back.svg',
                                  width: 20,
                                  height: 20,
                                  colorFilter: ColorFilter.mode(
                                    Colors.grey[300]!,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            _buildNavItem(
                              iconPath: 'assets/images/home.svg',
                              label: l10n.navOverview,
                              isSelected: _currentIndex == 0,
                              isCollapsed: _isSidebarCollapsed,
                              onTap: () => setState(() => _currentIndex = 0),
                            ),
                            _buildNavItem(
                              iconPath: 'assets/images/receipt.svg',
                              label: l10n.navLedger,
                              isSelected: _currentIndex == 1,
                              isCollapsed: _isSidebarCollapsed,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                            _buildNavItem(
                              iconPath: 'assets/images/profile_user.svg',
                              label: l10n.navClients,
                              isSelected: _currentIndex == 2,
                              isCollapsed: _isSidebarCollapsed,
                              onTap: () => setState(() => _currentIndex = 2),
                            ),
                            _buildNavItem(
                              iconPath: 'assets/images/setting.svg',
                              label: l10n.navProfile,
                              isSelected: _currentIndex == 3,
                              isCollapsed: _isSidebarCollapsed,
                              onTap: () => setState(() => _currentIndex = 3),
                            ),
                          ],
                        ),
                      ),
                      if (!_isSidebarCollapsed)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              // Language selector
                              // PopupMenuButton<Locale>(
                              //   tooltip: 'Language / Jezik',
                              //   onSelected: (locale) => widget.onLanguageChange?.call(locale),
                              //   offset: const Offset(0, -100),
                              //   itemBuilder: (context) => [
                              //     const PopupMenuItem(
                              //       value: Locale('sr', ''),
                              //       child: Row(
                              //         children: [
                              //           Text('🇷🇸'),
                              //           SizedBox(width: 8),
                              //           Text('Srpski'),
                              //         ],
                              //       ),
                              //     ),
                              //     const PopupMenuItem(
                              //       value: Locale('en', ''),
                              //       child: Row(
                              //         children: [
                              //           Text('🇬🇧'),
                              //           SizedBox(width: 8),
                              //           Text('English'),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              //   child: Container(
                              //     padding: const EdgeInsets.all(12),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white.withValues(alpha: 0.05),
                              //       borderRadius: BorderRadius.circular(8),
                              //     ),
                              //     child: Row(
                              //       children: [
                              //         Icon(
                              //           Icons.language,
                              //           color: Colors.grey[400],
                              //           size: 20,
                              //         ),
                              //         const SizedBox(width: 12),
                              //         Text(
                              //           Localizations.localeOf(context).languageCode == 'sr'
                              //               ? '🇷🇸 Srpski'
                              //               : '🇬🇧 English',
                              //           style: TextStyle(
                              //             color: Colors.grey[300],
                              //             fontSize: 14,
                              //           ),
                              //         ),
                              //         const Spacer(),
                              //         Icon(
                              //           Icons.keyboard_arrow_up,
                              //           color: Colors.grey[500],
                              //           size: 16,
                              //         ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // const SizedBox(height: 12),
                              // Container(
                              //   padding: const EdgeInsets.all(12),
                              //   decoration: BoxDecoration(
                              //     color: Colors.white.withValues(alpha: 0.05),
                              //     borderRadius: BorderRadius.circular(8),
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Icon(
                              //         Icons.help_outline,
                              //         color: Colors.grey[400],
                              //         size: 20,
                              //       ),
                              //       const SizedBox(width: 12),
                              //       Text(
                              //         'Pomoc i Podrška',
                              //         style: TextStyle(
                              //           color: Colors.grey[300],
                              //           fontSize: 14,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                            
                               _buildNavItem(
                              iconPath: 'assets/images/logout.svg',
                              label: l10n.navLogOut,
                              isSelected: _currentIndex == 4,
                              isCollapsed: _isSidebarCollapsed,
                              onTap: _disconnectGoogleSheets,
                            )
                            
                            ],
                          ),
                        ),
                      if (!_isSidebarCollapsed) const SizedBox(height: 20),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(12, 30, 41, 59),
                    child: IndexedStack(index: _currentIndex, children: screens),
                  ),
                ),
              ],
            )
          : Container(
              color: const Color.fromARGB(12, 30, 41, 59),
              child: IndexedStack(index: _currentIndex, children: screens),
            ),
      bottomNavigationBar: isWideLayout
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: [
                NavigationDestination(
                  icon: SvgPicture.asset(
                    'assets/images/home.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  selectedIcon: SvgPicture.asset(
                    'assets/images/home.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: l10n.navOverview,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    'assets/images/receipt.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  selectedIcon: SvgPicture.asset(
                    'assets/images/receipt.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: l10n.navLedger,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    'assets/images/profile_user.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  selectedIcon: SvgPicture.asset(
                    'assets/images/profile_user.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: l10n.navClients,
                ),
                NavigationDestination(
                  icon: SvgPicture.asset(
                    'assets/images/setting.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.grey[600]!,
                      BlendMode.srcIn,
                    ),
                  ),
                  selectedIcon: SvgPicture.asset(
                    'assets/images/setting.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.blue,
                      BlendMode.srcIn,
                    ),
                  ),
                  label: l10n.navProfile,
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
        if(_isConnected)
        scaffold,
        if(!_isConnected)
          Positioned.fill(
            child: 
            Container(
                color: Colors.white,
                alignment: Alignment.center,
                child:
            ConnectSheetPlaceholder(
              isConnecting: _isConnecting,
              onConnect: _connectGoogleSheets,
              onOpenApp: () => Navigator.pushNamed(context, '/about'),
            )))
          ,
        if (_isCheckingStructure)
          Positioned.fill(
            child: AbsorbPointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
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
                        horizontal: 28,
                        vertical: 22,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _structureStatus.isEmpty
                                ? l10n.syncingWithSheets
                                : _structureStatus,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: _structureProgress <= 0
                                ? null
                                : _structureProgress.clamp(0, 1),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  _structureStatus.isEmpty
                                      ? l10n.checkingSheetsHeaders
                                      : l10n.loadingData,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(_structureProgress * 100).clamp(0, 100).round()}%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
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
                          l10n.savingToSheets,
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.waitForSync,
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

  Widget _buildPrimaryFab({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    const buttonColor = Color(0xFF161C3A);

    return FloatingActionButton.extended(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: buttonColor,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      extendedPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      extendedIconLabelSpacing: 10,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required bool isSelected,
    required bool isCollapsed,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 12 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment:
                  isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 20,
                  height: 20,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.grey[400]!,
                    BlendMode.srcIn,
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
