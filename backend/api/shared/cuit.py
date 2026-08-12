"""Validación y normalización de CUIT/CUIL, compartida entre módulos.

Usada por ``usuarios`` (dueño de campo) y ``establecimientos`` (titular del
RENSPA, que puede no ser el usuario autenticado).
"""

import re

from api.shared.exceptions import ValidationError


class CuitInvalidoError(ValidationError):
    code = "cuit_invalido"

    def __init__(self, cuit: str) -> None:
        super().__init__(f"El CUIT/CUIL '{cuit}' no es válido")


def normalizar_cuit(value: str) -> str:
    """Quita guiones/espacios y valida que queden 11 dígitos.

    No valida el dígito verificador (ver ``validar_cuit``); lanza
    ``ValueError`` si el resultado no tiene exactamente 11 dígitos.
    """
    digits = re.sub(r"[\s-]", "", value)
    if not digits.isdigit() or len(digits) != 11:
        raise ValueError("El CUIT/CUIL debe tener 11 dígitos")
    return digits


def validar_cuit(cuit: str) -> bool:
    """Valida un CUIT/CUIL argentino (11 dígitos + dígito verificador mod-11).

    Acepta solo dígitos (sin guiones); el formato debe normalizarse antes.
    """
    if not cuit or not cuit.isdigit() or len(cuit) != 11:
        return False

    multiplicadores = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2]
    suma = sum(int(d) * m for d, m in zip(cuit[:10], multiplicadores))
    resto = suma % 11
    verificador = 11 - resto
    if verificador == 11:
        verificador = 0
    elif verificador == 10:
        # CUIT con verificador 10 no es válido bajo el esquema estándar.
        return False

    return verificador == int(cuit[10])
