"""Utilidades de dominio para usuarios.

``validar_cuit`` vive en ``api.shared.cuit`` (compartida con
``establecimientos``); se re-exporta acá para no romper el import existente.
"""

from api.shared.cuit import validar_cuit as validar_cuit
