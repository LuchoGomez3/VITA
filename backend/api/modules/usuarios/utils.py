"""Utilidades de dominio para usuarios."""


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
