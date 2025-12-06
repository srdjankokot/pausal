import 'package:flutter/material.dart';

class ConnectSheetPlaceholder extends StatelessWidget {
  const ConnectSheetPlaceholder({
    super.key,
    required this.isConnecting,
    required this.onConnect,
    this.onOpenApp,
  });

  final bool isConnecting;
  final Future<void> Function() onConnect;
  final VoidCallback? onOpenApp;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 900;
          
          
          return Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(isWide ? 32 : 20),
                child: isWide
                    ? Row(
                        children: [
                          Expanded(child: _buildIntroPanel(context, isWide)),
                          const SizedBox(width: 18),
                          Expanded(child: _buildVisualPanel(context, isWide)),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIntroPanel(context, isWide),
                        ],
                      ),
              ),
          );
        },
      ),
    );
  }

  Widget _buildIntroPanel(BuildContext context, bool isWide) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 24,
        vertical: isWide ? 40 : 28,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FF),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 44,
                width: 44,
      
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/pausal_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Paušal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2B2D42),
                ),
              ),
            ],
          ),
          SizedBox(height: isWide ? 60 : 36),

          if (isWide)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Paušal kalkulator',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Vaš digitalni asistent za paušalno oporezivanje koji razvija Finaccons',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: isConnecting
                          ? null
                          : () async {
                              await onConnect();
                            },
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.table_chart_rounded,
                          color: Colors.green[700],
                          size: 18,
                        ),
                      ),
                      label: Text(
                        isConnecting
                            ? 'Povezivanje...'
                            : 'Povežite Google Sheets nalog',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        side: const BorderSide(color: Colors.black87, width: 1),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Paušal kalkulator',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Vaš digitalni asistent za paušalno oporezivanje koji razvija Finaccons',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: isConnecting
                      ? null
                      : () async {
                          await onConnect();
                        },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.table_chart_rounded,
                      color: Colors.green[700],
                      size: 18,
                    ),
                  ),
                  label: Text(
                    isConnecting
                        ? 'Povezivanje...'
                        : 'Povežite Google Sheets nalog',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    side: const BorderSide(color: Colors.black87, width: 1),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
        


          const SizedBox(height: 42),
         
         
          if (isWide)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Razvio Finaccons. Sva prava zaštićena',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                TextButton(
                  onPressed: onOpenApp,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('O aplikaciji'),
                ),
              ],
            )
          else
            Column(
              children: [
                Text(
                  'Razvio Finaccons. Sva prava zaštićena',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onOpenApp,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('O aplikaciji'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVisualPanel(BuildContext context, bool isWide) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: isWide ? double.infinity : 280,
   
        child: Image.asset(
          'assets/images/landing.png',
          fit: BoxFit.fitHeight,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
