import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pausal_calculator/screens/app/client.dart';
import 'package:pausal_calculator/screens/app/client_share.dart';
import 'package:pausal_calculator/screens/app/lendger_entry.dart';
import 'package:pausal_calculator/screens/app/tabs/overview/contribution_row.dart';
import 'package:pausal_calculator/screens/app/tax_profile.dart';
import 'package:pausal_calculator/utils.dart';
import 'package:pausal_calculator/l10n/app_localizations.dart';

class OverviewTab extends StatefulWidget {
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
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  String _selectedPeriod = 'Do 6M';
  late int _selectedRevenueYear;

  @override
  void initState() {
    super.initState();
    _selectedRevenueYear = DateTime.now().year;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final invoices = widget.entries
        .where((entry) => entry.kind == LedgerKind.invoice)
        .toList();
    final expenses = widget.entries
        .where((entry) => entry.kind == LedgerKind.expense)
        .toList();

    final totalInvoiced = invoices.fold<double>(
      0,
      (sum, entry) => sum + entry.amountInRSD,
    );
    final totalExpenses = expenses.fold<double>(
      0,
      (sum, entry) => sum + entry.amountInRSD,
    );

    final currentYear = DateTime.now().year;
    final totalInvoicedCurrentYear = invoices
        .where((invoice) => invoice.date.year == currentYear)
        .fold<double>(0, (sum, entry) => sum + entry.amountInRSD);

    final trackedMonths = _countTrackedMonths(widget.entries);
    final fixedObligations =
        widget.profile.monthlyFixedContributions *
        (trackedMonths == 0 ? 1 : trackedMonths);

    final taxableBase = (totalInvoiced - totalExpenses).clamp(
      0,
      double.infinity,
    );
    final additionalTax = taxableBase * widget.profile.additionalTaxRate;
    final totalObligations = fixedObligations + additionalTax;
    final netIncome = totalInvoiced - totalExpenses - totalObligations;

    final remainingLimit = (widget.profile.annualLimit - totalInvoicedCurrentYear)
        .clamp(0, double.infinity);
    final limitProgress = widget.profile.annualLimit == 0
        ? 0.0
        : (totalInvoicedCurrentYear / widget.profile.annualLimit).clamp(0.0, 1.0);

    // Calculate client shares for selected year
    final totalInvoicedSelectedYear = invoices
        .where((invoice) => invoice.date.year == _selectedRevenueYear)
        .fold<double>(0, (sum, entry) => sum + entry.amountInRSD);

    final Map<String, double> clientTotals = {};
    for (final invoice in invoices.where(
      (invoice) => invoice.date.year == _selectedRevenueYear,
    )) {
      final clientId = invoice.clientId;
      if (clientId == null) continue;

      clientTotals.update(
        clientId,
        (value) => value + invoice.amountInRSD,
        ifAbsent: () => invoice.amountInRSD,
      );
    }
    final totalForShare = totalInvoicedSelectedYear == 0
        ? 1
        : totalInvoicedSelectedYear;
    final clientShares = <ClientShare>[];
    for (final entry in clientTotals.entries) {
      final client = widget.clients.firstWhere(
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
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 900;
              final cardCount = isWideScreen ? 4 : 2;
              final spacing = 16.0;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  _buildSummaryCard(
                    context,
                    l10n.issuedInvoices,
                    totalInvoiced,
                    'assets/images/receipt.svg',
                    Colors.green,

                    (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount,
                  ),
                  _buildSummaryCard(
                    context,
                    l10n.expenses,
                    totalExpenses,
                    'assets/images/money_send.svg',
                    Colors.red,

                    (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount,
                  ),
                  _buildSummaryCard(
                    context,
                    l10n.taxObligations,
                    totalObligations,
                    'assets/images/wallet_check.svg',
                    Colors.red,

                    (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount,
                  ),
                  _buildSummaryCard(
                    context,
                    l10n.estimatedNet,
                    netIncome,
                    'assets/images/wallet.svg',
                    Colors.green,

                    (constraints.maxWidth - (spacing * (cardCount - 1))) / cardCount,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Divider(
            thickness: 1,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 900;

              if (isWideScreen) {
                // Two column layout for wide screens
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column: Revenue by client + Last activity
                    Expanded(
                      child: Column(
                        children: [
                          _buildRevenueByClientCard(context, clientShares, _selectedRevenueYear, l10n),
                          const SizedBox(height: 20),
                          _buildLastActivitiesCard(context, l10n),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right column: Annual limit + Monthly obligations
                    Expanded(
                      child: Column(
                        children: [
                          _buildAnnualLimitCard(context, remainingLimit as double, totalInvoicedCurrentYear, limitProgress, l10n),
                          const SizedBox(height: 20),
                          _buildMonthlyObligationsCard(context, l10n),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                // Single column layout for narrow screens
                return Column(
                  children: [
                    _buildRevenueByClientCard(context, clientShares, _selectedRevenueYear, l10n),
                    const SizedBox(height: 20),
                    _buildAnnualLimitCard(context, remainingLimit as double, totalInvoicedCurrentYear, limitProgress, l10n),
                    const SizedBox(height: 20),
                    _buildMonthlyObligationsCard(context, l10n),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    double value,
    String iconPath,
    Color iconColor,
    double width,
  ) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
             color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: SvgPicture.asset(
                    iconPath,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildCurrencyText(
              context,
              value,
              numberFontSize: isMobile ? 22 : 28,
              currencyFontSize: isMobile ? 10 : 12,
              numberColor: Colors.black,
              includeDecimals: false,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueByClientCard(
    BuildContext context,
    List<ClientShare> clientShares,
    int selectedYear,
    AppLocalizations l10n,
  ) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    // Get available years from entries
    final availableYears = widget.entries
        .map((entry) => entry.date.year)
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

    // Calculate total income for selected year
    final totalIncomeForYear = clientShares.fold<double>(
      0,
      (sum, share) => sum + share.amount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.revenueShareByClientYear(selectedYear.toString()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (availableYears.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: selectedYear,
                    underline: const SizedBox(),
                    isDense: true,
                    icon: const Icon(Icons.arrow_drop_down, size: 20),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    items: availableYears.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newYear) {
                      if (newYear != null) {
                        setState(() {
                          _selectedRevenueYear = newYear;
                        });
                      }
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          buildCurrencyText(
            context,
            totalIncomeForYear,
            numberFontSize: isMobile ? 20 : 24,
            currencyFontSize: isMobile ? 10 : 12,
            numberWeight: FontWeight.bold,
            numberColor: Colors.black87,
          ),
          const SizedBox(height: 20),
          if (clientShares.isEmpty)
            Text(l10n.noConnectedClients)
          else
            ...clientShares.map((share) {
              final percent = (share.share * 100).clamp(0, 100);
              final exceedsThreshold = share.share > 0.60;
              return Column(
                children: [
                  Divider(
                    thickness: 1,
                    color: Colors.grey[300],
                  ),



                   if (isMobile) 
                            Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: 

                    Row(children: [
                      Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                                share.client.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                          ),
                        buildCurrencyText(
                          context,
                          share.amount,
                          numberFontSize: isMobile ? 12 : 14,
                          currencyFontSize: isMobile ? 8 : 9,
                          numberWeight: FontWeight.bold,
                          numberColor: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                  
    
                      ],
                    )),

                          Text(
                          '${percent.toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: exceedsThreshold ? Colors.redAccent : Colors.green[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )

                    ],)


                    ,
                  )
                      else

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8, top: 8),
                    child: 

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                      Expanded(
                          child: 
                              Text(
                                share.client.name,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                          ),
                        ),
                        buildCurrencyText(
                          context,
                          share.amount,
                          numberFontSize: isMobile ? 12 : 14,
                          currencyFontSize: isMobile ? 8 : 9,
                          numberWeight: FontWeight.bold,
                          numberColor: Colors.black87,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${percent.toStringAsFixed(1)}%)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: exceedsThreshold ? Colors.redAccent : Colors.green[600],
                            fontSize: isMobile ? 11 : 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
    
                      ],
                    ),
                  ),
                ],
              );
            }),
          if (clientShares.any((share) => share.share > 0.60))
            Padding(
              padding: const EdgeInsets.only(top: 4),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.redAccent[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTitleWithTooltip(
    BuildContext context,
    String title,
    String tooltipText,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.info_outline,
            size: 20,
            color: Colors.grey[600],
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(title),
                  content: Text(tooltipText),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('U redu'),
                    ),
                  ],
                );
              },
            );
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildAnnualLimitCard(
    BuildContext context,
    double remainingLimit,
    double totalInvoicedCurrentYear,
    double limitProgress,
    AppLocalizations l10n,
  ) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    // Calculate rolling 12 months data
    final now = DateTime.now();
    final twelveMonthsAgo = DateTime(now.year, now.month - 12, now.day);
    final totalInvoicedRolling = widget.entries
        .where((entry) =>
            entry.kind == LedgerKind.invoice &&
            entry.date.isAfter(twelveMonthsAgo))
        .fold<double>(0, (sum, entry) => sum + entry.amountInRSD);

    final rollingLimit = widget.profile.rollingLimit;
    final remainingRollingLimit = (rollingLimit - totalInvoicedRolling).clamp(0, double.infinity);
    final rollingProgress = rollingLimit == 0 ? 0.0 : (totalInvoicedRolling / rollingLimit).clamp(0.0, 1.0);

    final annualLimit = widget.profile.annualLimit;
    final remainingAnnualLimit = (annualLimit - totalInvoicedCurrentYear).clamp(0, double.infinity);
    final annualProgress = annualLimit == 0 ? 0.0 : (totalInvoicedCurrentYear / annualLimit).clamp(0.0, 1.0);

    return Column(
      children: [
        // Rolling 12 months limit card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWithTooltip(
                context,
                'Poslednji 12 meseci',
                'Ovaj limit prati ukupan prihod u proteklih 12 meseci (365 dana) od danas. '
                'To znači da se limit dinamički pomera sa svakim danom i uzima u obzir sve fakture '
                'iz poslednje godine, bez obzira na kalendarske godine. Ovaj limit je bitan za paušalno '
                'oporezivanje jer određuje da li još uvek možete raditi kao paušalac.',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preostalo do limita: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      buildCurrencyText(
                        context,
                        remainingRollingLimit as double,
                        numberFontSize: isMobile ? 14 : 16,
                        currencyFontSize: isMobile ? 10 : 12,
                        numberColor: Colors.black87,
                      ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       'Fakturisano',
                  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //         color: Colors.grey[600],
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 4),
                  //     buildCurrencyText(
                  //       context,
                  //       totalInvoicedRolling,
                  //       numberFontSize: 18,
                  //       currencyFontSize: 11,
                  //       numberColor: Colors.black87,
                  //     ),
                  //   ],
                  // ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

  RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      children: [
        TextSpan(
          text: "${rollingLimit/1000000}M",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: isMobile ? 24 : 30,
          ),
        ),
        TextSpan(
          text: 'RSD',
          style: TextStyle(
            color:  Colors.grey[500],
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  ),
                
                  // buildCurrencyText(
                  //   context,
                  //   rollingLimit,
                  //  numberFontSize: 30,
                  //   currencyFontSize: 16,
                  //   numberColor: Colors.black,
                  // ),
                ],
              ),
               const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: rollingProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

            ],
          ),
        ),
        const SizedBox(height: 16),
        // Annual limit card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleWithTooltip(
                context,
                l10n.annualLimit,
                'Ovaj limit prati ukupan prihod unutar kalendarske godine (od 1. januara do 31. decembra). '
                'Resetuje se na početku svake nove godine. Ovaj limit je takođe važan za paušalno '
                'oporezivanje i određuje maksimalni prihod koji možete ostvariti u toku jedne kalendarske godine.',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preostalo do limita: ',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.black87,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      buildCurrencyText(
                        context,
                        remainingAnnualLimit as double,
                        numberFontSize: isMobile ? 14 : 16,
                        currencyFontSize: isMobile ? 10 : 12,
                        numberColor: Colors.black87,
                      ),
                    ],
                  ),
                  // Column(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       'Fakturisano',
                  //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  //         color: Colors.grey[600],
                  //         fontSize: 12,
                  //       ),
                  //     ),
                  //     const SizedBox(height: 4),
                  //     buildCurrencyText(
                  //       context,
                  //       totalInvoicedCurrentYear,
                  //       numberFontSize: 18,
                  //       currencyFontSize: 11,
                  //       numberColor: Colors.black87,
                  //     ),
                  //   ],
                  // ),
                ],
              ),



              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
  RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      children: [
        TextSpan(
          text: "${annualLimit/1000000}M",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: isMobile ? 24 : 30,
          ),
        ),
        TextSpan(
          text: 'RSD',
          style: TextStyle(
            color:  Colors.grey[500],
            fontSize: isMobile ? 12 : 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  ),
     
                ],
              ),

        const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: annualProgress,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLastActivitiesCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final isMobile = MediaQuery.of(context).size.width <= 900;

    // Get the last 5 entries sorted by date
    final recentEntries = widget.entries.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final displayEntries = recentEntries.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.recentActivity,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (displayEntries.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  l10n.noEntriesYet,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else ...[
            // Table headers
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Broj fakture',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),

                        Expanded(
                  flex: 2,
                  child: Text(
                    'Opis',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Text(
                    'Datum',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Klijent',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Iznos',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey[300]),
            const SizedBox(height: 8),
            // Table rows
            ...displayEntries.asMap().entries.map((entry) {
              final index = entry.key;
              final ledgerEntry = entry.value;
              final isLast = index == displayEntries.length - 1;

              // Find the client name
              String displayName;
              if (ledgerEntry.kind == LedgerKind.expense) {
                // For expenses, show the client name directly
                // final client = widget.clients.firstWhere(
                //   (c) => c.id == ledgerEntry.clientId,
                //   orElse: () => const Client(
                //     id: '',
                //     name: '-',
                //     pib: '',
                //     address: '',
                //   ),
                // );
                displayName = ledgerEntry.title;
              } else {
                // For invoices, show the client name
                final client = widget.clients.firstWhere(
                  (c) => c.id == ledgerEntry.clientId,
                  orElse: () => const Client(
                    id: '',
                    name: '-',
                    pib: '',
                    address: '',
                  ),
                );
                displayName = client.name;
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            ledgerEntry.invoiceNumber ?? '-',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                       Expanded(
                          flex: 2,
                          child: Text(
                            ledgerEntry.title,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Expanded(
                          flex: 2,
                          child: Text(
                            '${ledgerEntry.date.day}.${ledgerEntry.date.month}.${ledgerEntry.date.year}.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: buildCurrencyText(
                              context,
                              ledgerEntry.amount,
                              numberFontSize: isMobile ? 12 : 14,
                              currencyFontSize: isMobile ? 8 : 9,
                              numberWeight: FontWeight.w600,
                              numberColor: ledgerEntry.kind == LedgerKind.invoice
                                  ? Colors.green[700]!
                                  : Colors.red[700]!,
                              currency: ledgerEntry.currency,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(height: 1, color: Colors.grey[200]),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthlyObligationsCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            value: widget.profile.monthlyPension,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),
          ContributionRow(
            label: l10n.healthInsurance,
            value: widget.profile.monthlyHealth,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),
          ContributionRow(
            label: l10n.taxPrepayment,
            value: widget.profile.monthlyTaxPrepayment,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey[200]),
          const SizedBox(height: 12),
          ContributionRow(
            label: l10n.totalMonthly,
            value: widget.profile.monthlyFixedContributions,
            emphasize: true,
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
