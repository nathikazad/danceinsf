import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dance_sf/widgets/verify_event_widgets/verify_user.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:dance_sf/controllers/event_instance_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExcitementWidget extends StatefulWidget {
  final String eventInstanceId;
  final bool initialIsExcited;
  final Function() onExcitementChanged;

  const ExcitementWidget({
    required this.eventInstanceId,
    required this.initialIsExcited,
    required this.onExcitementChanged,
    super.key,
  });

  @override
  State<ExcitementWidget> createState() => _ExcitementWidgetState();
}

class _ExcitementWidgetState extends State<ExcitementWidget> {
  late bool _isExcited;

  @override
  void initState() {
    super.initState();
    _isExcited = widget.initialIsExcited;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.areYouExcited,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final isVerified = await handleRatingVerification(context);
              if (!isVerified) return;
              final currentUserId = Supabase.instance.client.auth.currentUser!.id;
              await EventInstanceController.changeExcitedUser(
                widget.eventInstanceId, 
                currentUserId, 
                !_isExcited
              );
              setState(() {
                _isExcited = !_isExcited;
              });
              widget.onExcitementChanged();
            },
            child: Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: _isExcited 
                  ? Colors.orange.withOpacity(0.5)
                  : Colors.grey.withOpacity(0.5),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: _isExcited ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isExcited ? Colors.orange : Colors.grey,
                      ),
                      child: Center(
                        child: SvgIcon(
                          icon: SvgIconData('assets/icons/flame.svg'),
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 