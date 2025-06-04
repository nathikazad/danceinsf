import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_event_widgets/repeat_section.dart';
import '../widgets/add_event_widgets/location_section.dart';
import '../widgets/add_event_widgets/upload_section.dart';
// import '../widgets/add_event_widgets/organizer_section.dart';
import '../widgets/add_event_widgets/time_section.dart';
import '../widgets/add_event_widgets/cost_section.dart';
import '../widgets/add_event_widgets/tickets_section.dart';
import '../widgets/add_event_widgets/name_field.dart';
import '../widgets/add_event_widgets/dance_type_section.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  const AddEventScreen({super.key});

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  // Partial event object
  late Event _event;
  DateTime? _selectedDateForOnce;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _event = Event(
      eventId: '', // Will be set by the database
      name: '',
      type: EventType.social,
      styles: [DanceStyle.bachata],
      frequency: Frequency.once,
      location: Location(venueName: '', city: '', url: ''),
      schedule: SchedulePattern.once(),
      startTime: const TimeOfDay(hour: 0, minute: 0),
      endTime: const TimeOfDay(hour: 0, minute: 0),
      cost: 0.0,
      creatorId: Supabase.instance.client.auth.currentUser!.id,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update the event with the latest values
        _event = _event.copyWith(
          name: _nameController.text,
        );

        // Create the event using the controller
        await EventController.createEvent(_event, _selectedDateForOnce);

        if (mounted) {
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating event: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.only(left: 6),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer),
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create New',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondary, fontSize: 18),
        ),
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
              onScheduleChanged: (newSchedule, newFrequency, newSelectedDate) =>
                  setState(() {
                _event = _event.copyWith(
                  schedule: newSchedule,
                  frequency: newFrequency,
                );
                _selectedDateForOnce = newSelectedDate;
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
              initialTicketLink: _event.linkToEvent,
              onTicketLinkChanged: (link) => setState(() {
                _event = _event.copyWith(linkToEvent: link);
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
              fileUrl: _event.description,
              onFileChanged: (url) => setState(() {
                _event = _event.copyWith(flyerUrl: url);
              }),
            ),
            // const SizedBox(height: 20),
            // OrganizerSection(
            //   name: _event.name,
            //   phone: '',
            //   isOrganizer: true,
            //   onOrganizerChanged: (name, phone, isOrganizer) {
            //     // Not using organizer info in the event model yet
            //   },
            // ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _handleCreate,
                child: Text('Create',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
