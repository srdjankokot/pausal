import 'package:flutter/material.dart';
import 'package:pausal_calculator/constants/app_constants.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/client_share.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/tabs/overview/contribution_row.dart';
import 'package:pausal_calculator/screens/app/tabs/overview/overview_row.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';
import 'package:pausal_calculator/utils.dart';
import 'package:pausal_calculator/l10n/app_localizations.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.entries,
    required this.profile,
    required this.clients,
  });

  final List<LedgerEntry> entries;
  final TaxProfile profile;
  final List<Client> clients;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invoices = entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final expenses = entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .toList();

    final totalInvoiced = invoices.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, entry) => sum + entry.amount,
    );

    final now = DateTime.now();
    final currentYear = DateTime.now().year;
    final totalInvoicedCurrentYear = invoices
        .where((invoice) => invoice.date.year == currentYear)
        .fold<double>(0, (sum, entry) => sum + entry.amount);

    final trackedMonths = _countTrackedMonths(entries);
    final fixedObligations =
        profile.monthlyFixedContributions *
        (trackedMonths == 0 ? 1 : trackedMonths);

    final taxableBase = (totalInvoiced - totalExpenses).clamp(
      0,
      double.infinity,
    );
    final additionalTax = taxableBase * profile.additionalTaxRate;
    final totalObligations = fixedObligations + additionalTax;
    final netIncome = totalInvoiced - totalExpenses - totalObligations;

    final remainingLimit = (profile.annualLimit - totalInvoicedCurrentYear)
        .clamp(0, double.infinity);
    final limitProgress = profile.annualLimit == 0
        ? 0.0
        : (totalInvoicedCurrentYear / profile.annualLimit).clamp(0.0, 1.0);

    // final now = DateTime.now();
    final DateTime rollingWindowStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 365));
    final totalLast12Months = invoices
        .where((invoice) => invoice.date.isAfter(rollingWindowStart))
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final rollingProgress = profile.rollingLimit == 0
        ? 0.0
        : (totalLast12Months / profile.rollingLimit).clamp(0.0, 1.0);
    final rollingRemaining = (profile.rollingLimit - totalLast12Months).clamp(
      0,
      double.infinity,
    );

    final Map<String, double> clientTotals = {};
    for (final invoice in invoices.where(
      (invoice) => invoice.date.year == currentYear,
    )) {
      final clientId = invoice.clientId;
      if (clientId == null) continue;

      clientTotals.update(
        clientId,
        (value) => value + invoice.amount,
        ifAbsent: () => invoice.amount,
      );
    }
    final totalForShare = totalInvoicedCurrentYear == 0
        ? 1
        : totalInvoicedCurrentYear;
    final clientShares = <ClientShare>[];
    for (final entry in clientTotals.entries) {
      final client = clients.firstWhere(
        (c) => c.id == entry.key,
        orElse: () => Client(
          id: entry.key,
          name: l10n.unknownClient,
          pib: '',
          address: '',
        ),
      );
      final share = entry.value / totalForShare;
      clientShares.add(
        ClientShare(client: client, amount: entry.value, share: share),
      );
    }
    clientShares.sort((a, b) => b.share.compareTo(a.share));

    final latestEntries = entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    Client? resolveClient(String? id) {
      if (id == null) return null;
      try {
        return clients.firstWhere((client) => client.id == id);
      } catch (_) {
        return null;
      }
    }

    String buildSubtitle(LedgerEntry entry) {
      final client = resolveClient(entry.clientId);
      final parts = <String>[formatDate(entry.date)];
      if (client != null) {
        parts.add(client.name);
      }
      return parts.join('  ·  ');
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          Text(
            l10n.overviewGreeting,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.overviewSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.total,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OverviewRow(
                    label: l10n.issuedInvoices,
                    value: formatCurrency(totalInvoiced),
                    icon: Icons.trending_up,
                    iconColor: Colors.green[600]!,
                  ),
                  const SizedBox(height: 12),
                  OverviewRow(
                    label: l10n.expenses,
                    value: formatCurrency(totalExpenses),
                    icon: Icons.shopping_bag,
                    iconColor: pastelBlueDark,
                  ),
                  const SizedBox(height: 12),
                  OverviewRow(
                    label: l10n.taxObligations,
                    value: formatCurrency(totalObligations),
                    icon: Icons.account_balance_wallet,
                    iconColor: Colors.blue[600]!,
                  ),
                  const Divider(height: 32),
                  OverviewRow(
                    label: l10n.estimatedNet,
                    value: formatCurrency(netIncome),
                    icon: Icons.payments,
                    iconColor: Colors.purple[600]!,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.revenueShareByClientYear(currentYear.toString()),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (clientShares.isEmpty)
                    Text(l10n.noConnectedClients)
                  else
                    ...clientShares.map((share) {
                      final percent = (share.share * 100).clamp(0, 100);
                      final exceedsThreshold = share.share > 0.60;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    share.client.name,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontWeight: exceedsThreshold
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: share.share.clamp(0.0, 1.0),
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                      valueColor: AlwaysStoppedAnimation(
                                        exceedsThreshold
                                            ? Colors.redAccent
                                            : Colors.green[400]!,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${percent.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: exceedsThreshold
                                        ? Colors.redAccent
                                        : Colors.green[700],
                                  ),
                                ),
                                Text(
                                  formatCurrency(share.amount),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  if (clientShares.any((share) => share.share > 0.60))
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.redAccent[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.clientLimitWarning,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.redAccent[400]),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.rollingLimit,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: rollingProgress,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    backgroundColor: Colors.blueGrey[100],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.remainingToLimit),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(rollingRemaining as double),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.rollingLimitCap),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(profile.rollingLimit),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.periodCovered(formatDate(rollingWindowStart), formatDate(now)),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.annualLimit,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: limitProgress,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    backgroundColor: pastelBlueLight,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.remainingToLimit),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(remainingLimit as double),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(l10n.totalLimit),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(profile.annualLimit),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.monthlyObligations,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ContributionRow(
                    label: l10n.pensionContribution,
                    value: formatCurrency(profile.monthlyPension),
                  ),
                  const SizedBox(height: 12),
                  ContributionRow(
                    label: l10n.healthInsurance,
                    value: formatCurrency(profile.monthlyHealth),
                  ),
                  const SizedBox(height: 12),
                  ContributionRow(
                    label: l10n.taxPrepayment,
                    value: formatCurrency(profile.monthlyTaxPrepayment),
                  ),
                  const SizedBox(height: 12),
                  ContributionRow(
                    label: l10n.totalMonthly,
                    value: formatCurrency(profile.monthlyFixedContributions),
                    emphasize: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recentActivity,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (latestEntries.isEmpty)
                    Text(l10n.noEntriesYet)
                  else
                    ...latestEntries
                        .take(5)
                        .map(
                          (entry) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: entry.kind == LedgerKind.invoice
                                  ? Colors.green[100]
                                  : pastelBlueLight,
                              child: Icon(
                                entry.kind == LedgerKind.invoice
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: entry.kind == LedgerKind.invoice
                                    ? Colors.green[700]
                                    : pastelBlueDark,
                              ),
                            ),
                            title: Text(entry.title),
                            subtitle: Text(buildSubtitle(entry)),
                            trailing: Text(
                              formatCurrency(entry.amount),
                              style: TextStyle(
                                color: entry.kind == LedgerKind.invoice
                                    ? Colors.green[700]
                                    : pastelBlueDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

int _countTrackedMonths(List<LedgerEntry> entries) {
  final months = entries
      .map((entry) => DateTime(entry.date.year, entry.date.month))
      .toSet();
  return months.length;
}
