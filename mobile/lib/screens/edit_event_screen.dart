import 'package:flutter/material.dart';
import 'package:dance_sf/controllers/proposal_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/add_event_widgets/repeat_section.dart';
import '../widgets/add_event_widgets/location_section.dart';
import '../widgets/add_event_widgets/upload_section.dart';
import '../widgets/add_event_widgets/time_section.dart';
import '../widgets/add_event_widgets/cost_section.dart';
import '../widgets/add_event_widgets/tickets_section.dart';
import '../widgets/add_event_widgets/name_field.dart';
import '../widgets/add_event_widgets/dance_type_section.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';

class EditEventScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EditEventScreen({required this.eventId, super.key});

  @override
  ConsumerState<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends ConsumerState<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late Event _event;
  late Event _oldEvent;  // Store the original event
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadEvent() async {
    try {
      final event = await EventController.fetchEvent(widget.eventId);
      if (event != null && mounted) {
        setState(() {
          _event = event;
          _oldEvent = event;  // Store the original event
          _nameController.text = _event.name;
          _isLoading = false;
        });
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        _event = _event.copyWith(name: _nameController.text);
        final differences = Event.getDifferences(_oldEvent, _event);
        if (_event.organizerId == Supabase.instance.client.auth.currentUser?.id ||
        _event.creatorId == Supabase.instance.client.auth.currentUser?.id ||
        Supabase.instance.client.auth.currentUser?.id == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6') {
          await EventController.updateEvent(_event);
        } else {
          await ProposalController.createProposal(
          changes: differences ?? {},
          forAllEvents: true,
          eventId: _event.eventId);
        }
        
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating event: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit Event'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            NameField(controller: _nameController),
            const SizedBox(height: 20),
            DanceTypeSection(
              type: _event.type,
              styles: _event.styles,
              onTypeChanged: (type) => setState(() {
                _event = _event.copyWith(type: type);
              }),
              onStyleChanged: (style) => setState(() {
                List<DanceStyle> styles = List<DanceStyle>.from(_event.styles);
                if (!styles.contains(style)) {
                  styles.add(style);
                } else if (styles.length > 1) {
                  styles.remove(style);
                }
                _event = _event.copyWith(styles: styles);
              }),
            ),
            const SizedBox(height: 20),
            RepeatSection(
              schedule: _event.schedule,
              frequency: _event.frequency,
              onScheduleChanged: (newSchedule, newFrequency, _) => setState(() {
                _event = _event.copyWith(
                  schedule: newSchedule,
                  frequency: newFrequency,
                );
              }),
            ),
            const SizedBox(height: 20),
            TimeSection(
              startTime: _event.startTime,
              endTime: _event.endTime,
              onStartTimeChanged: (time) => setState(() {
                if (time != null) {
                  _event = _event.copyWith(startTime: time);
                }
              }),
              onEndTimeChanged: (time) => setState(() {
                if (time != null) {
                  _event = _event.copyWith(endTime: time);
                }
              }),
            ),
            const SizedBox(height: 20),
            CostSection(
              initialCost: _event.cost,
              onCostChanged: (cost) => setState(() {
                _event = _event.copyWith(cost: cost);
              }),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            LocationSection(
              location: _event.location,
              onLocationChanged: (newLocation) => setState(() {
                _event = _event.copyWith(location: newLocation);
              }),
            ),
            const SizedBox(height: 20),
            TicketsSection(
              initialTicketLinks: _event.linkToEvents,
              onTicketLinksChanged: (links) => setState(() {
                _event = _event.copyWith(linkToEvents: links);
              }),
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                final uri = Uri.tryParse(value);
                if (uri == null || !uri.isAbsolute) {
                  return 'Please enter a valid URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            UploadSection(
              fileUrl: _event.flyerUrl,
              onFileChanged: (url) => setState(() {
                _event = _event.copyWith(flyerUrl: url);
              }),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSave,
                child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 