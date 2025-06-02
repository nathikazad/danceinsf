import 'package:flutter/material.dart';
import 'package:dance_sf/controllers/proposal_controller.dart';
import 'package:dance_sf/models/proposal_model.dart';
import 'package:dance_sf/screens/verify_screen.dart';
import 'package:dance_sf/utils/string.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dance_sf/utils/theme/app_text_styles.dart';
import 'package:flutter/gestures.dart';

class ProposalItem extends StatefulWidget {
  final Proposal proposal;
  final bool isForAllEvents;
  final Function(Proposal)? onProposalUpdated;

  const ProposalItem({
    required this.proposal,
    required this.isForAllEvents,
    this.onProposalUpdated,
    super.key,
  });

  @override
  State<ProposalItem> createState() => _ProposalItemState();
}

class _ProposalItemState extends State<ProposalItem> {
  Future<void> _handleVote(bool isUpvote) async {
    if (Supabase.instance.client.auth.currentUser == null) {
      try {
        final result = await GoRouter.of(context).push<bool>('/verify',
          extra: {
            'nextRoute': '/back',
            'verifyScreenType': VerifyScreenType.voteOnProposal
          }
        );
        if (result != true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Need to verify your phone number to vote on proposals'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to verify phone number. Please try again.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }
    final updatedProposal = await ProposalController.voteOnProposal(widget.proposal.id, isUpvote);
    if (updatedProposal != null && widget.onProposalUpdated != null) {
      widget.onProposalUpdated!(updatedProposal);
    }
  }

  Widget _buildFormattedText(Map<String, dynamic> changes) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: changes.entries.map((entry) {
        if (entry.value is! Map) return const SizedBox.shrink();
        
        final key = entry.key;
        final value = entry.value as Map;
        final oldValue = value['old']?.toString() ?? '';
        final newValue = value['new']?.toString() ?? '';
        final formattedKey = key.split(RegExp('(?=[A-Z])')).join(' ');
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              style: AppTextStyles.bodyLarge.copyWith(color: colorScheme.onSurface),
              children: [
                TextSpan(text: 'Change ${formattedKey.capitalize()} from '),
                TextSpan(
                  text: oldValue.isEmpty ? 'None' : oldValue,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: oldValue.startsWith('http') ? (TapGestureRecognizer()
                    ..onTap = () async {
                      final url = Uri.parse(oldValue);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }) : null,
                ),
                const TextSpan(text: ' to '),
                TextSpan(
                  text: newValue.isEmpty ? 'None' : newValue,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer: newValue.startsWith('http') ? (TapGestureRecognizer()
                    ..onTap = () async {
                      final url = Uri.parse(newValue);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }) : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('proposal: ${widget.proposal.changes}');
    final formattedDate = DateFormat('MM/dd').format(widget.proposal.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Container()),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            _buildFormattedText(widget.proposal.changes),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isForAllEvents ? 'For All Events' : 'Only This Event',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          '${widget.proposal.yeses.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_up_outlined),
                          onPressed: () => _handleVote(true),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${widget.proposal.nos.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_down_outlined),
                          onPressed: () => _handleVote(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}