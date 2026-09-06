import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:synthinnotech/core/rbac/app_role.dart';
import 'package:synthinnotech/modules/auth/application/auth_providers.dart';
import 'package:synthinnotech/modules/leave/leave_models.dart';
import 'package:synthinnotech/modules/leave/leave_view_model.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final canApprove = user?.can(Permission.approveLeave) ?? false;

    return DefaultTabController(
      length: canApprove ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leave',
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, color: Colors.white)),
          bottom: canApprove
              ? const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [Tab(text: 'My requests'), Tab(text: 'Approvals')],
                )
              : null,
        ),
        body: TabBarView(
          children: [
            const _MyRequestsTab(),
            if (canApprove) const _ApprovalsTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showRequestSheet(context, ref),
          icon: const Icon(Icons.add),
          label: Text('Request leave',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void _showRequestSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RequestLeaveSheet(),
    );
  }
}

class _MyRequestsTab extends ConsumerWidget {
  const _MyRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myLeaveProvider);
    final cs = Theme.of(context).colorScheme;
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return _Empty(
          icon: Icons.event_note_outlined,
          text: 'No leave requests yet.\nTap "Request leave" to add one.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: state.items
          .map((r) => _LeaveCard(
                request: r,
                trailing: r.status == LeaveStatus.pending
                    ? TextButton(
                        onPressed: () =>
                            ref.read(myLeaveProvider.notifier).cancel(r),
                        child: Text('Cancel',
                            style: GoogleFonts.inter(color: cs.error)),
                      )
                    : null,
              ))
          .toList(),
    );
  }
}

class _ApprovalsTab extends ConsumerWidget {
  const _ApprovalsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pendingLeaveProvider);
    if (state.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.items.isEmpty) {
      return const _Empty(
          icon: Icons.inbox_outlined, text: 'Nothing waiting for approval.');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: state.items.map((r) {
        return _LeaveCard(
          request: r,
          showName: true,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Color(0xFFF44336)),
                onPressed: () => ref
                    .read(pendingLeaveProvider.notifier)
                    .decide(r, false),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF4CAF50)),
                onPressed: () =>
                    ref.read(pendingLeaveProvider.notifier).decide(r, true),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard(
      {required this.request, this.trailing, this.showName = false});
  final LeaveRequest request;
  final Widget? trailing;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('MMM d');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(request.type.icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text('${request.type.label} leave',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: request.status.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(request.status.label,
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: request.status.color)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (showName)
            Text(request.userName,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface.withValues(alpha: 0.7))),
          Text(
            '${df.format(request.from)} – ${df.format(request.to)}'
            '  ·  ${request.days} day${request.days == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
                fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(request.reason,
                style: GoogleFonts.inter(fontSize: 13, height: 1.4)),
          ],
          if (request.reviewerName != null) ...[
            const SizedBox(height: 6),
            Text(
                '${request.status.label} by ${request.reviewerName}'
                '${request.reviewNote?.isNotEmpty == true ? ' — ${request.reviewNote}' : ''}',
                style: GoogleFonts.inter(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurface.withValues(alpha: 0.55))),
          ],
          if (trailing != null)
            Align(alignment: Alignment.centerRight, child: trailing!),
        ],
      ),
    );
  }
}

class _RequestLeaveSheet extends ConsumerStatefulWidget {
  const _RequestLeaveSheet();

  @override
  ConsumerState<_RequestLeaveSheet> createState() => _RequestLeaveSheetState();
}

class _RequestLeaveSheetState extends ConsumerState<_RequestLeaveSheet> {
  LeaveType _type = LeaveType.casual;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now();
  final _reason = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pick(bool from) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: from ? _from : _to,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      if (from) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final ok = await ref.read(myLeaveProvider.notifier).submit(
          type: _type,
          from: _from,
          to: _to,
          reason: _reason.text,
        );
    if (mounted) {
      setState(() => _saving = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final df = DateFormat('EEE, MMM d');
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Request Leave',
              style: GoogleFonts.inter(
                  fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: LeaveType.values.map((t) {
              final sel = _type == t;
              return ChoiceChip(
                label: Text(t.label),
                selected: sel,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(true),
                  icon: const Icon(Icons.calendar_today_outlined, size: 16),
                  label: Text(df.format(_from),
                      style: GoogleFonts.inter(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pick(false),
                  icon: const Icon(Icons.event_outlined, size: 16),
                  label: Text(df.format(_to),
                      style: GoogleFonts.inter(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reason,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Submit request',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: cs.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                    color: cs.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      ),
    );
  }
}
