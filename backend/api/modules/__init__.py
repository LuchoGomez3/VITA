"""Agregador de modelos de dominio.

Importar este paquete (``import api.modules``) garantiza que todas las tablas
queden registradas en ``SQLModel.metadata`` antes de ``create_all`` (LOCAL/TEST)
o de la autogeneración de migraciones Alembic.

Cada ``models.py`` solo importa de hojas (``database.models`` y
``api.shared.enums``) y declara las FKs por string, así que no hay ciclos.
"""

from api.modules.usuarios import models as usuarios_models  # noqa: F401
from api.modules.establecimientos import models as establecimientos_models  # noqa: F401
from api.modules.categorias import models as categorias_models  # noqa: F401
from api.modules.alimentos import models as alimentos_models  # noqa: F401
from api.modules.planes_alimenticios import models as planes_alimenticios_models  # noqa: F401
from api.modules.lotes import models as lotes_models  # noqa: F401
from api.modules.animales import models as animales_models  # noqa: F401
from api.modules.pesajes import models as pesajes_models  # noqa: F401
from api.modules.productos_sanitarios import models as productos_sanitarios_models  # noqa: F401
from api.modules.eventos_sanitarios import models as eventos_sanitarios_models  # noqa: F401
from api.modules.movimientos import models as movimientos_models  # noqa: F401
from api.modules.egresos import models as egresos_models  # noqa: F401
