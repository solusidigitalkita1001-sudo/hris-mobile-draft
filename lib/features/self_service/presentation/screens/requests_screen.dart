import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/self_service/domain/entities/employee_request.dart';
import 'package:hrm_app/features/self_service/self_service_providers.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Requests',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
            onPressed: () => _showNewRequestSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark
              ? AppColors.darkTextSub
              : AppColors.lightTextSub,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(context, null),
          _buildList(context, RequestStatus.pending),
          _buildList(context, RequestStatus.approved),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, RequestStatus? filter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final requests = ref.watch(requestControllerProvider);
    final items = filter == null
        ? requests
        : requests.where((r) => r.status == filter).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Quick request types
        const SectionHeader(title: 'New Request'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _RequestTypeCard(
              icon: Icons.beach_access_rounded,
              label: 'Annual Leave',
              color: AppColors.primary,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
            _RequestTypeCard(
              icon: Icons.medical_services_rounded,
              label: 'Sick Leave',
              color: AppColors.danger,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
            _RequestTypeCard(
              icon: Icons.person_off_rounded,
              label: 'Permission',
              color: AppColors.purple,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
            _RequestTypeCard(
              icon: Icons.more_time_rounded,
              label: 'Overtime',
              color: AppColors.warning,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
            _RequestTypeCard(
              icon: Icons.edit_calendar_rounded,
              label: 'Attendance\nCorrection',
              color: AppColors.info,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
            _RequestTypeCard(
              icon: Icons.flight_takeoff_rounded,
              label: 'Business\nTrip',
              color: AppColors.success,
              isDark: isDark,
              onTap: () => _showNewRequestSheet(context),
            ),
          ],
        ),

        const SizedBox(height: 28),

        SectionHeader(
          title: 'Recent Requests',
          actionLabel: 'Filter',
          onAction: () {},
        ),

        const SizedBox(height: 14),

        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 48,
                    color: textSub.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No requests',
                    style: TextStyle(color: textSub, fontSize: 14),
                  ),
                ],
              ),
            ),
          )
        else
          ...items.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RequestCard(
                request: r,
                isDark: isDark,
                textPrimary: textPrimary,
                textSub: textSub,
                cardColor: cardColor,
                borderColor: borderColor,
              ),
            ),
          ),
      ],
    );
  }

  void _showNewRequestSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewRequestSheet(
        isDark: isDark,
        onSubmit: (type) =>
            ref.read(requestControllerProvider.notifier).submit(type),
      ),
    );
  }
}

class _RequestTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _RequestTypeCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final EmployeeRequest request;
  final bool isDark;
  final Color textPrimary;
  final Color textSub;
  final Color cardColor;
  final Color borderColor;

  const _RequestCard({
    required this.request,
    required this.isDark,
    required this.textPrimary,
    required this.textSub,
    required this.cardColor,
    required this.borderColor,
  });

  IconData get _typeIcon {
    switch (request.type) {
      case 'Annual Leave':
        return Icons.beach_access_rounded;
      case 'Sick Leave':
        return Icons.medical_services_rounded;
      case 'Overtime Claim':
        return Icons.more_time_rounded;
      case 'WFH Request':
        return Icons.home_work_rounded;
      case 'Business Trip':
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  Color get _typeColor {
    switch (request.type) {
      case 'Annual Leave':
        return AppColors.primary;
      case 'Sick Leave':
        return AppColors.danger;
      case 'Overtime Claim':
        return AppColors.warning;
      case 'WFH Request':
        return AppColors.success;
      case 'Business Trip':
        return AppColors.purple;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.type,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  request.dateRange,
                  style: TextStyle(fontSize: 11, color: textSub),
                ),
                const SizedBox(height: 3),
                Text(
                  'Submitted ${request.submittedOn}',
                  style: TextStyle(
                    fontSize: 11,
                    color: textSub.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          _requestBadge(request.status),
        ],
      ),
    );
  }

  StatusBadge _requestBadge(RequestStatus status) => switch (status) {
    RequestStatus.approved => const StatusBadge(
      label: 'Approved',
      backgroundColor: Color(0xffDCFCE7),
      textColor: Color(0xff166534),
    ),
    RequestStatus.pending => const StatusBadge(
      label: 'Pending',
      backgroundColor: Color(0xffFEF3C7),
      textColor: Color(0xff92400E),
    ),
    RequestStatus.rejected => const StatusBadge(
      label: 'Rejected',
      backgroundColor: Color(0xffFEE2E2),
      textColor: Color(0xff991B1B),
    ),
  };
}

class _NewRequestSheet extends StatefulWidget {
  final bool isDark;
  final Future<void> Function(String type) onSubmit;

  const _NewRequestSheet({required this.isDark, required this.onSubmit});

  @override
  State<_NewRequestSheet> createState() => _NewRequestSheetState();
}

class _NewRequestSheetState extends State<_NewRequestSheet> {
  String _selectedType = 'Annual Leave';
  final List<String> _types = [
    'Annual Leave',
    'Sick Leave',
    'Personal Leave',
    'Overtime',
    'WFH Request',
    'Business Trip',
    'Attendance Correction',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final sheetColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: sheetColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'New Request',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Request Type',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSub,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _types
                .map(
                  (t) => GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedType == t
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkBg
                                  : AppColors.lightMuted),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedType == t
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _selectedType == t ? Colors.white : textSub,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSub,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSub
                      : AppColors.lightTextSub,
                ),
                const SizedBox(width: 10),
                Text(
                  'Select date range',
                  style: TextStyle(fontSize: 13, color: textSub),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Reason (optional)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSub,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBg : AppColors.lightMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: TextField(
              maxLines: 3,
              style: TextStyle(fontSize: 13, color: textPrimary),
              decoration: InputDecoration.collapsed(
                hintText: 'Add a note for your manager...',
                hintStyle: TextStyle(color: textSub, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await widget.onSubmit(_selectedType);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Submit Request',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
