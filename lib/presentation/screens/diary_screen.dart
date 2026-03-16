import 'package:flutter/material.dart';
import '../../core/style_guide.dart';
import '../widgets/smartur_skeleton.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mi Diario', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SmarturShimmer(
        enabled: _isLoading,
        child: _isLoading 
          ? _buildSkeletonList()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 5,
              itemBuilder: (context, index) => _buildDiaryCard(index),
            ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: List.generate(4, (index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: const SkeletonContainer(height: 120, borderRadius: 20),
      )),
    );
  }

  Widget _buildDiaryCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: SmarturStyle.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: SmarturStyle.purple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Recuerdo #${index + 1}", style: SmarturStyle.calSansTitle.copyWith(fontSize: 16)),
                const SizedBox(height: 4),
                const Text(
                  "Visitado el 12 de Oct, 2023",
                  style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
