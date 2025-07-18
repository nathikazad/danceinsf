import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event_sub_models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BankInfoWidget extends StatefulWidget {
  final BankInfo bankInfo;

  const BankInfoWidget({
    Key? key,
    required this.bankInfo,
  }) : super(key: key);

  @override
  State<BankInfoWidget> createState() => _BankInfoWidgetState();
}

class _BankInfoWidgetState extends State<BankInfoWidget> {
  bool _expanded = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, String copyLabel, String copyMessage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            onPressed: () => _copyToClipboard(context, value, copyMessage),
            tooltip: 'Copy $copyLabel',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: (expanded) => setState(() => _expanded = expanded),
        title: Row(
          children: [
            Icon(
              Icons.account_balance,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.bankInfoTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        children: _expanded
            ? [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(context, l10n.bankInfoBank, widget.bankInfo.bankName, l10n.bankInfoBank, l10n.bankInfoCopied(l10n.bankInfoBank)),
                      _buildInfoRow(context, l10n.bankInfoAccountHolder, widget.bankInfo.name, l10n.bankInfoAccountHolder, l10n.bankInfoCopied(l10n.bankInfoAccountHolder)),
                      _buildInfoRow(context, l10n.bankInfoCardNumber, widget.bankInfo.tarjeta, l10n.bankInfoCardNumber, l10n.bankInfoCopied(l10n.bankInfoCardNumber)),
                      _buildInfoRow(context, l10n.bankInfoClabe, widget.bankInfo.clabe, l10n.bankInfoClabe, l10n.bankInfoCopied(l10n.bankInfoClabe)),
                    ],
                  ),
                ),
              ]
            : [],
      ),
    );
  }
} 