import 'package:flutter/material.dart';
import 'package:goal_master/core/styles/app_text_styles.dart';
import 'package:goal_master/core/styles/spaces.dart';
import 'package:goal_master/core/utils/arabic_dates.dart';

class EventCard extends StatelessWidget {
  final String date;
  final String startTime;
  final String endTime;

  /// The booking's real start and end.
  ///
  /// Optional so the older caller keeps working, but strongly preferred: with
  /// them the card can say «11:00 مساءً – 12:00 منتصف الليل» and name the day
  /// the session actually STARTS. Without them it falls back to whatever
  /// pre-formatted strings it was handed — which is how this card came to
  /// print «00:00 - 23:00» under a date a day later than the booking.
  final DateTime? startAt;
  final DateTime? endAt;
  final String club;
  final String categoryName;
  final String serviceTitle;
  final String address;

  const EventCard({
    Key? key,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.startAt,
    this.endAt,
    required this.club,
    required this.categoryName,
    required this.serviceTitle,
    required this.address,
  }) : super(key: key);

  bool get _crossesMidnight =>
      startAt != null &&
      endAt != null &&
      (startAt!.year != endAt!.year ||
          startAt!.month != endAt!.month ||
          startAt!.day != endAt!.day);

  String _clock(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date and time, stacked rather than squeezed side by side.
              //
              // The old two-column row could not fit a readable Arabic time,
              // so it showed a bare "23:00" — and because the range was built
              // as '$startTime - $endTime' inside an Arabic paragraph, the
              // bidi algorithm reordered it on screen into "00:00 - 23:00".
              // One phrase, written right-to-left, cannot be reordered.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التاريخ',
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  HeightSpace(4),
                  _buildInfoChip(
                    icon: Icons.calendar_month,
                    // The day the session STARTS. A booking at 11 at night
                    // belongs to that night, not to the morning it spills into.
                    text: startAt != null
                        ? formatArabicDayAndDate(startAt!)
                        : date,
                    color: Colors.blue[700]!,
                  ),

                  // Only when it genuinely crosses midnight — otherwise this
                  // is noise on every ordinary booking.
                  if (_crossesMidnight) ...[
                    HeightSpace(6),
                    Row(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          size: 14,
                          color: Colors.indigo[400],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ينتهي بعد منتصف الليل — ${formatArabicDayAndDate(endAt!)}',
                            style: AppTextStyles.font12Medium.copyWith(
                              color: Colors.indigo[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  HeightSpace(14),

                  Text(
                    'الوقت',
                    style: AppTextStyles.font16Bold.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  HeightSpace(4),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    text: (startAt != null && endAt != null)
                        ? formatArabicTimeRange(
                            _clock(startAt!),
                            _clock(endAt!),
                          )
                        : '$startTime - $endTime',
                    color: Colors.orange[700]!,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildInfoRow(
                icon: Icons.sports_soccer,
                title: 'النادي',
                value: club,
                iconColor: Colors.green,
              ),

              const SizedBox(height: 12),

              _buildInfoRow(
                icon: Icons.category,
                title: 'الفئة',
                value: categoryName,
                iconColor: Colors.purple,
              ),

              const SizedBox(height: 12),

              _buildInfoRow(
                icon: Icons.work,
                title: 'الخدمة',
                value: serviceTitle,
                iconColor: Colors.blue,
              ),

              const SizedBox(height: 16),

              // Address section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red[600],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'العنوان',
                          style: AppTextStyles.font14Medium.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: AppTextStyles.font16Regular.copyWith(
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.font14Medium.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: iconColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.font14Medium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.font16Regular.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
