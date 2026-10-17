"""Códigos de invitación: generación, normalización y hash (adr-0012).

8 caracteres de un alfabeto de 31 símbolos sin los que se confunden al dictarlos
o leerlos (0/O, 1/I/L): ~8,5 × 10¹¹ combinaciones. Con el límite de intentos por
usuario no se puede adivinar uno. Se muestra como ``XXXX-XXXX`` y se acepta con
o sin guion, espacios o minúsculas.

Se guarda un HMAC-SHA256 con una clave del servidor y no el código: si se filtra
la tabla, sin la clave no se pueden probar códigos offline. No hace falta un
hash lento (bcrypt) porque el código es aleatorio y no lo elige una persona.
"""

import hashlib
import hmac
import secrets

ALFABETO = "23456789ABCDEFGHJKMNPQRSTUVWXYZ"
LONGITUD = 8


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
