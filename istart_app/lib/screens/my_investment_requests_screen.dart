// lib/screens/my_investment_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/investment_request_provider.dart';
import '../providers/auth_provider.dart';

class MyInvestmentRequestsScreen extends StatefulWidget {
  const MyInvestmentRequestsScreen({super.key});

  @override
  State<MyInvestmentRequestsScreen> createState() =>
      _MyInvestmentRequestsScreenState();
}

class _MyInvestmentRequestsScreenState
    extends State<MyInvestmentRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvestmentRequestProvider>().fetchMyRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final accent = const Color(0xFFF59E0B);
    final provider = context.watch<InvestmentRequestProvider>();
    final pendingRequests = provider.myPendingRequests;
    final approvedRequests = provider.myApprovedRequests;
    final loading = provider.loading;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          foregroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Investment Proposals',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
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
        ),
        body: TabBarView(
          children: [
            // Pending tab
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
                        message: 'No pending proposals',
                        icon: Icons.pending_outlined,
                      )
                    : RefreshIndicator(
                        color: accent,
                        backgroundColor: const Color(0xFF161616),
                        onRefresh: () => context
                            .read<InvestmentRequestProvider>()
                            .fetchMyRequests(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: pendingRequests.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) => _ProposalCard(
                            request: pendingRequests[i],
                            accent: accent,
                            isPending: true,
                          ),
                        ),
                      ),
            // Approved tab
            approvedRequests.isEmpty
                ? _EmptyState(
                    accent: accent,
                    message: 'No approved proposals yet',
                    icon: Icons.check_circle_outline,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: approvedRequests.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _ProposalCard(
                      request: approvedRequests[i],
                      accent: accent,
                      isPending: false,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

// ─── Proposal Card ────────────────────────────────────────────────────────────

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({
    required this.request,
    required this.accent,
    required this.isPending,
  });

  final dynamic request;
  final Color accent;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final ideaTitle = request.ideaId is Map
        ? (request.ideaId['title'] ?? 'Startup Idea')
        : 'Startup Idea';

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
            // Idea title + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    ideaTitle,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.amber.withOpacity(0.12)
                        : accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isPending ? 'Pending' : 'Approved',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPending ? Colors.amber : accent,
                    ),
                  ),
                ),
              ],
            ),
            if (request.fundingAmount != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: accent.withOpacity(0.7),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Proposed: \$${request.fundingAmount?.toStringAsFixed(0) ?? 'N/A'}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            if (request.message?.isNotEmpty ?? false) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.message ?? '',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              'Sent ${_formatDate(request.createdAt)}',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            if (!isPending && request.respondedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Approved ${_formatDate(request.respondedAt)}',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11,
                  color: accent.withOpacity(0.7),
                ),
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
  const _EmptyState({
    required this.accent,
    required this.message,
    required this.icon,
  });

  final Color accent;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
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