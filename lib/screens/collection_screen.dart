import 'package:flutter/material.dart';

import '../models/character_presentation.dart';
import '../models/dajare_entry.dart';
import '../services/dajare_collection_service.dart';
import '../widgets/primary_action_button.dart';
import 'dajare_input_screen.dart';

typedef DajareEntriesLoader = Future<List<DajareEntry>> Function();

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key, this.loadEntries});

  final DajareEntriesLoader? loadEntries;

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  late Future<List<DajareEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final loader =
        widget.loadEntries ?? const DajareCollectionService().loadEntries;
    _entries = loader();
  }

  void _retry() {
    setState(_load);
  }

  void _openInput() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const DajareInputScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ダジャレ図鑑')),
      body: SafeArea(
        child: FutureBuilder<List<DajareEntry>>(
          future: _entries,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CollectionLoading();
            }
            if (snapshot.hasError) {
              return _CollectionError(onRetry: _retry);
            }

            final entries = snapshot.data ?? const [];
            if (entries.isEmpty) {
              return _CollectionEmpty(onCreate: _openInput);
            }

            return ListView.separated(
              key: const Key('collection_list'),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              itemCount: entries.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _DajareEntryCard(entry: entries[index], index: index),
            );
          },
        ),
      ),
    );
  }
}

class _DajareEntryCard extends StatelessWidget {
  const _DajareEntryCard({required this.entry, required this.index});

  final DajareEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    final reaction = CharacterPresentation.reactionForLevel(entry.level);
    final date = '${entry.createdAt.month}/${entry.createdAt.day}';

    return Card(
      key: Key('collection_entry_$index'),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.submittedText,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${entry.score}点',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(CharacterPresentation.reactionLabel(reaction)),
              ],
            ),
            const SizedBox(height: 10),
            Text(entry.comment, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                date,
                key: Key('collection_entry_date_$index'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionLoading extends StatelessWidget {
  const _CollectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('ダジャレ図鑑をよみこみ中！'),
        ],
      ),
    );
  }
}

class _CollectionEmpty extends StatelessWidget {
  const _CollectionEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.menu_book_rounded, size: 72),
              const SizedBox(height: 20),
              Text(
                'まだダジャレがないよ！\nひとつ作ってみよう！',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 28),
              PrimaryActionButton(
                label: 'ダジャレを作る',
                icon: Icons.edit_rounded,
                onPressed: onCreate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionError extends StatelessWidget {
  const _CollectionError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ダジャレ図鑑をよみこめなかったみたい。\nもういちどためしてみてね！',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              PrimaryActionButton(
                label: 'もういちどよみこむ',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
