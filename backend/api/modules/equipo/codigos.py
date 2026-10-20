"""Códigos de invitación: generación, normalización y hash (adr-0012).

6 caracteres de un alfabeto de 31 símbolos sin los que se confunden al dictarlos
o leerlos (0/O, 1/I/L): ~8,9 × 10⁸ combinaciones. Alcanza porque el canje además
exige la sesión del email invitado: adivinar un código no le sirve a otra cuenta,
y el límite de intentos por usuario frena la fuerza bruta. Se muestra como
``XXX-XXX`` (como en el diseño) y se acepta con o sin guion, espacios o minúsculas.

Se guarda un HMAC-SHA256 con una clave del servidor y no el código: si se filtra
la tabla, sin la clave no se pueden probar códigos offline. No hace falta un
hash lento (bcrypt) porque el código es aleatorio y no lo elige una persona.
"""

import hashlib
import hmac
import secrets

ALFABETO = "23456789ABCDEFGHJKMNPQRSTUVWXYZ"
LONGITUD = 6


def generar_codigo() -> str:
    return "".join(secrets.choice(ALFABETO) for _ in range(LONGITUD))


def normalizar_codigo(codigo: str) -> str:
    return "".join(c for c in codigo.upper() if c.isalnum())


def formatear_codigo(codigo: str) -> str:
    mitad = LONGITUD // 2
    return f"{codigo[:mitad]}-{codigo[mitad:]}"


def hashear_codigo(codigo: str, secreto: str) -> str:
    return hmac.new(
        secreto.encode("utf-8"),
        normalizar_codigo(codigo).encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def tiene_formato_valido(codigo: str) -> bool:
    normalizado = normalizar_codigo(codigo)
    return len(normalizado) == LONGITUD and all(c in ALFABETO for c in normalizado)
