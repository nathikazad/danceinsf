import 'package:flutter/material.dart';
import 'package:flutter_application/models/event_model.dart';
import 'package:flutter_application/models/proposal_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'proposal_item.dart';
import 'proposal_form.dart';

class ProposalsWidget extends StatefulWidget {
  final EventInstance eventInstance;

  const ProposalsWidget({required this.eventInstance, super.key});

  @override
  State<ProposalsWidget> createState() => _ProposalsWidgetState();
}

class _ProposalsWidgetState extends State<ProposalsWidget> {
  bool showProposals = false;
  String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

  List<Proposal> _eventInstanceProposals = [];
  List<Proposal> _eventProposals = [];

  @override
  void initState() {
    super.initState();
    _eventInstanceProposals = widget.eventInstance.proposals ?? [];
    _eventProposals = widget.eventInstance.event.proposals ?? [];
  }

  void _updateProposal(Proposal updatedProposal) {
    setState(() {
      // Update in the appropriate list based on whether it's for all events
      if (updatedProposal.eventId != null) {
        final index =
            _eventProposals.indexWhere((p) => p.id == updatedProposal.id);
        if (index != -1) {
          _eventProposals[index] = updatedProposal;
        }
      } else {
        final index = _eventInstanceProposals
            .indexWhere((p) => p.id == updatedProposal.id);
        if (index != -1) {
          _eventInstanceProposals[index] = updatedProposal;
        }
      }
    });
  }

  bool get hasUserProposal {
    if (currentUserId == null) return false;

    final eventProposals = widget.eventInstance.event.proposals;
    final instanceProposals = widget.eventInstance.proposals;

    return (eventProposals
                ?.any((proposal) => proposal.userId == currentUserId) ??
            false) ||
        (instanceProposals
                ?.any((proposal) => proposal.userId == currentUserId) ??
            false);
  }

  int get totalProposals =>
      (widget.eventInstance.proposals?.length ?? 0) +
      (widget.eventInstance.event.proposals?.length ?? 0);

  List<Proposal> get eventInstanceProposals => _eventInstanceProposals;
  List<Proposal> get eventProposals => _eventProposals;

  void _handleSuggestEdit() {
    showDialog(
      context: context,
      builder: (context) => ProposalForm(
        eventInstance: widget.eventInstance,
        onSubmitted: () {
          setState(() {}); // Refresh the widget to show new proposal
        },
      ),
    );
  }

  Widget _buildProposalsList() {
    return Column(
      children: [
        ...eventInstanceProposals
            .map((proposal) => ProposalItem(
                  proposal: proposal,
                  isForAllEvents: false,
                  onProposalUpdated: _updateProposal,
                ))
            .toList(),
        ...eventProposals
            .map((proposal) => ProposalItem(
                  proposal: proposal,
                  isForAllEvents: true,
                  onProposalUpdated: _updateProposal,
                ))
            .toList(),
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Proposed Edits ($totalProposals)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white),
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
    return Container(
      width: double.infinity,
      child: Column(
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
          if (totalProposals > 0) _buildEditProposalsHeader(),
          if (showProposals) ...[
            const SizedBox(height: 16),
            _buildProposalsList(),
          ],
        ],
      ),
    );
  }
}
