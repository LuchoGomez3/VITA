import 'package:frontend_mayoral/features/animal_register/presentation/cubit/registrar_animal_cubit.dart';
import 'package:frontend_mayoral/features/animal_register/presentation/widgets/registrar_animal_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegistrarAnimalPage extends StatelessWidget {
  const RegistrarAnimalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrarAnimalCubit(),
      child: BlocListener<RegistrarAnimalCubit, RegistrarAnimalState>(
        listener: (context, state) {
          if (state.status == RegistrarAnimalStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Animal registrado correctamente.')),
            );
            context.read<RegistrarAnimalCubit>().resetFeedback();
          }

          if (state.status == RegistrarAnimalStatus.failure &&
              state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!.message)),
            );
            context.read<RegistrarAnimalCubit>().resetFeedback();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Registrar animal'),
          ),
          body: BlocBuilder<RegistrarAnimalCubit, RegistrarAnimalState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: RegistrarAnimalForm(
                  isSubmitting: state.status == RegistrarAnimalStatus.loading,
                  onSubmit: context.read<RegistrarAnimalCubit>().submit,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
