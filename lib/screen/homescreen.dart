import 'package:flutter/material.dart';
import 'package:traveljournal/auth/auth_service.dart';
import 'package:traveljournal/models/journal.dart';
import 'package:traveljournal/services/journal_service.dart';
import 'package:traveljournal/widgets/custom_app_bar.dart';
import 'package:traveljournal/widgets/journal_card.dart';
import 'package:traveljournal/screen/journal_details_screen.dart';
import 'package:traveljournal/screen/journal_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final JournalService _journalService = JournalService();
  String _userEmail = '';
  List<Journal> _journals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadJournals();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _loadJournals() async {
    try {
      final journals = await _journalService.getJournals();
      if (mounted) {
        setState(() {
          _journals = journals;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load journals: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(userEmail: _userEmail, authService: _authService),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _journals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No journals yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Create your first travel memory!',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadJournals,
              child: ListView.builder(
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
    );
  }
}
