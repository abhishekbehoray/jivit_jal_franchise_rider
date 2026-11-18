import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:jivit_jal_2/Utils/AppColors.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';

class LegalContentScreen extends StatefulWidget {
  final String type; // 'privacy_policy' or 'terms_and_conditions'
  final String title;

  const LegalContentScreen({
    super.key,
    required this.type,
    required this.title,
  });

  @override
  State<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends State<LegalContentScreen> {
  final _repo = FranchiseRepository();

  String? _heading;
  String? _content;
  String? _updatedAt;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getLegalContent(widget.type);
      setState(() {
        _heading = data['heading'];
        _content = data['content'];
        _updatedAt = data['updatedAt'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _fetch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.primaryBlue,
                    onRefresh: _fetch,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: 4,
                        right: 4,
                        bottom: MediaQuery.of(context).padding.bottom + 26,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Html(
                            data: _content ?? '',
                            style: {
                              'body': Style(
                                fontSize: FontSize(14),
                                color: AppColors.textSecondary,
                                lineHeight: const LineHeight(1.6),
                                margin: Margins.zero,
                                padding: HtmlPaddings.symmetric(
                                    horizontal: 16, vertical: 8),
                              ),
                              'h2': Style(
                                fontSize: FontSize(17),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                margin: Margins.only(top: 20, bottom: 6),
                              ),
                              'h3': Style(
                                fontSize: FontSize(15),
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                margin: Margins.only(top: 12, bottom: 4),
                              ),
                              'p': Style(
                                margin: Margins.only(bottom: 8),
                              ),
                              'ul': Style(
                                margin: Margins.only(bottom: 8, left: 8),
                              ),
                              'li': Style(
                                margin: Margins.only(bottom: 4),
                              ),
                            },
                          ),
                          if (_updatedAt != null && _updatedAt!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.update_outlined,
                                        size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Last Updated: ${_formatDate(_updatedAt)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
