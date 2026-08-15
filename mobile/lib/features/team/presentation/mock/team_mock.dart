import 'package:flutter/material.dart';
import 'package:frontend_mayoral/core/theme/theme.dart';

/// Rol real de un usuario dentro de un establecimiento.
///
/// Son los 6 roles definidos en CLAUDE.md. El diseño de referencia
/// (`EquipoInvitar` en `screens-other.jsx`) sólo muestra 5 y omite
/// `assetManager` — acá se listan los 6 (ver `.claude/specs/gestion-de-equipo.md`).
enum TeamRole {
  /// Control total, facturación y baja del establecimiento.
  owner,

  /// Configuración, datos y usuarios. No factura.
  administrator,

  /// Operación diaria: animales, pesajes, sanidad, movimientos.
  capataz,

  /// Altas, bajas y movimientos de hacienda. Sin sanidad ni facturación.
  assetManager,

  /// Acceso parcial al módulo Sanidad, puede aplicar tratamientos.
  veterinarian,

  /// Solo lectura del rodeo, pensado para escritorios externos.
  externalBuyer,
}

/// Estado de un miembro del equipo.
enum TeamMemberStatus {
  /// Ya aceptó la invitación y tiene acceso.
  active,

  /// Invitación enviada, todavía sin aceptar.
  invited,
}

/// Una opción de rol mostrada en el selector de `InviteTeamMemberPage`.
class TeamRoleOption {
  /// Crea una opción de rol con su descripción.
  const TeamRoleOption({required this.role, required this.label, required this.description});

  /// Rol representado.
  final TeamRole role;

  /// Nombre visible del rol.
  final String label;

  /// Descripción corta de qué puede hacer este rol.
  final String description;
}

/// Las 6 opciones de rol reales, en orden de gobernanza → operación →
/// especialista → externo. `capataz` es el preseleccionado por defecto.
const teamRoleOptionsMock = [
  TeamRoleOption(
    role: TeamRole.owner,
    label: 'Owner',
    description: 'Control total · facturación · eliminar el establecimiento.',
  ),
  TeamRoleOption(
    role: TeamRole.administrator,
    label: 'Administrator',
    description: 'Configuración + datos + usuarios. No factura.',
  ),
  TeamRoleOption(
    role: TeamRole.capataz,
    label: 'Capataz',
    description: 'Operación diaria: animales, pesajes, sanidad, movimientos.',
  ),
  TeamRoleOption(
    role: TeamRole.assetManager,
    label: 'Encargado de bienes',
    description: 'Altas, bajas y movimientos de hacienda. No maneja sanidad ni facturación.',
  ),
  TeamRoleOption(
    role: TeamRole.veterinarian,
    label: 'Veterinario',
    description: 'Acceso parcial al módulo Sanidad. Puede aplicar tratamientos.',
  ),
  TeamRoleOption(
    role: TeamRole.externalBuyer,
    label: 'Consignatario externo',
    description: 'Solo lectura del rodeo. Pensado para escritorios.',
  ),
];

/// Rol preseleccionado al abrir el formulario de invitación.
const teamInviteDefaultRole = TeamRole.capataz;

/// Nombre visible de un [TeamRole], para la chip de rol de cada miembro.
String teamRoleLabel(TeamRole role) {
  return teamRoleOptionsMock.firstWhere((option) => option.role == role).label;
}

/// Un miembro mock del equipo del establecimiento.
class TeamMemberMock {
  /// Crea un miembro mock.
  const TeamMemberMock({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.initials,
    required this.avatarColor,
    this.scopeNote,
  });

  /// Nombre completo.
  final String name;

  /// Email de contacto.
  final String email;

  /// Rol asignado.
  final TeamRole role;

  /// Estado de la invitación/membresía.
  final TeamMemberStatus status;

  /// Iniciales mostradas en el avatar.
  final String initials;

  /// Color de fondo del avatar.
  final Color avatarColor;

  /// Nota de alcance opcional (ej. "sólo lectura de un módulo").
  final String? scopeNote;
}

/// Los 4 usuarios mock del establecimiento (ver `gestion-de-equipo.md`).
const teamMembersMock = [
  TeamMemberMock(
    name: 'Mariano Suárez',
    email: 'mariano@lasirena.com.ar',
    role: TeamRole.capataz,
    status: TeamMemberStatus.active,
    initials: 'MS',
    avatarColor: AppColors.primary,
  ),
  TeamMemberMock(
    name: 'Cecilia Lazarte',
    email: 'ceci@lasirena.com.ar',
    role: TeamRole.owner,
    status: TeamMemberStatus.active,
    initials: 'CL',
    avatarColor: AppColors.textEmphasis,
  ),
  TeamMemberMock(
    name: 'Diego Romero',
    email: 'dr.vet@gmail.com',
    role: TeamRole.veterinarian,
    status: TeamMemberStatus.active,
    initials: 'DR',
    avatarColor: AppColors.textSecondary,
    scopeNote: 'Acceso solo lectura · módulo Sanidad',
  ),
  TeamMemberMock(
    name: 'Augusto Páez',
    email: 'augusto.consign@gmail.com',
    role: TeamRole.externalBuyer,
    status: TeamMemberStatus.invited,
    initials: 'AP',
    avatarColor: AppColors.textHint,
    scopeNote: 'Acceso solo lectura · módulo Animales',
  ),
];

/// Email mock precargado en el formulario de invitación.
const teamInviteEmailMock = 'hernan.peon@lasirena.com.ar';
