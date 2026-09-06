import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/modules/attendance/attendance_models.dart';
import 'package:synthinnotech/modules/attendance/attendance_view_model.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  bool _teamView = false;
  DateTime _teamDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final canSeeTeam = user?.can(Permission.viewAllAttendance) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w700, color: Colors.white)),
        bottom: canSeeTeam
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: SegmentedButton<bool>(
                    style: SegmentedButton.styleFrom(
                      foregroundColor: Colors.white,
                      selectedForegroundColor:
                          Theme.of(context).colorScheme.primary,
                      selectedBackgroundColor: Colors.white,
                    ),
                    segments: const [
                      ButtonSegment(value: false, label: Text('Me')),
                      ButtonSegment(value: true, label: Text('Team')),
                    ],
                    selected: {_teamView},
                    onSelectionChanged: (s) =>
                        setState(() => _teamView = s.first),
                  ),
                ),
              )
            : null,
      ),
      body: _teamView ? _buildTeam(context) : _buildMine(context),
    );
  }

  Widget _buildMine(BuildContext context) {
    final state = ref.watch(attendanceViewModelProvider);
    final vm = ref.read(attendanceViewModelProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = state.today;
    final status = today?.status ?? AttendanceStatus.absent;

    return RefreshIndicator(
      onRefresh: vm.refreshHistory,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [status.color, status.color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(DateFormat('EEEE, MMM d').format(DateTime.now()),
                    style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(status.label,
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(
                  today?.checkIn != null
                      ? 'In ${DateFormat.jm().format(today!.checkIn!)}'
                          '${today.checkOut != null ? '  •  Out ${DateFormat.jm().format(today.checkOut!)}' : ''}'
                          '   ·   ${today.workedLabel}'
                      : 'You haven\'t checked in yet',
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.busy || status == AttendanceStatus.done
                        ? null
                        : () {
                            if (status == AttendanceStatus.absent) {
                              vm.checkIn();
                            } else {
                              vm.checkOut();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: status.color,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: state.busy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            switch (status) {
                              AttendanceStatus.absent => 'Check In',
                              AttendanceStatus.working => 'Check Out',
                              AttendanceStatus.done => 'All done for today',
                            },
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                  label: 'Present (30d)',
                  value: '${state.presentDays}',
                  icon: Icons.event_available_outlined),
              const SizedBox(width: 12),
              _MiniStat(
                  label: 'Hours (30d)',
                  value: '${state.monthWorked.inHours}h',
                  icon: Icons.timelapse_outlined),
            ],
          ),
          const SizedBox(height: 20),
          Text('Recent days',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface.withValues(alpha: 0.6))),
          const SizedBox(height: 8),
          if (state.history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('No attendance history yet',
                    style: GoogleFonts.inter(
                        color: cs.onSurface.withValues(alpha: 0.5))),
              ),
            )
          else
            ...state.history.map((r) => _HistoryTile(record: r)),
        ],
      ),
    );
  }

  Widget _buildTeam(BuildContext context) {
    final async = ref.watch(teamAttendanceProvider(_teamDay));
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.calendar_today_outlined),
          title: Text(DateFormat('EEEE, MMM d, y').format(_teamDay),
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.edit_calendar_outlined),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _teamDay,
              firstDate: DateTime(2023),
              lastDate: DateTime.now(),
            );
            if (picked != null) setState(() => _teamDay = picked);
          },
        ),
        const Divider(height: 1),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
                child: Text('$e',
                    style: GoogleFonts.inter(color: cs.error))),
            data: (records) => records.isEmpty
                ? Center(
                    child: Text('No one checked in on this day',
                        style: GoogleFonts.inter(
                            color: cs.onSurface.withValues(alpha: 0.5))))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children:
                        records.map((r) => _HistoryTile(record: r, showName: true)).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.icon});
  final String label, value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.record, this.showName = false});
  final AttendanceRecord record;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = record.status;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: s.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(showName ? record.userName : record.day,
                    style: GoogleFonts.inter(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(
                  [
                    if (record.checkIn != null)
                      'In ${TimeOfDay.fromDateTime(record.checkIn!).format(context)}',
                    if (record.checkOut != null)
                      'Out ${TimeOfDay.fromDateTime(record.checkOut!).format(context)}',
                  ].join('  •  '),
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurface.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Text(record.workedLabel,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: s.color)),
        ],
      ),
    );
  }
}
