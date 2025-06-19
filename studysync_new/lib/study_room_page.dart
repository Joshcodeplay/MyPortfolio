import 'dart:io';
import 'package:flutter/material.dart';

class StudyRoomPage extends StatefulWidget {
  final String roomId;
  final bool isCreator;
  final String nickname;
  final List<String> uploadedFiles;

  const StudyRoomPage({
    super.key,
    required this.roomId,
    required this.isCreator,
    required this.nickname,
    required this.uploadedFiles,
  });

  @override
  State<StudyRoomPage> createState() => _StudyRoomPageState();
}

class _StudyRoomPageState extends State<StudyRoomPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {'user': 'User1', 'text': 'Hey, let’s review Chapter 3!', 'type': 'text', 'time': DateTime.now().subtract(const Duration(minutes: 5))},
    {'user': 'User2', 'text': 'Sure, I’ll share my notes.', 'type': 'text', 'time': DateTime.now().subtract(const Duration(minutes: 2))},
  ];
  final List<String> _goals = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  
  // Pomodoro Timer
  int _pomodoroSeconds = 25 * 60; // 25 minutes
  bool _isPomodoroRunning = false;
  late AnimationController _pomodoroController;

  @override
  void initState() {
    super.initState();
    _pomodoroController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _pomodoroSeconds),
    )..addListener(() {
        setState(() {
          _pomodoroSeconds = (_pomodoroController.duration! * (1 - _pomodoroController.value)).inSeconds;
          if (_pomodoroSeconds <= 0) {
            _isPomodoroRunning = false;
            _pomodoroController.reset();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pomodoro finished! Take a break.')));
          }
        });
      });
  }

  @override
  void dispose() {
    _pomodoroController.dispose();
    _messageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _sendMessage(String type, {String? content}) {
    if (type == 'text' && _messageController.text.isNotEmpty) {
      final newMessage = {
        'user': widget.nickname,
        'text': _messageController.text,
        'type': 'text',
        'time': DateTime.now(),
      };
      setState(() {
        _messages.add(newMessage);
        _listKey.currentState?.insertItem(_messages.length - 1);
        _messageController.clear();
      });
    } else if (type == 'file' && content != null) {
      final newMessage = {
        'user': widget.nickname,
        'text': content,
        'type': 'file',
        'time': DateTime.now(),
      };
      setState(() {
        _messages.add(newMessage);
        _listKey.currentState?.insertItem(_messages.length - 1);
      });
    }
  }

  void _addGoal() {
    if (_goalController.text.isNotEmpty) {
      setState(() {
        _goals.add('${widget.nickname}: ${_goalController.text}');
        _goalController.clear();
      });
    }
  }

  void _showFilePicker() {
    if (widget.uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No files uploaded yet!')));
      return;
    }
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: widget.uploadedFiles.length,
          itemBuilder: (context, index) {
            final filePath = widget.uploadedFiles[index];
            final fileName = filePath.split('/').last;
            return ListTile(
              leading: filePath.endsWith('.png') || filePath.endsWith('.jpg')
                  ? Image.file(File(filePath), width: 40, height: 40, fit: BoxFit.cover)
                  : const Icon(Icons.insert_drive_file),
              title: Text(fileName, style: const TextStyle(fontFamily: 'Poppins')),
              onTap: () {
                _sendMessage('file', content: filePath);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  void _togglePomodoro() {
    setState(() {
      if (_isPomodoroRunning) {
        _pomodoroController.stop();
        _isPomodoroRunning = false;
      } else {
        _pomodoroController.forward(from: 1 - (_pomodoroSeconds / (25 * 60)));
        _isPomodoroRunning = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Study Room: ${widget.roomId}',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: 'Poppins',
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pomodoro: ${_pomodoroSeconds ~/ 60}:${(_pomodoroSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.deepPurple),
                ),
                ElevatedButton(
                  onPressed: _togglePomodoro,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                  child: Text(
                    _isPomodoroRunning ? 'Pause' : 'Start',
                    style: const TextStyle(fontFamily: 'Poppins', color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text(
              'Study Goals',
              style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, color: Colors.deepPurple),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _goalController,
                      decoration: InputDecoration(
                        hintText: 'Add your study goal...',
                        hintStyle: TextStyle(color: Colors.grey[700]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.5),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add, color: Colors.deepPurple),
                          onPressed: _addGoal,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Poppins'),
                    ),
                    const SizedBox(height: 10),
                    ..._goals.map((goal) => ListTile(
                          title: Text(goal, style: const TextStyle(fontFamily: 'Poppins')),
                        )),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _messages.length,
              padding: const EdgeInsets.all(16.0),
              itemBuilder: (context, index, animation) {
                final message = _messages[index];
                final isMe = message['user'] == widget.nickname;
                return SlideTransition(
                  position: animation.drive(Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOut))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isMe) ...[
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              message['user'][0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.deepPurple : Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                if (!isMe)
                                  Text(
                                    message['user'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                      color: Colors.black87,
                                      fontSize: 12,
                                    ),
                                  ),
                                message['type'] == 'text'
                                    ? Text(
                                        message['text'],
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: isMe ? Colors.white : Colors.black87,
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: () => message['text'].endsWith('.png') || message['text'].endsWith('.jpg')
                                            ? _showFullScreenImage(message['text'])
                                            : null,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.insert_drive_file,
                                              color: isMe ? Colors.white : Colors.black87,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              message['text'].split('/').last,
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                color: isMe ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                const SizedBox(height: 5),
                                Text(
                                  '${message['time'].hour}:${message['time'].minute.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isMe ? Colors.white70 : Colors.grey[600],
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isMe) ...[
                          const SizedBox(width: 10),
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              widget.nickname[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.deepPurple),
                  onPressed: _showFilePicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.5),
                    ),
                    style: const TextStyle(fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.deepPurple),
                  onPressed: () => _sendMessage('text'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}