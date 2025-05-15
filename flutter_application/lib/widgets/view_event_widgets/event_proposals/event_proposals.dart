import 'package:flutter/material.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'proposal_item.dart';
import 'proposal_form.dart';

class ProposalsWidget extends StatefulWidget {
  final String eventId;
  final String eventInstanceId;
  final List<Proposal> eventProposals;
  final List<Proposal> eventInstanceProposals;
  
  const ProposalsWidget({
    required this.eventId, 
    required this.eventInstanceId, 
    required this.eventProposals,
    required this.eventInstanceProposals,
    super.key
  });

  @override
  State<ProposalsWidget> createState() => _ProposalsWidgetState();
}

class _ProposalsWidgetState extends State<ProposalsWidget> {
  bool showProposals = false;

  String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
  
  bool get hasUserProposal => currentUserId != null && 
      (widget.eventProposals.any((proposal) => proposal.userId == currentUserId) ||
       widget.eventInstanceProposals.any((proposal) => proposal.userId == currentUserId));

  int get totalProposals => widget.eventInstanceProposals.length + widget.eventProposals.length;

  void _handleSuggestEdit() {
    showDialog(
      context: context,
      builder: (context) => ProposalForm(
        eventId: widget.eventId,
        eventInstanceId: widget.eventInstanceId,
        onSubmitted: () {
          setState(() {}); // Refresh the widget to show new proposal
        },
      ),
    );
  }

  Widget _buildProposalsList() {
    return Column(
      children: [
        ...widget.eventInstanceProposals.map((proposal) => 
          ProposalItem(proposal: proposal, isForAllEvents: false)
        ).toList(),
        ...widget.eventProposals.map((proposal) => 
          ProposalItem(proposal: proposal, isForAllEvents: true)
        ).toList(),
      ],
    );
  }

  Widget _buildEditProposalsHeader() {
    return InkWell(
      onTap: () {
        setState(() {
          showProposals = !showProposals;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proposed Edits ($totalProposals)',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(
              showProposals ? Icons.expand_less : Icons.expand_more,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'This listing is maintained by the Community',
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        if (!hasUserProposal)
          GestureDetector(
            onTap: _handleSuggestEdit,
            child: const Text(
              'Suggest an edit',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(height: 20),
        if (totalProposals > 0)
          _buildEditProposalsHeader(),
        if (showProposals) ...[
          const SizedBox(height: 16),
          _buildProposalsList(),
        ],
      ],
    );
  }
} 