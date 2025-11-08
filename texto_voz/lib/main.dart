import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario Accesible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AccessibleFormScreen(),
    );
  }
}

class AccessibleFormScreen extends StatefulWidget {
  @override
  _AccessibleFormScreenState createState() => _AccessibleFormScreenState();
}

class _AccessibleFormScreenState extends State<AccessibleFormScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final stt.SpeechToText speechToText = stt.SpeechToText();
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  TextEditingController _mensajeController = TextEditingController();

  String _selectedOption = 'Opción 1';
  bool _aceptoTerminos = false;

  // Variables para control de voz
  bool _isListening = false;
  bool _ttsEnabled = true;
  double _ttsVolume = 1.0;
  String? _currentListeningField;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initSpeech();
  }

  _initTts() async {
    await flutterTts.setLanguage("es-ES");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(_ttsVolume);
  }

  _initSpeech() async {
    bool available = await speechToText.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done') {
          setState(() {
            _isListening = false;
            _currentListeningField = null;
          });
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() {
          _isListening = false;
          _currentListeningField = null;
        });
      },
    );

    if (!available) {
      _speak("El reconocimiento de voz no está disponible");
    }
  }

  _speak(String text) async {
    if (text.isNotEmpty && _ttsEnabled) {
      await flutterTts.speak(text);
    }
  }

  _stopTts() async {
    await flutterTts.stop();
  }

  _toggleTTS() {
    setState(() {
      _ttsEnabled = !_ttsEnabled;
    });
    _speak(_ttsEnabled ? "Voz activada" : "Voz desactivada");
  }

  _changeVolume(double volume) {
    setState(() {
      _ttsVolume = volume;
    });
    flutterTts.setVolume(volume);
  }

  _readFieldDescription(String fieldName, String description) {
    _speak("Campo $fieldName. $description");
  }

  // Llenado individual de un campo específico - SIN INSTRUCCIONES
  _startFieldVoiceInput(
    String fieldName,
    TextEditingController controller,
  ) async {
    // Si ya está escuchando este campo, detener
    if (_isListening && _currentListeningField == fieldName) {
      await _stopListening();
      return;
    }

    // Detener cualquier TTS en curso
    await _stopTts();

    // Detener cualquier grabación previa
    if (_isListening) {
      await speechToText.stop();
    }

    setState(() {
      _isListening = true;
      _currentListeningField = fieldName;
    });

    // INICIAR GRABACIÓN DIRECTAMENTE SIN INSTRUCCIONES
    await _listenForField(fieldName, controller);
  }

  _listenForField(String fieldName, TextEditingController controller) async {
    await speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          final recognizedText = result.recognizedWords;
          if (recognizedText.isNotEmpty) {
            _fillField(fieldName, controller, recognizedText);
          }
        }
      },
      listenFor: Duration(seconds: 10),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
      localeId: "es_ES",
    );
  }

  _fillField(String fieldName, TextEditingController controller, String text) {
    setState(() {
      controller.text = text;
      _isListening = false;
      _currentListeningField = null;
    });

    // Confirmación breve y opcional
    if (_ttsEnabled) {
      _speak("Campo $fieldName llenado");
    }
  }

  _stopListening() async {
    await _stopTts();
    await speechToText.stop();
    setState(() {
      _isListening = false;
      _currentListeningField = null;
    });
  }

  _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (!_aceptoTerminos) {
        _speak("Debe aceptar los términos y condiciones");
        return;
      }

      _speak("Formulario enviado correctamente. Gracias por registrarse");
      // Aquí procesarías el formulario
    } else {
      _speak("Por favor, corrija los errores en el formulario");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FORMULARIO ACCESIBLE'),
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: _toggleTTS,
            tooltip: _ttsEnabled ? 'Silenciar voz' : 'Activar voz',
          ),
          if (_isListening)
            IconButton(
              icon: Icon(Icons.stop, color: Colors.red),
              onPressed: _stopListening,
              tooltip: 'Detener reconocimiento de voz',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Controles de volumen
              _buildVolumeControls(),

              SizedBox(height: 20),

              // Título
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Complete el formulario:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.record_voice_over),
                    onPressed:
                        () => _speak(
                          "Formulario de registro. Use los botones de micrófono para llenar campos por voz",
                        ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Campo Nombre
              _buildTextFieldWithSpeech(
                controller: _nombreController,
                label: 'Nombre completo *',
                hint: 'Ingrese su nombre completo',
                fieldName: 'Nombre completo',
                description: 'Requerido. Escriba su nombre y apellido',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              // Campo Email
              _buildTextFieldWithSpeech(
                controller: _emailController,
                label: 'Correo electrónico *',
                hint: 'ejemplo@correo.com',
                fieldName: 'Correo electrónico',
                description: 'Requerido. Ingrese un email válido',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su email';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),

              SizedBox(height: 15),

              // Campo Teléfono
              _buildTextFieldWithSpeech(
                controller: _telefonoController,
                label: 'Teléfono',
                hint: '+57 300 123 4567',
                fieldName: 'Teléfono',
                description: 'Opcional. Ingrese su número de contacto',
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 15),

              // Dropdown
              _buildDropdownWithSpeech(),

              SizedBox(height: 15),

              // Campo Mensaje
              _buildTextFieldWithSpeech(
                controller: _mensajeController,
                label: 'Mensaje o comentarios',
                hint: 'Escriba su mensaje aquí...',
                fieldName: 'Mensaje',
                description: 'Opcional. Escriba cualquier comentario adicional',
                maxLines: 4,
              ),

              SizedBox(height: 20),

              // Checkbox términos
              _buildCheckboxWithSpeech(),

              SizedBox(height: 30),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitForm,
                      icon: Icon(Icons.send),
                      label: Text('ENVIAR FORMULARIO'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Botón para leer todo el formulario
              Center(
                child: OutlinedButton.icon(
                  onPressed: () => _readFormSummary(),
                  icon: Icon(Icons.audio_file),
                  label: Text('LEER RESUMEN DEL FORMULARIO'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControls() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Control de Voz',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Slider(
                    value: _ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: _changeVolume,
                  ),
                ),
                Text('${(_ttsVolume * 100).toInt()}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithSpeech({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String fieldName,
    required String description,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    bool isThisFieldListening =
        _isListening && _currentListeningField == fieldName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            // Botón de ayuda (solo para leer descripción)
            IconButton(
              icon: Icon(Icons.help_outline, size: 18),
              onPressed: () => _readFieldDescription(fieldName, description),
              tooltip: 'Leer descripción',
            ),
            // Botón de micrófono - INICIA GRABACIÓN DIRECTAMENTE
            IconButton(
              icon: Icon(
                isThisFieldListening ? Icons.stop : Icons.mic,
                size: 18,
                color: isThisFieldListening ? Colors.red : Colors.blue,
              ),
              onPressed: () => _startFieldVoiceInput(fieldName, controller),
              tooltip:
                  isThisFieldListening ? 'Detener grabación' : 'Llenar por voz',
            ),
          ],
        ),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
            enabledBorder:
                isThisFieldListening
                    ? OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                    )
                    : null,
          ),
        ),
        if (isThisFieldListening) ...[
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.record_voice_over, size: 14, color: Colors.red),
              SizedBox(width: 5),
              Text(
                'Escuchando... Hable ahora',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownWithSpeech() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tipo de consulta *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.help_outline, size: 18),
              onPressed:
                  () => _speak(
                    "Tipo de consulta. Seleccione una opción del menú desplegable",
                  ),
              tooltip: 'Leer descripción',
            ),
          ],
        ),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _selectedOption,
          items:
              ['Opción 1', 'Opción 2', 'Opción 3', 'Opción 4'].map((
                String value,
              ) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedOption = newValue!;
            });
            _speak("Seleccionado: $newValue");
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxWithSpeech() {
    return Row(
      children: [
        Checkbox(
          value: _aceptoTerminos,
          onChanged: (bool? value) {
            setState(() {
              _aceptoTerminos = value!;
            });
            _speak(value! ? "Términos aceptados" : "Términos no aceptados");
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _aceptoTerminos = !_aceptoTerminos;
              });
              _speak(
                _aceptoTerminos
                    ? "Términos aceptados"
                    : "Términos no aceptados",
              );
            },
            child: Text(
              'Acepto los términos y condiciones *',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.help_outline, size: 18),
          onPressed:
              () => _speak(
                "Debe aceptar los términos y condiciones para continuar",
              ),
          tooltip: 'Leer descripción',
        ),
      ],
    );
  }

  void _readFormSummary() {
    String summary = """
      Resumen del formulario.
      Nombre: ${_nombreController.text.isEmpty ? 'No ingresado' : _nombreController.text}.
      Email: ${_emailController.text.isEmpty ? 'No ingresado' : _emailController.text}.
      Teléfono: ${_telefonoController.text.isEmpty ? 'No ingresado' : _telefonoController.text}.
      Tipo de consulta: $_selectedOption.
      Mensaje: ${_mensajeController.text.isEmpty ? 'No ingresado' : _mensajeController.text}.
      Términos: ${_aceptoTerminos ? 'Aceptados' : 'No aceptados'}.
    """;
    _speak(summary);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _mensajeController.dispose();
    flutterTts.stop();
    speechToText.stop();
    super.dispose();
  }
}