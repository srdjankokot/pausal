# Localization Implementation Guide

## ✅ Completed

1. **Setup**
   - ✅ Added `flutter_localizations` and `intl` to `pubspec.yaml`
   - ✅ Created `l10n.yaml` configuration
   - ✅ Created ARB files for Serbian (`app_sr.arb`) and English (`app_en.arb`)
   - ✅ Generated localization code in `lib/l10n/app_localizations.dart`
   - ✅ Updated `main.dart` with localization delegates

2. **Completed File Migrations**
   - ✅ `lib/screens/landing_page.dart` - All strings replaced
   - ✅ `lib/screens/privacy_policy_page.dart` - All strings replaced
   - ✅ `lib/main.dart` - Localization enabled

## 🔨 Remaining Work

### Files That Need String Replacement

You need to add the l10n import and replace hardcoded strings in these files:

#### High Priority (Main App Flow)
1. **`lib/screens/app/pausal_home.dart`** - Main app screen with many strings
2. **`lib/screens/app/tabs/overview/overview_tab.dart`** - Dashboard/overview
3. **`lib/screens/app/tabs/ledger/ledger_tab.dart`** - Ledger/invoices tab
4. **`lib/screens/app/tabs/client/client_tab.dart`** - Clients tab
5. **`lib/screens/app/tabs/seetings/settings_tab.dart`** - Settings tab

#### Medium Priority (Forms and Dialogs)
6. **`lib/screens/app/add_entry_sheet.dart`** - Add invoice/expense form
7. **`lib/screens/app/add_client.dart`** - Add client form
8. **`lib/screens/app/profile_form.dart`** - Company/tax profile form
9. **`lib/screens/app/connect_sheet_placeholder.dart`** - Connection placeholder
10. **`lib/screens/app/google_sheet_card.dart`** - Google Sheets card

#### Low Priority (Components)
11. **`lib/screens/app/tabs/ledger/ledger_section.dart`** - Ledger section component
12. **`lib/screens/app/invoice_item_row.dart`** - Invoice item row
13. **`lib/screens/app/tabs/overview/overview_row.dart`** - Overview row (if has strings)
14. **`lib/screens/app/tabs/overview/contribution_row.dart`** - Contribution row (if has strings)

## 📝 How to Replace Strings in Each File

### Step 1: Add Import
At the top of each file, add:
```dart
import '../l10n/app_localizations.dart'; // Adjust path as needed
// or for deeper nested files:
import '../../l10n/app_localizations.dart';
import '../../../l10n/app_localizations.dart';
```

### Step 2: Get l10n Instance
In the `build` method, add:
```dart
final l10n = AppLocalizations.of(context)!;
```

### Step 3: Replace Hardcoded Strings
Replace:
```dart
const Text('Povežite Google Sheets nalog')
```

With:
```dart
Text(l10n.connectSheetHeading)
```

### Step 4: Replace Strings with Parameters
For strings with dynamic values, use the parameterized methods:

**Example 1: Simple parameter**
```dart
// Old:
Text('Faktura ${entry.invoiceNumber}')

// New:
Text(l10n.invoiceDetail(entry.invoiceNumber))
```

**Example 2: Multiple parameters**
```dart
// Old:
Text('Udeo: ${percent}% · Računi: $invoiceCount · $amount')

// New:
Text(l10n.clientStats(percent.toStringAsFixed(1), invoiceCount, amount))
```

**Example 3: SnackBar messages**
```dart
// Old:
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('Podaci sačuvani')),
);

// New:
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(l10n.dataSaved)),
);
```

## 🔑 Key ARB String Mappings

Here are the most commonly used strings:

### Buttons
- `save` - "Sačuvaj"
- `cancel` - "Otkaži"
- `delete` - "Obriši"
- `edit` - "Uredi"
- `connect` - "Poveži"

### Navigation
- `navOverview` - "Pregled"
- `navLedger` - "Knjiga"
- `navClients` - "Klijenti"
- `navProfile` - "Profil"

### Google Sheets
- `connectGoogleSheets` - "Poveži Google Sheets"
- `connectBeforeData` - "Povežite Google Sheets pre nego što dodate podatke."
- `syncCompleted` - "Sinhronizacija završena"
- `loadingInvoices` - "Učitavamo fakture..."
- `loadingClients` - "Učitavamo klijente..."

### Forms
- `newEntry` - "Nova stavka"
- `editEntry` - "Izmena stavke"
- `newClient` - "Novi klijent"
- `editClient` - "Izmena klijenta"
- `invoiceNumber` - "Broj fakture"
- `date` - "Datum"

### Errors
- `sessionExpired` - "Sesija je istekla. Prijavite se ponovo da biste nastavili."
- `authError` - "Greška pri autentifikaciji Google naloga."
- `syncFailed` - "Neuspešna sinhronizacija sa Google Sheets."

## 🧪 Testing

After completing the migration:

1. **Build the app:**
   ```bash
   flutter build web
   ```

2. **Run the app:**
   ```bash
   flutter run -d chrome
   ```

3. **Test language switching:**
   - The app will use the device/browser language by default
   - Serbian (sr) and English (en) are supported
   - To test English, change your browser language settings

## 📖 Reference Files

Look at these files as examples of completed migrations:
- `lib/screens/landing_page.dart`
- `lib/screens/privacy_policy_page.dart`

## 🌍 Adding More Languages

To add a new language (e.g., German):

1. Create `lib/l10n/app_de.arb`
2. Copy the structure from `app_en.arb`
3. Translate all strings to German
4. Update `main.dart` to include:
   ```dart
   supportedLocales: const [
     Locale('sr', ''),
     Locale('en', ''),
     Locale('de', ''), // Add this
   ],
   ```
5. Run `flutter pub get` to regenerate localization files

## 📚 ARB File Location

All translation strings are in:
- **Serbian:** `lib/l10n/app_sr.arb` (default/template)
- **English:** `lib/l10n/app_en.arb`

To modify or add strings:
1. Edit both ARB files
2. Run `flutter pub get` to regenerate
3. Use the new strings in your code with `l10n.yourNewKey`

## ⚠️ Important Notes

- Always use `Text(l10n.key)` instead of `const Text('...')` when using localized strings
- The `!` after `AppLocalizations.of(context)!` is safe because we configured it in `main.dart`
- If you see compilation errors, run `flutter pub get` to regenerate localization code
- The old `lib/l10n/app_strings.dart` file is no longer needed and can be deleted after migration

## 🎯 Priority Order

Suggested order to complete the migration:

1. **First:** `pausal_home.dart` (most critical, has connection dialogs)
2. **Second:** All tab files (overview, ledger, clients, settings)
3. **Third:** Form files (add_entry_sheet, add_client, profile_form)
4. **Fourth:** Component files (smaller components)
5. **Finally:** Test everything and remove old `app_strings.dart`

---

Good luck with the migration! 🚀
