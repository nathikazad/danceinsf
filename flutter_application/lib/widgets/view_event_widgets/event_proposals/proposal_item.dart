import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/proposal_controller.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:flutter_application/screens/verify_screen.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final result = await GoRouter.of(context).push<bool>('/verify',
        extra: {
          'nextRoute': '/back',
          'verifyScreenType': VerifyScreenType.giveRating
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
    }
    final updatedProposal = await ProposalController.voteOnProposal(widget.proposal.id, isUpvote);
    if (updatedProposal != null && widget.onProposalUpdated != null) {
      widget.onProposalUpdated!(updatedProposal);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              widget.proposal.text,
              style: const TextStyle(fontSize: 16),
            ),
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