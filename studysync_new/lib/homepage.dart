import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'study_room_page.dart';
import 'dart:async';
import 'task_manager.dart'; // Added import for TaskManager

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  late Box _uploadBox;
  final TextEditingController _notesController = TextEditingController();
  final List<String> _notes = [];
  final TextEditingController _roomIdController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeHiveBox();
  }

  Future<void> _initializeHiveBox() async {
    _uploadBox = await Hive.openBox('uploads');
    setState(() {});
  }

  Future<void> _pickAndSaveFile({bool isImage = true}) async {
    FilePickerResult? result;

    if (isImage) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final int fileSize = await file.length();
        result = FilePickerResult([
          PlatformFile(
            path: pickedFile.path,
            name: pickedFile.name,
            size: fileSize,
          )
        ]);
      }
    } else {
      result = await FilePicker.platform.pickFiles(type: FileType.any);
    }

    if (result != null && result.files.isNotEmpty) {
      final File file = File(result.files.single.path!);
      final directory = await getApplicationDocumentsDirectory();
      final String newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final File savedFile = await file.copy(newPath);

      _uploadBox.add(savedFile.path);
      setState(() {});
    }
  }

  void _deleteFile(int index) {
    final String filePath = _uploadBox.getAt(index) as String;
    final File file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    _uploadBox.deleteAt(index);
    setState(() {});
  }

  void _showFullScreenImage(String imagePath) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              Center(
                child: Image.file(File(imagePath), fit: BoxFit.contain),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNote() {
    if (_notesController.text.isNotEmpty) {
      setState(() {
        _notes.add(_notesController.text);
        _notesController.clear();
      });
    }
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _createStudyRoom() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Create Study Room',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          content: TextField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              hintText: 'Enter your nickname',
              hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nicknameController.text.trim().isNotEmpty) {
                  final roomId = DateTime.now().millisecondsSinceEpoch.toString();
                  _uploadBox.put('currentRoom', roomId);
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyRoomPage(
                        roomId: roomId,
                        isCreator: true,
                        nickname: _nicknameController.text.trim(),
                        uploadedFiles: _uploadBox.values.cast<String>().toList(),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a nickname')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Create', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _joinStudyRoom() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Join Study Room',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              color: Colors.deepPurple,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roomIdController,
                decoration: const InputDecoration(
                  hintText: 'Enter Room ID',
                  hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  hintText: 'Enter your nickname',
                  hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins')),
            ),
            ElevatedButton(
              onPressed: () {
                final roomId = _roomIdController.text.trim();
                final nickname = _nicknameController.text.trim();
                final storedRoom = _uploadBox.get('currentRoom') as String?;
                if (roomId.isEmpty || nickname.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                } else if (storedRoom != null && roomId == storedRoom) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudyRoomPage(
                        roomId: roomId,
                        isCreator: false,
                        nickname: nickname,
                        uploadedFiles: _uploadBox.values.cast<String>().toList(),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid Room ID')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text('Join', style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        );
      },
    );
  }

  void _showPomodoroTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PomodoroTimerSheet(),
    );
  }

  // New method to show TaskManager page
  void _showTaskManager() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TaskManager()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('uploads')) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'StudySync',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [Colors.purple, Colors.pink, Colors.orange],
                      ).createShader(bounds);
                    },
                    child: const Text(
                      'Welcome to\nStudySync',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.15,
                        fontFamily: 'Poppins',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Sync up, stay motivated, and ace your goals!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  FeatureCard(
                    icon: Icons.group_add,
                    label: 'Join Study Room',
                    description: 'Collaborate with others in real-time study sessions.',
                    color: Colors.purple,
                    onTap: _joinStudyRoom,
                  ),
                  const SizedBox(height: 20),
                  FeatureCard(
                    icon: Icons.create,
                    label: 'Create Study Room',
                    description: 'Start your own study room and invite friends.',
                    color: Colors.pinkAccent,
                    onTap: _createStudyRoom,
                  ),
                  const SizedBox(height: 20),
                  FeatureCard(
                    icon: Icons.timer,
                    label: 'Pomodoro',
                    description: 'Boost productivity with timed study sessions.',
                    color: Colors.redAccent,
                    onTap: _showPomodoroTimer,
                  ),
                  const SizedBox(height: 20),
                  FeatureCard(
                    icon: Icons.assignment_turned_in,
                    label: 'Tasks',
                    description: 'Organize and track your study tasks.',
                    color: Colors.green,
                    onTap: _showTaskManager, // Updated to trigger TaskManager
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Notes',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesController,
                          decoration: InputDecoration(
                            hintText: 'Add a note...',
                            hintStyle: TextStyle(
                              fontFamily: 'Poppins',
                              color: Colors.grey[700],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add, color: Colors.deepPurple),
                              onPressed: _addNote,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(
                                  _notes[index],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteNote(index),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton.extended(
                    heroTag: 'imageUpload',
                    onPressed: () => _pickAndSaveFile(isImage: true),
                    label: const Text(
                      "Upload Image",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.image),
                    backgroundColor: Colors.pinkAccent,
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'docUpload',
                    onPressed: () => _pickAndSaveFile(isImage: false),
                    label: const Text(
                      "Upload Document",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const Icon(Icons.upload_file),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Uploaded Files',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  _uploadBox.isEmpty
                      ? const Text(
                          "No files uploaded yet!",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: _uploadBox.length,
                          itemBuilder: (context, index) {
                            final String filePath = _uploadBox.getAt(index) as String;
                            final File file = File(filePath);
                            final String fileName = filePath.split('/').last;

                            return GestureDetector(
                              onTap: () => filePath.endsWith('.png') || filePath.endsWith('.jpg')
                                  ? _showFullScreenImage(filePath)
                                  : null,
                              child: Card(
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        filePath.endsWith('.png') || filePath.endsWith('.jpg')
                                            ? Image.file(file, width: 80, height: 80, fit: BoxFit.cover)
                                            : const Icon(Icons.insert_drive_file, size: 80),
                                        const SizedBox(height: 10),
                                        Text(
                                          fileName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteFile(index),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Poppins',
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PomodoroTimerSheet extends StatefulWidget {
  const PomodoroTimerSheet({super.key});

  @override
  State<PomodoroTimerSheet> createState() => _PomodoroTimerSheetState();
}

class _PomodoroTimerSheetState extends State<PomodoroTimerSheet> {
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  bool _isWorkSession = true;

  void _startPauseTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          _switchSession();
        }
      });
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 25 * 60;
      _isRunning = false;
      _isWorkSession = true;
    });
  }

  void _switchSession() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isWorkSession = !_isWorkSession;
      _secondsRemaining = _isWorkSession ? 25 * 60 : 5 * 60;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isWorkSession ? 'Work Session' : 'Break Time',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _secondsRemaining / (_isWorkSession ? 25 * 60 : 5 * 60),
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                ),
              ),
              Text(
                _formatTime(_secondsRemaining),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _startPauseTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? Colors.orange : Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: Text(
                  _isRunning ? 'Pause' : 'Start',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: _resetTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
                child: const Text(
                  'Reset',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}