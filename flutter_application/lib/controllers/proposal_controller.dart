
import 'package:flutter_application/models/proposal_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProposalController {
  static Future<String?> createProposal({
    required String text,
    required bool forAllEvents,
    String? eventId,
    String? eventInstanceId,
  }) async {
    final supabase = Supabase.instance.client;
    if (forAllEvents && eventId == null) {
      throw Exception('eventId should not be null if forAllEvents is true');
    }
    if (!forAllEvents && eventInstanceId == null) {
      throw Exception('eventInstanceId should not be null if forAllEvents is false');
    }
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      final data = {
        'user_id': user.id,
        'text': text,
        'event_id': forAllEvents ? eventId : null,
        'event_instance_id': forAllEvents ? null : eventInstanceId,
        'yeses': [],
        'nos': [],
      };
      final response = await supabase
          .from('proposals')
          .insert(data)
          .select('id')
          .single();
      return response['id'].toString();
    } catch (e, st) {
      print('Error creating proposal: $e');
      print(st);
      return null;
    }
  }

  static Future<Proposal?> voteOnProposal(int proposalId, bool isYes) async {
    final supabase = Supabase.instance.client;
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // First get the current proposal to check existing votes
      final proposalResponse = await supabase
          .from('proposals')
          .select('*')
          .eq('id', proposalId)
          .single();

      List<String> yeses = List<String>.from(proposalResponse['yeses'] ?? []);
      List<String> nos = List<String>.from(proposalResponse['nos'] ?? []);

      // Remove user's vote from both lists if it exists
      yeses.remove(user.id);
      nos.remove(user.id);

      // Add user's vote to the appropriate list
      if (isYes) {
        yeses.add(user.id);
      } else {
        nos.add(user.id);
      }

      // Update the proposal with new votes
      await supabase
          .from('proposals')
          .update({
            'yeses': yeses,
            'nos': nos,
          })
          .eq('id', proposalId);

      proposalResponse['yeses'] = yeses;
      proposalResponse['nos'] = nos;

      final proposal = Proposal.fromMap(proposalResponse);
      return proposal;
    } catch (e, st) {
      print('Error voting on proposal: $e');
      print(st);
      return null;
    }
  }
}