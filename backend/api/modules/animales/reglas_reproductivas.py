"""Reglas de compatibilidad entre sexo, categoría y condición reproductiva.

Son funciones puras para que el alta, la edición y el reenvío de sincronización
apliquen exactamente la misma regla. La base las replica en un trigger
(migración ``20261001_02``) porque Supabase admite escrituras directas.

Regla vigente:

- ``null`` siempre es válido: significa que la condición no corresponde.
- Un macho no admite ninguna condición reproductiva.
- ``sin_determinar`` vale para cualquier hembra, tenga o no categoría.
- ``vacia`` y ``prenada`` exigen una hembra con una categoría que tenga
  ``permite_estado_reproductivo``.
- La categoría, si hay, tiene que admitir el sexo del animal.
"""

from api.modules.animales.exceptions import (
    CategoriaIncompatibleConSexoError,
    EstadoReproductivoInvalidoError,
)
from api.modules.categorias.models import Categoria
from api.shared.enums import EstadoReproductivo, SexoAnimal, SexoPermitido


def categoria_admite_sexo(sexo_permitido: SexoPermitido, sexo: SexoAnimal) -> bool:
    """¿Puede un animal de ``sexo`` pertenecer a una categoría así?"""
    return sexo_permitido == SexoPermitido.ambos or sexo_permitido.value == sexo.value


def validar_combinacion(
    sexo: SexoAnimal,
    categoria: Categoria | None,
    estado_reproductivo: EstadoReproductivo | None,
) -> None:
    """Valida el estado final de un animal; lanza si la combinación es inválida.

    Recibe el resultado completo —no el cambio— para que cambiar categoría y
    condición en la misma solicitud se evalúe en conjunto.
    """
    if categoria is not None and not categoria_admite_sexo(
        SexoPermitido(categoria.sexo_permitido), sexo
    ):
        raise CategoriaIncompatibleConSexoError()

    if estado_reproductivo is None:
        return
    if sexo != SexoAnimal.hembra:
        raise EstadoReproductivoInvalidoError(
            "Un macho no puede tener condición reproductiva"
        )
    if estado_reproductivo == EstadoReproductivo.sin_determinar:
        return
    if categoria is None:
        raise EstadoReproductivoInvalidoError(
            "Asigne al animal una categoría que admita condición reproductiva "
            "antes de registrarla"
        )
    if not categoria.permite_estado_reproductivo:
        raise EstadoReproductivoInvalidoError(
            "La categoría del animal no admite registrar condición reproductiva"
        )
