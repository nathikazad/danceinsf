import 'package:flutter/material.dart';
import 'package:flutter_application/controllers/proposal_controller.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:intl/intl.dart';


class ProposalItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MM/dd').format(proposal.createdAt);

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
              proposal.text,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isForAllEvents ? 'For All Events' : 'Only This Event',
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
                          '${proposal.yeses.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_up_outlined),
                          onPressed: () async {
                            final updatedProposal = await ProposalController.voteOnProposal(proposal.id, true);
                            if (updatedProposal != null && onProposalUpdated != null) {
                              onProposalUpdated!(updatedProposal);
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${proposal.nos.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_down_outlined),
                          onPressed: () async {
                            final updatedProposal = await ProposalController.voteOnProposal(proposal.id, false);
                            if (updatedProposal != null && onProposalUpdated != null) {
                              onProposalUpdated!(updatedProposal);
                            }
                          },
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