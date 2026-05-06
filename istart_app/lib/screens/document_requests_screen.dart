// lib/screens/document_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/doc_request.dart';
import '../providers/doc_request_provider.dart';
import '../providers/idea_provider.dart';
import '../providers/auth_provider.dart';

class DocumentRequestsScreen extends StatefulWidget {
  const DocumentRequestsScreen({super.key});

  @override
  State<DocumentRequestsScreen> createState() => _DocumentRequestsScreenState();
}

class _DocumentRequestsScreenState extends State<DocumentRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final ideas = context.read<IdeaProvider>().ideas;
    final founderIdeas = ideas
        .where(
          (idea) =>
              idea.founder['_id'] == context.read<AuthProvider>().user?.id,
        )
        .toList();

    if (founderIdeas.isNotEmpty) {
      // Load requests for first founder's idea (or implement selection)
      final ideaId = founderIdeas.first.id;
      context.read<DocRequestProvider>().fetchRequestsForIdea(ideaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Requests'),
        elevation: 0,
        backgroundColor: const Color(0xFF0A0A0A),
      ),
      body: Consumer<DocRequestProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No document requests yet',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Investors will request documents here',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.requests.length,
            itemBuilder: (context, index) {
              final request = provider.requests[index];
              return _DocumentRequestCard(request: request);
            },
          );
        },
      ),
    );
  }
}

class _DocumentRequestCard extends StatefulWidget {
  final DocRequest request;

  const _DocumentRequestCard({required this.request});

  @override
  State<_DocumentRequestCard> createState() => _DocumentRequestCardState();
}

class _DocumentRequestCardState extends State<_DocumentRequestCard> {
  late TextEditingController _replyController;
  String? _selectedFileUrl;
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply message')),
      );
      return;
    }

    setState(() => _isReplying = true);

    final success = await context.read<DocRequestProvider>().replyToDocRequest(
      requestId: widget.request.id,
      replyMessage: _replyController.text.trim(),
      fileUrl: _selectedFileUrl,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<DocRequestProvider>().error ?? 'Failed to send reply',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => _isReplying = false);
  }

  void _showReplyDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Respond to Request',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Investor info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${widget.request.investor?['name'] ?? 'Investor'}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (widget.request.investor?['email'] != null)
                        Text(
                          widget.request.investor!['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Original request
                Text('Request:', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.request.requestMessage,
                    style: TextStyle(color: Colors.grey[300], fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),
                // Reply message field
                Text(
                  'Your Reply:',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _replyController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Type your response here...',
                    hintStyle: TextStyle(color: Colors.grey[600]),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[800]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF6C5CE7)),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                // File upload section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[800]!),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[900],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.attach_file,
                            size: 18,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileUrl != null
                                  ? 'File attached'
                                  : 'Attach a file (optional)',
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedFileUrl != null
                                    ? Colors.green[400]
                                    : Colors.grey[400],
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _selectFile,
                            child: Text(
                              _selectedFileUrl != null ? 'Change' : 'Select',
                            ),
                          ),
                        ],
                      ),
                      if (_selectedFileUrl != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'File: $_selectedFileUrl',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isReplying
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isReplying ? null : _sendReply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: _isReplying
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Send Reply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectFile() async {
    // TODO: Implement file picker
    // For now, show a simple dialog to enter file URL
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('File URL'),
        content: TextField(
          onChanged: (value) => _selectedFileUrl = value,
          decoration: const InputDecoration(hintText: 'Enter file URL or path'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d, yyyy');
    final timeFormatter = DateFormat('h:mm a');
    final isResponded = widget.request.status == 'responded';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF161616),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.request.investor?['name'] ?? 'Investor',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.request.investor?['email'] != null)
                        Text(
                          widget.request.investor!['email'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isResponded ? Colors.green[900] : Colors.orange[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isResponded ? 'Responded' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isResponded
                          ? Colors.green[200]
                          : Colors.orange[200],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            Text(
              '${dateFormatter.format(widget.request.createdAt)} at ${timeFormatter.format(widget.request.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 12),
            // Request message
            Text(
              'Request:',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.grey[400]),
            ),
            const SizedBox(height: 6),
            Text(
              widget.request.requestMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[200]),
            ),
            // Response (if exists)
            if (isResponded && widget.request.responseMessage != null) ...[
              const SizedBox(height: 16),
              Divider(color: Colors.grey[800]),
              const SizedBox(height: 12),
              Text(
                'Your Response:',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: Colors.green[400]),
              ),
              const SizedBox(height: 6),
              Text(
                widget.request.responseMessage!,
                style: TextStyle(fontSize: 14, color: Colors.grey[200]),
              ),
              if (widget.request.fileUrl != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // TODO: Open file
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.file_present,
                        size: 16,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.request.fileUrl!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            // Action buttons
            if (!isResponded)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showReplyDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Respond'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
