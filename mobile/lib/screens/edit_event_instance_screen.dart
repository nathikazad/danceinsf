import 'package:dance_sf/widgets/add_event_widgets/description_section.dart';
import 'package:flutter/material.dart';
import 'package:dance_sf/controllers/event_instance_controller.dart';
import 'package:dance_sf/controllers/proposal_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/add_event_widgets/location_section.dart';
import '../widgets/add_event_widgets/upload_section.dart';
import '../widgets/add_event_widgets/time_section.dart';
import '../widgets/add_event_widgets/cost_section.dart';
import '../widgets/add_event_widgets/tickets_section.dart';
import '../widgets/add_event_widgets/date_field.dart';
import '../models/event_model.dart';

class EditEventInstanceScreen extends ConsumerStatefulWidget {
  final String eventInstanceId;
  const EditEventInstanceScreen({required this.eventInstanceId, super.key});

  @override
  ConsumerState<EditEventInstanceScreen> createState() => _EditEventInstanceScreenState();
}

class _EditEventInstanceScreenState extends ConsumerState<EditEventInstanceScreen> {
  final _formKey = GlobalKey<FormState>();
  late EventInstance _eventInstance;
  late EventInstance _oldEventInstance;  // Store the original event instance
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventInstance();
  }

  Future<void> _loadEventInstance() async {
    try {
      final instance = await EventInstanceController.fetchEventInstance(widget.eventInstanceId);
      if (instance != null && mounted) {
        setState(() {
          _eventInstance = instance;
          _oldEventInstance = instance;  // Store the original event instance
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading event instance: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Get and print the differences between original and current state
        final differences = EventInstance.getDifferences(_oldEventInstance, _eventInstance);

        if (_eventInstance.event.organizerId == Supabase.instance.client.auth.currentUser?.id ||
        _eventInstance.event.creatorId == Supabase.instance.client.auth.currentUser?.id ||
        Supabase.instance.client.auth.currentUser?.id == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6') {
          await EventInstanceController.updateEventInstance(_eventInstance);
        } else {
          await ProposalController.createProposal(
          changes: differences ?? {},
          forAllEvents: false,
          eventInstanceId: _eventInstance.eventInstanceId);
        }

        
        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating event instance: $e')),
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
        title: const Text('Edit Event Instance'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DateField(
              date: _eventInstance.date,
              onDateChanged: (date) => setState(() {
                _eventInstance = _eventInstance.copyWith(date: date);
              }),
            ),
            const SizedBox(height: 20),
            TimeSection(
              startTime: _eventInstance.startTime,
              endTime: _eventInstance.endTime,
              onStartTimeChanged: (time) => setState(() {
                if (time != null) {
                  _eventInstance = _eventInstance.copyWith(startTime: time);
                }
              }),
              onEndTimeChanged: (time) => setState(() {
                if (time != null) {
                  _eventInstance = _eventInstance.copyWith(endTime: time);
                }
              }),
            ),
            const SizedBox(height: 20),
            CostSection(
              initialCost: _eventInstance.cost,
              onCostChanged: (cost) => setState(() {
                _eventInstance = _eventInstance.copyWith(cost: cost);
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
              location: Location(
                venueName: _eventInstance.venueName,
                city: _eventInstance.city,
                url: _eventInstance.url,
              ),
              onLocationChanged: (newLocation) => setState(() {
                _eventInstance = _eventInstance.copyWith(
                  venueName: newLocation.venueName,
                  city: newLocation.city,
                  url: newLocation.url,
                );
              }),
            ),
            const SizedBox(height: 20),
            TicketsSection(
              initialTicketLinks: _eventInstance.linkToEvents
              .toSet()
              .difference(_eventInstance.event.linkToEvents.toSet())
              .toList(),
              onTicketLinksChanged: (links) => setState(() {
                print(links);
                _eventInstance = _eventInstance.copyWith(linkToEvents: links);
              }),
              // validator: (value) {
              //   if (value == null || value.isEmpty) return null;
              //   final uri = Uri.tryParse(value);
              //   if (uri == null || !uri.isAbsolute) {
              //     return 'Please enter a valid URL';
              //   }
              //   return null;
              // },
            ),
            const SizedBox(height: 20),
            UploadSection(
              fileUrl: _eventInstance.flyerUrl,
              onFileChanged: (url) => setState(() {
                _eventInstance = _eventInstance.copyWith(flyerUrl: url);
              }),
            ),
            const SizedBox(height: 28),
            DescriptionSection(
              description: _eventInstance.description,
              onDescriptionChanged: (Map<String, String>? description) {
                setState(() {
                  _eventInstance = _eventInstance.copyWith(description: description);
                });
              },
            ),
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