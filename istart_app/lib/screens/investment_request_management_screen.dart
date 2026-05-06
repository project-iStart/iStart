// lib/screens/investment_request_management_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/startup_idea.dart';
import '../providers/investment_request_provider.dart';
import '../providers/auth_provider.dart';
import 'profile/public_profile_screen.dart';

class InvestmentRequestManagementScreen extends StatefulWidget {
  final StartupIdea idea;

  const InvestmentRequestManagementScreen({super.key, required this.idea});

  @override
  State<InvestmentRequestManagementScreen> createState() =>
      _InvestmentRequestManagementScreenState();
}

class _InvestmentRequestManagementScreenState
    extends State<InvestmentRequestManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentRequestProvider>().fetchRequestsForIdea(
        widget.idea.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final accent = _accentForRole(user?.role ?? 'founder');
    final provider = context.watch<InvestmentRequestProvider>();
    final pendingRequests = provider.pendingRequests;
    final approvedRequests = provider.approvedRequests;
    final loading = provider.loading;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161616),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white.withOpacity(0.7),
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Funding Requests',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            widget.idea.title,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: accent,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                indicatorColor: accent,
                labelStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'Pending (${pendingRequests.length})'),
                  Tab(text: 'Approved (${approvedRequests.length})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: accent,
                              strokeWidth: 2,
                            ),
                          )
                        : pendingRequests.isEmpty
                        ? _EmptyState(
                            accent: accent,
                            message: 'No pending funding requests',
                          )
                        : RefreshIndicator(
                            color: accent,
                            backgroundColor: const Color(0xFF161616),
                            onRefresh: () => context
                                .read<InvestmentRequestProvider>()
                                .fetchRequestsForIdea(widget.idea.id),
                            child: ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: pendingRequests.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, i) =>
                                  _InvestmentRequestCard(
                                    request: pendingRequests[i],
                                    accent: accent,
                                    isPending: true,
                                  ),
                            ),
                          ),
                    approvedRequests.isEmpty
                        ? _EmptyState(
                            accent: accent,
                            message: 'No approved investors yet',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: approvedRequests.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) => _InvestmentRequestCard(
                              request: approvedRequests[i],
                              accent: accent,
                              isPending: false,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _accentForRole(String role) {
    switch (role) {
      case 'collaborator':
        return const Color(0xFF10B981);
      case 'investor':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6366F1);
    }
  }
}

// ─── Investment Request Card ──────────────────────────────────────────────────

class _InvestmentRequestCard extends StatefulWidget {
  const _InvestmentRequestCard({
    required this.request,
    required this.accent,
    required this.isPending,
  });

  final dynamic request;
  final Color accent;
  final bool isPending;

  @override
  State<_InvestmentRequestCard> createState() => _InvestmentRequestCardState();
}

class _InvestmentRequestCardState extends State<_InvestmentRequestCard> {
  bool _isProcessing = false;

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);
    final success = await context
        .read<InvestmentRequestProvider>()
        .approveRequest(widget.request.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Investor approved!'),
          backgroundColor: widget.accent,
        ),
      );
    }
  }

  Future<void> _handleReject() async {
    setState(() => _isProcessing = true);
    final success = await context
        .read<InvestmentRequestProvider>()
        .rejectRequest(widget.request.id);
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Request rejected'),
          backgroundColor: Colors.red.withOpacity(0.8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final investorId = (widget.request.investorId ?? '') as String;
    final investorName = (widget.request.investorName ?? '') as String;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Investor header row
            GestureDetector(
              onTap: investorId.isEmpty
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PublicProfileScreen(
                            userId: investorId,
                            userName: investorName,
                          ),
                        ),
                      );
                    },
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: widget.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        investorName.isNotEmpty
                            ? investorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: widget.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          investorName,
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.request.investorEmail ?? '',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isPending
                          ? Colors.amber.withOpacity(0.12)
                          : widget.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.isPending ? 'Pending' : 'Approved',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: widget.isPending ? Colors.amber : widget.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.request.fundingAmount != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: widget.accent.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Requested Amount: \$${widget.request.fundingAmount?.toStringAsFixed(0) ?? 'N/A'}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (widget.request.message?.isNotEmpty ?? false) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.request.message ?? '',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Submitted ${_formatDate(widget.request.createdAt)}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            if (widget.isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isProcessing ? null : _handleReject,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.red.withOpacity(0.5),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handleApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accent,
                        disabledBackgroundColor: widget.accent.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.8),
                                ),
                              ),
                            )
                          : const Text(
                              'Approve',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.month}/${date.day}/${date.year}';
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.accent, required this.message});

  final Color accent;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.attach_money_rounded,
            size: 48,
            color: accent.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
