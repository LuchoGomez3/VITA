"""Root conftest para pytest — configura PYTHONPATH del monorepo."""

import sys
from pathlib import Path

# Agregar la raíz del monorepo a PYTHONPATH para que se encuentren los módulos
root = Path(__file__).parent
sys.path.insert(0, str(root))
