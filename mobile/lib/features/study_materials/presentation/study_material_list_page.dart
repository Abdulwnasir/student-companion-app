import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/study_material_model.dart';
import '../presentation/study_material_bloc.dart';
import '../presentation/study_material_event.dart';
import '../presentation/study_material_state.dart';

class StudyMaterialListPage extends StatefulWidget {
  const StudyMaterialListPage({super.key});

  @override
  State<StudyMaterialListPage> createState() => _StudyMaterialListPageState();
}

class _StudyMaterialListPageState extends State<StudyMaterialListPage> {
  final _searchController = TextEditingController();
  String? _selectedCourse;
  bool _isDownloading = false;

  // Available courses for filter
  final List<String> _availableCourses = [
    'All',
    'Computer Science',
    'Data Science',
    'Software Engineering',
    'Information Technology',
    'Electrical Engineering',
  ];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  void _loadMaterials() {
    context.read<StudyMaterialBloc>().add(
      LoadMaterials(query: _searchController.text, course: _selectedCourse),
    );
  }

  void _onSearchChanged(String query) {
    _loadMaterials();
  }

  void _filterByCourse(String? course) {
    setState(() {
      _selectedCourse = course == 'All' ? null : course;
    });
    _loadMaterials();
  }

  Future<void> _downloadAndOpenFile(StudyMaterial material) async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      // Get base URL from environment or use default IP
      final baseUrl = dotenv.env['API_BASE_URL']?.replaceAll('/api', '') ?? 
          'http://10.141.120.211:3000';
      final fullUrl = '$baseUrl${material.fileUrl}';

      final uri = Uri.parse(fullUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open the material URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: ${e.toString().substring(0, 100)}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showUploadDialog() {
    final titleController = TextEditingController();
    final courseController = TextEditingController();
    File? selectedFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Upload Material'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: courseController,
                decoration: const InputDecoration(
                  labelText: 'Course Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result != null && result.files.single.path != null) {
                        setState(() {
                          selectedFile = File(result.files.single.path!);
                        });
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Pick File'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : 'No file selected',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedFile != null ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    courseController.text.isNotEmpty &&
                    selectedFile != null) {
                  context.read<StudyMaterialBloc>().add(
                    UploadMaterial(
                      titleController.text,
                      courseController.text,
                      selectedFile!,
                    ),
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Uploading material...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getFileTypeIcon(String fileType) {
    IconData icon;
    Color color;
    
    switch (fileType.toUpperCase()) {
      case 'PDF':
        icon = Icons.picture_as_pdf;
        color = Colors.red;
        break;
      case 'DOC':
      case 'DOCX':
        icon = Icons.description;
        color = Colors.blue;
        break;
      case 'PPT':
      case 'PPTX':
        icon = Icons.slideshow;
        color = Colors.orange;
        break;
      case 'VIDEO':
        icon = Icons.video_library;
        color = Colors.purple;
        break;
      case 'LINK':
        icon = Icons.link;
        color = Colors.teal;
        break;
      default:
        icon = Icons.insert_drive_file;
        color = AppTheme.primary;
    }
    
    return Icon(icon, color: color, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Materials'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMaterials,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search materials...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // Course Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _availableCourses.length,
              itemBuilder: (context, index) {
                final course = _availableCourses[index];
                final isSelected = (_selectedCourse == null && course == 'All') ||
                    (_selectedCourse == course);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(course),
                    selected: isSelected,
                    onSelected: (_) => _filterByCourse(course),
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primary.withOpacity(0.2),
                    checkmarkColor: AppTheme.primary,
                  ),
                );
              },
            ),
          ),
          // Materials List
          Expanded(
            child: BlocBuilder<StudyMaterialBloc, StudyMaterialState>(
              builder: (context, state) {
                if (state.status == StudyMaterialStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == StudyMaterialStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Error: ${state.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMaterials,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.materials.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No materials found',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Materials shared with your section will appear here',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadMaterials();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: state.materials.length,
                    itemBuilder: (context, index) {
                      final material = state.materials[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () => _downloadAndOpenFile(material),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // File Type Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: _getFileTypeIcon(material.fileType),
                                ),
                                const SizedBox(width: 12),
                                // Material Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        material.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        material.courseName,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('MMM d, yyyy').format(material.createdAt),
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 11,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: material.isPublic
                                                  ? Colors.green.withOpacity(0.2)
                                                  : Colors.orange.withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              material.isPublic ? 'Public' : 'Shared',
                                              style: TextStyle(
                                                color: material.isPublic ? Colors.green : Colors.orange,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Download Button
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: IconButton(
                                    icon: _isDownloading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.download_rounded),
                                    color: AppTheme.primary,
                                    onPressed: _isDownloading
                                        ? null
                                        : () => _downloadAndOpenFile(material),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }
}
