import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  initializeDateFormatting('es', null); // Inicializa la localización en español
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    SchedulePage(),
    HomePage(),
    ProfilePage(), // Agregamos la página de perfil aquí
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Horario',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
           icon: Icon(Icons.person), // Ícono de perfil
            label: 'Perfil', // Etiqueta para la página de perfil
          ),
        ],
        selectedItemColor: Color.fromARGB(255, 1, 12, 72),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
        },
        child: Text('Ir a Inicio'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implementa la interfaz de la página de perfil aquí
    return Center(
      child: Text('Página de Perfil'), // Puedes personalizar esta página según tus necesidades
    );
  }
}


class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final DateFormat _dateFormat = DateFormat('EEEE', 'es'); // Usa la localización en español
  List<DateTime> _daysList = [];
  late int _currentDayIndex;

  // Lista de clases
  List<Clase> _clases = [];

  @override
  void initState() {
    super.initState();
    _updateDaysList();
  }

  void _updateDaysList() {
    final DateTime currentDate = DateTime.now();
    final List<DateTime> nextDays = [];
    int todayIndex = 0;

    for (int i = 0; i < 7; i++) {
      final day = currentDate.add(Duration(days: i));
      nextDays.add(day);

      if (day.day == currentDate.day) {
        todayIndex = i;
      }
    }
    setState(() {
      _daysList = nextDays;
      _currentDayIndex = todayIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 16),
              child: Text(
                'Hola Diego',
                style: TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 1, 12, 72),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddScheduleScreen(
                    onClaseAdded: (clase) {
                      setState(() {
                        _clases.add(clase);
                      });
                    },
                  ),
                ));
              },
            ),
          ],
        ),
        SizedBox(height: 30),
        Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _daysList.length,
            itemBuilder: (context, index) {
              final day = _daysList[index];
              final isToday = index == _currentDayIndex;
              final textColor =
                  isToday ? Color.fromARGB(255, 1, 12, 72) : Colors.grey;

              return Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _capitalize(_dateFormat.format(day)), // Aplica capitalización
                  style: TextStyle(
                    fontSize: isToday ? 30 : 30,
                    color: textColor,
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _clases.length,
            itemBuilder: (context, index) {
              final clase = _clases[index];
              return Container(
                decoration: BoxDecoration(
                  color: clase.color,
                ),
                padding: EdgeInsets.all(8),
                margin: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      clase.horaInicio,
                      style: TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 1, 12, 72),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_capitalize(clase.materia)), // Aplica capitalización
                        Text('${clase.horaInicio} - ${clase.horaFin}'),
                      ],
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.info),
                      onPressed: () {
                        // Mostrar información adicional de la clase si es necesario.
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Función para capitalizar la primera letra
  String _capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
  }
}


class AddScheduleScreen extends StatefulWidget {
  final Function(Clase) onClaseAdded;

  AddScheduleScreen({required this.onClaseAdded});

  @override
  _AddScheduleScreenState createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dias = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes'];
  String _selectedDia = 'Lunes';
  String _horaInicio = '';
  String _horaFin = '';
  String _salon = '';
  Color _selectedColor = Color(0xff2196f3); // Valor único para color
  String _infoExtra = '';
  String _materia = '';

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 31,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
        ),
        child: Padding(
      
          padding: const EdgeInsets.all(16.0),
          
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true, // Hace que el ListView tenga el tamaño mínimo necesario
              physics: NeverScrollableScrollPhysics(), // Evita el desplazamiento del ListView
              children: [
                // Campo para el nombre de la materia
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        _materia = value;
                      });
                    },
                    
  decoration: InputDecoration(
    hintText: 'Nombre de la materia', // Utiliza hintText en lugar de labelText
    hintStyle: TextStyle(
      fontSize: 23,
      color: Color.fromARGB(255, 187, 187, 190),
        
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 187 , 187, 190),
      ),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Color.fromARGB(255, 1, 12, 72),
      ),
    ),
    
  ),
  
)

  
),
SizedBox(height: 30),

  Container(
  padding: EdgeInsets.all(8),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(5),
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Día:',
        style: TextStyle(
          fontSize: 23,
        ),
      ),
      SizedBox(width: 160),
      Container(
        width: 120, // Ajusta el ancho del cuadro sin mover el texto "Día:"
        padding: EdgeInsets.symmetric(horizontal: 8 ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            bottomLeft: Radius.circular(10),
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedDia,
          onChanged: (value) {
            setState(() {
              _selectedDia = value!;
            });
          },
          items: _dias.map((dia) {
            return DropdownMenuItem<String>(
              value: dia,
              child: Text(
                dia,
                style: TextStyle(
                  color: Color.fromARGB(255, 1, 12, 72),
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 1, 12, 72),
            ),
            border: InputBorder.none,
          ),
           icon: SizedBox.shrink(),
        ),
      ),
    ],
  ),
),
SizedBox(height: 16),
Divider(
  color: Colors.grey,
  height: 1.0,
  thickness: 1.0,
),

SizedBox(height: 30),


              // Campos de hora de inicio y fin
Container(
  padding: EdgeInsets.all(8),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.end, // Alineación hacia la derecha
    children: [
      Text('Hora: ', style: TextStyle(fontSize: 23)),
      SizedBox(width: 95 ),
      Container(
        width: 70,
        height: 25, // Altura controlada
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Padding vertical eliminado
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              _horaInicio = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Inicio',
            labelStyle: TextStyle(
               fontSize: 10, // Establecemos el tamaño de fuente en 21
              color: Color.fromARGB(255, 1, 12, 72),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8 ), // Padding interno ajustado
          ),
        ),
      ),
      SizedBox(width: 8),
      Text('>', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      SizedBox(width: 8),
      Container(
        width: 70,
        height: 25, // Altura controlada
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0), // Padding vertical eliminado
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        ),
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              _horaFin = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Fin',
            labelStyle: TextStyle(
               fontSize: 10, // Establecemos el tamaño de fuente en 21
              color: Color.fromARGB(255, 1, 12, 72),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8), // Padding interno ajustado
          ),
        ),
      ),
    ],
  ),
),
SizedBox(height: 60),






            // Campo de salón
Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Padding ajustado
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Stack(
    children: [
      TextFormField(
        onChanged: (value) {
          setState(() {
            _salon = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Salón',
          hintStyle: TextStyle(
            fontSize: 18 , // Aquí ajustamos el tamaño de la fuente a 21
            color: Color.fromARGB(255, 1, 12, 72),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero, 
        ),
      ),
      Positioned(
        right: 0, 
        top: 0,
        bottom: 0,
        child: Center(
          child: Text('›', style: TextStyle(fontSize: 38 )),
        ),
      ),
    ],
  ),
),
SizedBox(height: 16),



Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row( // Envuelve los elementos en un Row
    children: [
      Expanded( // Asegura que el cuadro de texto ocupe todo el espacio disponible
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              _salon = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Color',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 1, 12, 72),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
      SizedBox(width: 10), // Agrega un espacio entre el cuadro de texto y la paleta de colores
      GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Selecciona un color'),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: _selectedColor,
                    onColorChanged: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                    showLabel: true,
                    pickerAreaHeightPercent: 0.8,
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Aceptar'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                  ),
                ],
              );
            },
          );
        },
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _selectedColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    ],
  ),
),
SizedBox(height: 40),




Container(
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Información Extra: ',
        style: TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 1, 12, 72),
        ),
      ),
      SizedBox(height: 8),
      Container(
        height: 100, // puedes ajustar este valor según tus necesidades
        child: TextFormField(
          onChanged: (value) {
            setState(() {
              _infoExtra = value;
            });
          },
          maxLines: null,
          decoration: InputDecoration(
            labelStyle: TextStyle(
              color: Color.fromARGB(255, 1, 12, 72),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  ),
),
SizedBox(height: 80),








              // Botón para guardar la clase
               ElevatedButton(
                onPressed: () {
                  // Validar y guardar la clase
                  if (_formKey.currentState!.validate()) {
                    final clase = Clase(
                      materia: _materia,
                      dia: _selectedDia,
                      horaInicio: _horaInicio,
                      horaFin: _horaFin,
                      salon: _salon,
                      color: _selectedColor,
                      infoExtra: _infoExtra,
                    );

                    widget.onClaseAdded(clase);

                    Navigator.of(context).pop();
                  }
                },
                child: Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 21,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 0, 0, 100), // Azul más oscuro // Azul oscuro
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50), // Borde redondeado
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20), // Ajusta el padding para hacerlo más alargado
                  elevation: 0, // Elimina la elevación (sombra) del botón
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
    );

  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página de Inicio'),
      ),
      body: Center(
        child: Text('Contenido de la página de Inicio'),
      ),
    );
  }
}

class Clase {
  final String materia;
  final String dia;
  final String horaInicio;
  final String horaFin;
  final String salon;
  final Color color;
  final String infoExtra;

  Clase({
    required this.materia,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.salon,
    required this.color,
    required this.infoExtra,
  });
}


