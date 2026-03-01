import 'package:flutter/material.dart';
import 'package:vivi_room/shared/widgets/app_bottom_nav_bar.dart';
import 'package:vivi_room/shared/widgets/cliente_avatar.dart';
import 'package:vivi_room/shared/widgets/primary_button.dart';

import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/fab_button.dart';
import '../../../shared/widgets/search_bar_widget.dart';
import '../../../shared/widgets/secondary_button.dart';
import '../../../shared/widgets/status_badge.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  int index = 0;
  void onTap(int newIndex) {
    setState(() {
      index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavBar(currentIndex: index, onTap: onTap),
      floatingActionButton: const FabButton(),
      body: Column(
        children: [
          SearchBarWidget(),
          PrimaryButton(text: 'Crear Cita'),
          SecondaryButton(text: 'Crear Cita'),
          AppTextField(label: 'Nombre'),
          AppTextField(label: 'Teléfono'),
          AppTextField(label: 'Email'),
          StatusBadge(status: 'CONFIRMADA'),
          ClienteAvatar(nombre: "Jose")
        ],
      ),
    );
  }
}
