// lib/pages/items_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/supabase_service.dart';
import '../../models/item.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});
  @override
  ItemsPageState createState() => ItemsPageState();
}

class ItemsPageState extends State<ItemsPage> {
  late Future<List<Item>> _fetchFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() {
    final svc = Provider.of<SupabaseService>(context, listen: false);
    _fetchFuture = svc.fetchItems().then((_) => svc.items);
  }

  Future<void> _refresh() async {
    _loadItems();
    await _fetchFuture;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final svc          = Provider.of<SupabaseService>(context, listen: false);
    final currentEmail = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)], // Aqua → Mint gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      '✨ Preloved Picks Store',
                      style: GoogleFonts.lato(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: Colors.teal.shade900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.teal),
                      onPressed: () async {
                        await svc.signOut();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/signin', (_) => false);
                      },
                    ),
                  ],
                ),
              ),

              // Content grid
              Expanded(
                child: RefreshIndicator(
                  color: Colors.teal,
                  onRefresh: _refresh,
                  child: FutureBuilder<List<Item>>(
                    future: _fetchFuture,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.teal),
                        );
                      }
                      if (snap.hasError) {
                        return Center(
                          child: Text(
                            'Oops! ${snap.error}',
                            style: GoogleFonts.lato(color: Colors.redAccent),
                          ),
                        );
                      }
                      final items = snap.data!;
                      if (items.isEmpty) {
                        return Center(
                          child: Text(
                            'No treasures yet 🧐',
                            style: GoogleFonts.lato(
                              color: Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item    = items[i];
                          final isOwner = item.uploaderEmail == currentEmail;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [

                                Expanded(
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.network(
                                          item.imageUrl,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      if (isOwner)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: IconButton(
                                              icon: const Icon(
                                                  Icons.delete, size: 20),
                                              color: Colors.redAccent,
                                              onPressed: () async {
                                                await svc.deleteItem(item.id);
                                                await _refresh();
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),


                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Php ${item.price.toStringAsFixed(2)}',
                                        style: GoogleFonts.lato(
                                          fontSize: 14,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'By ${item.uploadedBy}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.lato(
                                          fontSize: 12,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                            padding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/detail',
                                              arguments: item.id,
                                            );
                                          },
                                          child: Text(
                                            'Details',
                                            style: GoogleFonts.lato(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),


              Padding(
                padding: const EdgeInsets.all(16),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Add New',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(context, '/add');
                    await _refresh();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
