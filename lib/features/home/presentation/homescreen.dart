import 'package:flutter/material.dart';
import 'package:traveljournal/features/auth/data/auth_service.dart';
import 'package:traveljournal/features/journal/models/journal.dart';
import 'package:traveljournal/features/journal/data/journal_service.dart';
import 'package:traveljournal/widgets/custom_app_bar.dart';
import 'package:traveljournal/features/journal/presentation/journal_card.dart';
import 'package:traveljournal/features/journal/presentation/journal_details_screen.dart';
import 'package:traveljournal/features/journal/presentation/journal_form_screen.dart';
import 'package:traveljournal/widgets/refreshable_view.dart';
import 'package:traveljournal/widgets/connection_lost_screen.dart';
import 'package:traveljournal/services/connectivity_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final JournalService _journalService = JournalService();
  final ConnectivityService _connectivityService = ConnectivityService();
  String _userEmail = '';
  List<Journal> _journals = [];
  bool _isLoading = true;
  String? _error;
  bool _isConnected = true;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    if (_isConnected) {
      _loadJournals();
    }
    _connectivityService.connectionStatusController.stream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (!isConnected) {
            _error = null;
            _isLoading = false;
          } else {
            _loadJournals();
          }
        });
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && mounted) {
        setState(() {
          _userEmail = user.email ?? '';
        });
      }
    } catch (e) {
      // Non-critical error, just log it
    }
  }

  Future<void> _loadJournals() async {
    if (!mounted) return;

    if (!_isConnected) {
      setState(() {
        _isLoading = false;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final journals = await _journalService.getJournals();
      if (!mounted) return;

      setState(() {
        _journals = journals;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load journals: $e';
        _isLoading = false;
      });
    }
  }

  void _createNewJournal() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const JournalFormScreen()),
    );

    if (created == true && mounted) {
      _loadJournals();
    }
  }

  void _viewJournalDetails(Journal journal) async {
    final needsRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => JournalDetailsScreen(journal: journal),
      ),
    );

    if (needsRefresh == true && mounted) {
      _loadJournals();
    }
  }

  Future<void> _retryConnection() async {
    setState(() => _isRetrying = true);
    await _connectivityService.checkConnectionStatus();
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(userEmail: _userEmail, authService: _authService),
          body: RefreshableView(
            onRefresh: _loadJournals,
            isLoading: _isLoading,
            errorMessage: _isConnected ? _error : null,
            emptyMessage: _journals.isEmpty
                ? 'Start your journey by creating your first travel memory!'
                : null,
            onRetry: _loadJournals,
            builder: (context) => ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _journals.length,
              itemBuilder: (context, index) {
                final journal = _journals[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: JournalCard(
                    journal: journal,
                    onTap: () => _viewJournalDetails(journal),
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _createNewJournal,
            backgroundColor: const Color(0xFF1E201E),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
        ),
        if (!_isConnected)
          ConnectionLostScreen(
            onRetry: _retryConnection,
            isRetrying: _isRetrying,
          ),
      ],
    );
  }
} 