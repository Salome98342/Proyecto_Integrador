import 'package:flutter/material.dart';

/// Ejemplo de Flutter para personalizar AppBar y tema.

final List<int> _items = List<int>.generate(51, (int index) => index);

// Lista de íconos para mostrar en el Grid.
const List<IconData> _gridIcons = <IconData>[
  Icons.star,
  Icons.favorite,
  Icons.coffee,
  Icons.flight_takeoff,
  Icons.bolt,
  Icons.camera_alt,
  Icons.pets,
  Icons.music_note,
  Icons.sports_soccer,
  Icons.beach_access,
  Icons.lightbulb,
  Icons.bookmark,
];

void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Cambia el color base del tema (colorSchemeSeed) y define colores de fondo.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF006E7F), // Teal oscuro
        scaffoldBackgroundColor: const Color(0xFFF3F4F6), // Fondo claro para contraste
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF004D61), // Fondo del AppBar
          foregroundColor: Colors.white, // Color del texto/íconos del AppBar
        ),
      ),
      home: const AppBarExample(),
    );
  }
}

class AppBarExample extends StatefulWidget {
  const AppBarExample({super.key});

  @override
  State<AppBarExample> createState() => _AppBarExampleState();
}

class _AppBarExampleState extends State<AppBarExample> {
  bool shadowColor = false;
  double? scrolledUnderElevation;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
  // Mayor contraste para los ítems del GridView.
  final Color oddItemColor = colorScheme.primary.withValues(alpha: 0.20);
  final Color evenItemColor = colorScheme.primary.withValues(alpha: 0.35);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.grid_view_rounded),
            SizedBox(width: 8),
            Text('Galería de Íconos'),
          ],
        ),
        scrolledUnderElevation: scrolledUnderElevation,
        shadowColor: shadowColor ? Theme.of(context).colorScheme.shadow : null,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006E7F), Color(0xFF00A7A7)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: GridView.builder(
        itemCount: _items.length,
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.0,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemBuilder: (BuildContext context, int index) {
          final icon = _gridIcons[(index - 1) % _gridIcons.length];
          return _IconTile(
            icon: icon,
            background: _items[index].isOdd ? oddItemColor : evenItemColor,
            semanticLabel: 'Elemento $index',
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: OverflowBar(
            overflowAlignment: OverflowBarAlignment.center,
            alignment: MainAxisAlignment.center,
            overflowSpacing: 5.0,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    shadowColor = !shadowColor;
                  });
                },
                icon: Icon(shadowColor ? Icons.visibility_off : Icons.visibility),
                label: const Text('color de sombra'),
              ),
              const SizedBox(width: 5),
              ElevatedButton(
                onPressed: () {
                  if (scrolledUnderElevation == null) {
                    setState(() {
                      // La elevación por defecto es 3.0, incrementamos en 1.0.
                      scrolledUnderElevation = 4.0;
                    });
                  } else {
                    setState(() {
                      scrolledUnderElevation = scrolledUnderElevation! + 1.0;
                    });
                  }
                },
                child: Text('elevación al desplazar: ${scrolledUnderElevation ?? 'predeterminado'}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconTile extends StatefulWidget {
  const _IconTile({
    required this.icon,
    required this.background,
    this.semanticLabel,
  });

  final IconData icon;
  final Color background;
  final String? semanticLabel;

  @override
  State<_IconTile> createState() => _IconTileState();
}

class _IconTileState extends State<_IconTile> {
  bool _hovering = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = _hovering ? scheme.primary : scheme.onPrimaryContainer;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {},
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: widget.background,
              ),
              child: Icon(
                widget.icon,
                size: 28,
                color: iconColor,
                semanticLabel: widget.semanticLabel,
              ),
            ),
          ),
        ),
      ),
    );
  }
}