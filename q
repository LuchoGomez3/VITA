[33mcommit d1cac3aa9ab5e225236498505f109ab11cab44b7[m[33m ([m[1;36mHEAD[m[33m -> [m[1;32mepetrich9/vita-141-pesar-por-vision-artificial[m[33m)[m
Merge: 54179b2 847d58e
Author: Ernesto <epetrich9@gmail.com>
Date:   Mon Oct 5 16:46:14 2026 -0300

    Merge branch 'jornada-poster' into epetrich9/vita-141-pesar-por-vision-artificial

[33mcommit 847d58ee0261aa4411d8ffbde5a5275c10fe7aa7[m[33m ([m[1;32mjornada-poster[m[33m)[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Thu Oct 1 15:48:35 2026 -0300

    jornada poster

[33mcommit 61a1f281e0b49cf0eebcfb06ae0eb11969093438[m
Merge: 4a5dd00 078fe54
Author: francofilippa <134890143+Filippa-92191@users.noreply.github.com>
Date:   Wed Sep 23 15:19:44 2026 -0300

    Merge pull request #50 from LuchoGomez3/feature/registrar_venta_hacienda
    
    fix(db): ajustar permisos y restricciones de ventas

[33mcommit 078fe54661ea0c5f6ff71ac44ac41eda0afc026f[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Mon Sep 21 19:53:03 2026 -0300

    fix(db): resolver observaciones de revisión de ventas

[33mcommit 41e080fc842264f116a91d68b6bde8291381d806[m
Merge: e69c8b1 4a5dd00
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Mon Sep 21 18:40:20 2026 -0300

    Merge branch 'develop' into feature/registrar_venta_hacienda

[33mcommit 4a5dd003282db5194b7d4134abd2235e48940402[m
Merge: fc2d7bd 4c20745
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Mon Sep 21 16:43:59 2026 -0300

    Merge pull request #48 from LuchoGomez3/feature/vita-lotes-movimientos-batch
    
    feat(lotes): módulo de lotes y movimiento batch de animales

[33mcommit 4c2074551db4cd146922d3b3fc73ca46155be960[m[33m ([m[1;31morigin/feature/vita-lotes-movimientos-batch[m[33m)[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Mon Sep 21 16:29:26 2026 -0300

    chore(ventas): revertir la migracion reconstruida de comprador y DTe
    
    Revierte 81df1d1. Esa migracion se habia reconstruido desde el DDL
    recuperado de pg_stat_statements porque un companero la aplico a Supabase
    el 2026-09-10 y nunca la pusheo, reusando a proposito el id 20260910_02
    para que el push tardio chocara como conflicto visible.
    
    El push llego: la PR #50 trae la original como
    20260910_02_exigir_dte_y_clasificar_comprador.py. Mantener las dos deja
    dos scripts con el mismo revision y alembic no puede cargar el directorio
    de versiones, asi que `alembic heads` fallaria en develop. La cadena de la
    #50 ademas incluye 20260910_01, que restringe las politicas RLS de ventas
    a los roles admin y owner y que esta rama no tiene, aunque ya este
    aplicada en Supabase.
    
    Sobrevive la de la #50. Esta rama vuelve a terminar en 20260905_03, y la
    #50 tiene que reencadenar 20260910_01 sobre 20260905_03 y mergear despues
    de esta, para que la cadena final quede lineal y siga terminando en
    20260910_02, que es el sello actual de Supabase.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 54179b2ad85baa7638c1384838a54388ecb6b85a[m[33m ([m[1;31morigin/epetrich9/vita-141-pesar-por-vision-artificial[m[33m)[m
Merge: c7777a1 fc2d7bd
Author: Ernesto <epetrich9@gmail.com>
Date:   Mon Sep 21 15:12:20 2026 -0300

    Merge branch 'develop' into epetrich9/vita-141-pesar-por-vision-artificial

[33mcommit c7777a1b53fba0b2820b9e7fb317994f4058da17[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Mon Sep 21 15:10:54 2026 -0300

    feat(vision-weighing): implementar pesaje bovino offline con IA
    
    - incorpora captura, revisión manual y modo calibración
    - integra inferencia TFLite y persistencia del pesaje
    - vincula el resultado con animales mediante RFID
    - reorganiza la feature según Clean Architecture
    - agrega pruebas para cámara, inferencia y guardado

[33mcommit e69c8b14e3a552764d6b762fde603e7306452453[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Mon Sep 21 14:39:17 2026 -0300

    fix(db): ajustar permisos y restricciones de ventas

[33mcommit d1602cd7be4eec113e67f046840775b9565dd825[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Sep 18 19:07:54 2026 -0300

    feat(lotes): hacer opcional el lote del animal y el origen del movimiento
    
    Atiende los pedidos de Agustin en la revision del PR #48, para cerrar el
    contrato con mobile.
    
    1. El upsert POST /api/v1/lotes tambien borra, y por esa via no se validaba
       nada: un lote con hacienda adentro se podia borrar reenviando el alta con
       deleted_at, algo que el PATCH ya rechazaba. Se aplica el mismo resguardo
       y responde 409 lote_con_animales. Solo se controla la transicion, porque
       un lote ya borrado no pudo recibir animales despues.
    
    2. lote_id pasa a ser opcional al dar de alta un animal: puede ingresar sin
       asignar y ubicarse mas tarde. Cuando se informa, se conservan intactas
       las validaciones de existencia y pertenencia al establecimiento.
    
    3. lote_origen_id pasa a ser opcional en el movimiento batch: representa la
       primera asignacion de animales que no estan en ningun lote.
    
    El modelo ya contemplaba los dos casos —Animal.lote_id y
    MovimientoLote.lote_origen_id son nullable, y el CHECK del movimiento ya
    preveia el origen nulo—, asi que el cambio es de schemas y validaciones, sin
    migracion.
    
    La comprobacion de pertenencia al origen no necesito cambios: un animal sin
    lote contra un origen nulo ya da igualdad, y de paso rechaza mover sin origen
    animales que si estan asignados.
    
    Tests: los cuatro escenarios, verificados como discriminadores (fallan sin
    estos cambios y pasan con ellos). Suite completa verde con TZ=UTC.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 51d4bae2ec7415e8878c2bf14e253cfc8d97715a[m
Merge: 81df1d1 fc2d7bd
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 17 22:08:32 2026 -0300

    Merge remote-tracking branch 'origin/develop' into feature/vita-lotes-movimientos-batch

[33mcommit fc2d7bdf9e081e7636138186d38f574654c1e6c9[m
Merge: da21634 a9278cc
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Thu Sep 17 22:07:32 2026 -0300

    Merge pull request #49 from LuchoGomez3/fix/tests-zona-horaria-egresos
    
    fix(tests): calcular el día de los egresos en la zona horaria del negocio

[33mcommit a9278cc069b5b8cf2e79c53e406e1ade24831826[m[33m ([m[1;31morigin/fix/tests-zona-horaria-egresos[m[33m)[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 17 22:02:03 2026 -0300

    fix(tests): calcular el dia de los egresos en la zona horaria del negocio
    
    Los tests armaban las fechas con date.today(), que usa la zona del sistema,
    mientras el validador de la API usa ZONA_HORARIA_NEGOCIO (Cordoba). El
    runner del CI corre en UTC, tres horas adelantado, asi que entre las 00 y
    las 03 UTC el test mandaba el dia siguiente al que ve el validador y la
    API respondia 422 por fecha futura.
    
    Fallaban 9 pruebas en esa ventana horaria. No es flakiness del entorno: es
    una discrepancia real entre como calculan "hoy" la prueba y la regla de
    negocio.
    
    Verificado con TZ=UTC: sin el cambio falla, con el cambio pasa. La suite
    completa queda verde tanto en UTC como en hora argentina.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 81df1d1e7cc14bb56204c66f57b6b98690a3694b[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 17 21:56:20 2026 -0300

    feat(ventas): distinguir comprador empresa de particular y exigir el DTe
    
    Reconstruye la migracion 20260910_02, que se habia aplicado sobre Supabase
    el 10-09 pero cuyo archivo nunca se pusheo: la base quedo sellada en una
    revision inexistente en el repo y Alembic no podia resolverla.
    
    El DDL se recupero de pg_stat_statements y se reescribe con los guards
    defensivos del proyecto, asi que es idempotente sobre la base que ya lo
    tiene aplicado. Se reusa el numero de revision original a proposito: si
    aparece el archivo del autor, choca como conflicto en el mismo archivo y
    no como dos revisiones divergentes.
    
    Regla que codifica: una empresa se identifica por razon social y no lleva
    apellido; un particular lo exige no vacio. El nro_dte pasa a ser
    obligatorio porque respalda la venta ante SENASA.
    
    El test que admitia el DTe y el apellido ausentes afirmaba la regla vieja,
    asi que se reescribe en lugar de parchearse.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 6155b34a218a45463c7083012c977e381c601793[m
Merge: da2ea62 5730cfb
Author: Ernesto <epetrich9@gmail.com>
Date:   Sat Sep 12 20:33:47 2026 -0300

    merge con develop

[33mcommit da2ea62572841eac24ecacb0f60b064b9469f6bc[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Sat Sep 12 20:24:57 2026 -0300

    feat(vision-weighing): implementar cámara, revisión y modo calibración
    
    - Integrar cámara desde la navbar con animaciones y controles de orientación.
    - Agregar análisis local de calidad, revisión manual y zoom compatible con scroll.
    - Incorporar peso real de calibración y carga de fotos desde la galería.
    - Reutilizar estilos y widgets de core.
    
    Validación: 18 pruebas aprobadas y análisis sin errores.
    Pendientes: inferencia TFLite, persistencia y sincronización.

[33mcommit 8656303dacd4b8bb9db51b34983a09de0372d8f1[m
Merge: 9382b11 da21634
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Tue Sep 8 20:14:36 2026 -0300

    Merge remote-tracking branch 'origin/develop' into feature/vita-lotes-movimientos-batch

[33mcommit da216349ec4ca0211edd565cbb5653df9f027e7b[m
Merge: 5730cfb f19e377
Author: francofilippa <134890143+Filippa-92191@users.noreply.github.com>
Date:   Tue Sep 8 12:26:54 2026 -0300

    Merge pull request #47 from LuchoGomez3/feature/vita-127-estructura-ventas
    
    feat(db): estructura de base de datos para ventas de hacienda (VITA-127)

[33mcommit 9382b11374444853b47307ee4d3adccfe8c76d50[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Sat Sep 5 15:27:25 2026 -0300

    docs(lotes): actualizar la nota de roles tras la simplificacion del PR #45
    
    El ADR y el contrato citaban `external_buyer` como ejemplo de rol que no
    deberia mover hacienda. Ese rol dejo de existir: el PR #45 redujo `RolUsuario`
    a admin/owner/employee. Se reformula la nota sin nombrar un rol inexistente.
    
    CLAUDE.md sigue documentando los seis roles viejos; esa correccion excede este
    trabajo y es una decision de producto.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit e8ad5a939bac3c08842868580097459fbdf65746[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Sat Sep 5 07:56:47 2026 -0300

    feat(lotes): implementar modulo de lotes y movimiento batch de animales
    
    Mobile ya tenia toda la gestion de lotes funcionando en SQLite, con los
    contratos REST y la cola Brick cableados pero apagados por los flags
    VITA_ENABLE_LOT_REMOTE_SYNC y VITA_ENABLE_LOT_MOVEMENT_REMOTE_SYNC: el backend
    no tenia contraparte y /api/v1/lotes y /api/v1/movimientos_lotes daban 404.
    
    Entre lo que mobile serializa y lo que el backend conocia habia un
    desalineamiento de campos (faltaban geometria_local, modo_geometria, estado,
    tiene_agua y recurso_forrajero_codigo) y una incompatibilidad de cardinalidad
    en el movimiento: mobile manda una operacion con N animales y un solo UUID,
    mientras que el backend modelaba una fila por animal.
    
    Cambios principales:
    
    - Modulos completos api/modules/lotes/ y api/modules/movimientos/ siguiendo el
      patron offline-first de animales: upsert idempotente por UUID de cliente,
      last-write-wins por updated_at, tombstones y pull delta con updated_since.
    - El movimiento pasa a ser un agregado cabecera + detalle (mismo patron que
      ventas/ventas_detalles), atomico e idempotente. Un replay devuelve lo
      persistido sin volver a mover a nadie.
    - Geometria esquematica local validada con shapely: area positiva, sin
      auto-intersecciones y sin superposicion con area positiva entre lotes.
      Compartir vertice, borde o adyacencia es valido. No se incorpora PostGIS.
    - Codigos de dominio en espanol (activo/descanso/mantenimiento/inactivo),
      coherentes con el resto de los enums; mobile debe adaptarse antes de
      encender los flags.
    - Migracion 20260905_03 con backfill de los 4 lotes existentes y script SQL
      espejo. Ambos caminos verificados contra Postgres 16: producen esquemas
      identicos, la migracion es re-ejecutable y el downgrade revierte.
    - Se agregan politicas RLS a lotes y movimientos, que hasta ahora tenian RLS
      habilitada y cero politicas.
    
    Ademas, coverage no seguia los greenlets de SQLAlchemy async y reportaba como
    no cubiertos los cuerpos de todos los services: la medicion global pasa de 78%
    a 92% con concurrency = greenlet,thread en pyproject.toml. Sin eso el umbral
    de 85% de CI venia midiendo mal en todo el repo.
    
    Decisiones de contrato en docs/adr/adr-0002 y devolucion a mobile en
    docs/contrato-lotes-movimientos.md.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit f19e3777933376e6ace068496a57dd6a01f2fd53[m[33m ([m[1;31morigin/feature/vita-127-estructura-ventas[m[33m)[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Sat Sep 5 15:24:12 2026 -0300

    fix(db): reencadenar la migracion de ventas sobre 20260827_02
    
    El PR #45 incorporo 20260827_01 y 20260827_02, ambas encadenadas desde
    20260819_01, que es de donde tambien colgaba la migracion de ventas. Eso
    dejaba la historia bifurcada en dos heads en vez de lineal.
    
    Ademas, Supabase ya esta sellado en 20260827_02: con el encadenamiento
    anterior, `alembic upgrade head` fallaba con "Can't locate revision
    20260827_02" porque esa revision no existia entre los archivos de esta rama.
    
    No hace falta tocar el script espejo: los .sql no llevan id de revision.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit ef696711abecddb0dce3ceda2fc670210e62d525[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 3 13:36:24 2026 -0300

    docs(adr): corregir el estado real de egresos en Supabase
    
    El ADR afirmaba que la tabla `egresos` no existía en Supabase y que no había
    datos. Verificado contra el proyecto real: la tabla sí existe (la creó
    create_all) y tiene una fila de prueba cuyo `tipo` es 'Egreso', un valor que
    ni siquiera pertenece al enum TipoEgreso.
    
    La decisión no cambia —no hay ningún egreso de tipo `venta`, así que quitar
    ese valor del enum no deja registros huérfanos— pero la justificación escrita
    partía de un hecho falso.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit bc8710dfb4ad36ec1128b4e549640d09c5092a20[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 3 04:48:32 2026 -0300

    docs(alcance): habilitar el módulo económico y documentar migraciones
    
    La restricción dura de "no módulo económico" quedó desactualizada:
    egresos_operativos ya es un módulo económico, ventas es el otro lado del
    mismo flujo y el producto va a tener módulo económico alimentado por las
    ventas y por una futura API de precios.
    
    Se levanta la prohibición en los cuatro lugares donde vivía y que se
    contradecían entre sí: CLAUDE.md, AGENTS.md, la skill de code review (donde
    era un bloqueo CRITICAL) y el spec de pantallas (que declaraba MercadoScreen
    "no implementar bajo ningún concepto"; ahora es una pantalla pendiente sin
    spec). Quedan dentro de alcance el registro de operaciones, el flujo de caja,
    la valuación de stock en pesos, las cotizaciones externas y la simulación.
    
    Se mantiene atado a offline-first, que es donde este módulo tiene más riesgo:
    una cotización externa es una mejora, nunca una precondición. Toda pantalla
    debe renderizar y toda operación debe poder registrarse con la última
    cotización cacheada o sin ninguna; lo contrario es un hallazgo CRITICAL.
    
    Se agregan además los comandos de Alembic a las guías, con la aclaración de
    que las revisiones son deltas incrementales sobre un esquema anterior a
    Alembic: no hay baseline, así que cada upgrade() debe poder correr sobre una
    base que ya tiene los objetos.
    
    De paso, AGENTS.md y CLAUDE.md vuelven a estar sincronizados: a Codex le
    faltaba la sección entera de constraints de producto.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 88159b88ad9802cb3b7a32d4a344f31b13d5a023[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 3 04:48:16 2026 -0300

    feat(db): crear estructura de base de datos para ventas de hacienda
    
    Hasta ahora no había forma de persistir la venta de un animal. Existía un
    modelo Egreso/EgresoDetalle con TipoEgreso.venta, pero era un esqueleto
    huérfano: sin router, service, repository ni schemas, sin tabla en Supabase
    y sin código que lo referenciara.
    
    Se crean `ventas` y `ventas_detalles` como estructura nueva e independiente:
    
    - Venta es sincronizable (UUID de cliente, soft delete, last-write-wins) e
      incluye tipo de comprador, DTe, modalidad por kilo o al bulto y monto.
    - VentaDetalle hereda solo de Base: la venta es un agregado atómico y sus
      detalles viajan en su payload, sin sincronizar por separado.
    - UNIQUE (venta_id, animal_id) impide repetir un animal en la misma venta,
      pero el mismo animal puede aparecer en ventas distintas (reventa).
    - Índice (establecimiento_id, updated_at) para la descarga delta del cliente
      offline, e índice en animal_id para resolver "¿este animal ya se vendió?".
    
    `egresos` se conserva y pierde el valor `venta`: queda como salida física no
    comercial (muerte, baja, traslado externo). Ver el ADR para la frontera con
    `egresos_operativos`.
    
    Dos desvíos respecto de VITA-127, documentados en el ADR:
    
    - nro_dte es nullable. SENASA lo emite después de cerrar el trato y exigirlo
      rompería el escenario de venta en el campo sin señal (VITA-43, escenario 3).
    - apellido_comprador es nullable. Un frigorífico o un remate es una razón
      social y no tiene apellido; nombre_comprador sigue siendo obligatorio.
    
    La migración 20260902_02 es idempotente (verifica con sa.inspect antes de
    crear) y aplica RLS solo si auth.uid() existe, para que un Postgres de
    desarrollo sin Supabase también pueda migrar. Se acompaña del script espejo
    scripts/crear_ventas.sql para intervención manual; ambos caminos producen un
    esquema idéntico, verificado con pg_dump.
    
    Verificado sobre Postgres 16: upgrade sobre base existente, alembic check sin
    diferencias, head único, 5 policies RLS, 0 privilegios para anon, downgrade
    limpio y re-ejecución idempotente.
    
    Refs VITA-127
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit c73084f53f78d04bcfcde8948198af6e49fada56[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Thu Sep 3 04:47:46 2026 -0300

    chore(repo): dejar de versionar .claude/settings.json
    
    Es configuración local de cada desarrollador y no debe viajar en el
    repositorio. Agregarlo a .gitignore no alcanzaba: git sigue versionando
    los archivos que ya estaban en el índice, así que se quita con
    `git rm --cached` sin borrarlo del disco.
    
    Las skills de .claude/ sí se versionan: son criterio de equipo compartido.
    
    Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>

[33mcommit 5730cfbfacc5a8d79f23f2b58b44609fb53e71ed[m
Merge: 31601a4 afa08ed
Author: Ernesto Joaquin Petrich <133264090+ernestopetrich@users.noreply.github.com>
Date:   Sat Sep 5 14:47:24 2026 -0300

    Merge pull request #45 from LuchoGomez3/epetrich9/vita-37-visualizar-egresos-operativos
    
    Visualizar egresos operativos

[33mcommit afa08edd1d0efa33f55179caf3d2684aad36e017[m[33m ([m[1;31morigin/epetrich9/vita-37-visualizar-egresos-operativos[m[33m)[m
Merge: 30ffc23 31601a4
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Sat Sep 5 14:27:26 2026 -0300

    merge develop

[33mcommit 30ffc239bda0394f12d46e70ffb73979c2efcaca[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Sat Sep 5 14:25:15 2026 -0300

    fix(egresos): refina sincronización y validación del catálogo
    
    - desacopla el datasource financiero de Brick
    - reutiliza el transporte remoto durante la sincronización inicial
    - incorpora json_serializable a los DTOs
    - valida respuestas remotas inválidas de forma consistente
    - reconcilia categorías por identidad funcional
    - preserva UUIDs creados offline y evita duplicados
    - acepta categorías existentes como confirmadas
    - agrega Key al guard de rutas financieras
    - amplía las pruebas de sincronización y parsing

[33mcommit 65c70f2b0e45407b9766c25cc893466313fbea39[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Sat Sep 5 10:31:31 2026 -0300

    fix(egresos): corrige sincronización offline y permisos financieros
    
    - sincroniza egresos y categorías personalizadas al iniciar sesión
    - reconcilia correctamente el historial filtrado con SQLite
    - conserva operaciones pendientes ante renovaciones de sesión sin conexión
    - desacopla DTOs, autenticación y composición de dependencias
    - actualiza el catálogo offline al registrar establecimientos
    - fortalece el control de acceso a rutas financieras
    - elimina la visualización de roles en el Home
    - agrega pruebas de sincronización, permisos y resolución LWW
    - aplica el formato de Ruff a los archivos del backend

[33mcommit 31601a41605a66687f249dadb5470b81b91a759f[m
Merge: 177033f be83bae
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Aug 31 19:15:36 2026 -0300

    Merge pull request #46 from LuchoGomez3/feature/crear-lotes
    
    Feature/crear lotes

[33mcommit be83bae31ee2bb47e7a9f38236f6eb5d8741b288[m[33m ([m[1;31morigin/feature/crear-lotes[m[33m)[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Aug 31 19:13:28 2026 -0300

    elimino docs

[33mcommit 46b54d674cefd4b02030d74a66967aadf00d913d[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Aug 31 19:13:14 2026 -0300

    fix(brick): corregir notificación local tras transacciones

[33mcommit 09206cc7ab9f6d306f38b4f8e751a57735bc45be[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Aug 31 19:08:00 2026 -0300

    fix(lotes): corregir persistencia, transacciones y estados locales

[33mcommit e377d07678b18b35369cdc697c76345ed9636853[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Aug 31 17:33:08 2026 -0300

    feat(lotes): implementar gestión offline-first y preparar sincronización

[33mcommit 5ef69763582ffd231bf76e08202a0b6d6ab2867a[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Sun Aug 30 19:25:48 2026 -0300

    feature: fields mobile feature implementation done

[33mcommit c80afd68b4db8eae49d102ab579c7cd5e7f50f3c[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Fri Aug 28 13:33:15 2026 -0300

    lotes: crear y guardar lotes primera implementacion

[33mcommit 12e7b2b2a0c4f47c306f6c2274daa341f7e52063[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Thu Aug 27 21:27:32 2026 -0300

    feat(egresos): incorporar historial offline y permisos por establecimiento
    
    - agrega filtros por fecha, tipo y categoría con totales consolidados
    - incorpora exportación CSV del historial de egresos operativos
    - implementa reconciliación local, last-write-wins y estados pendientes de sincronización
    - limita la información financiera a los roles admin y owner
    - simplifica los roles a admin, owner y employee
    - expone y persiste el rol correspondiente a cada establecimiento
    - adapta navegación, perfil y opciones financieras al rol seleccionado
    - renueva la sesión y reintenta solicitudes ante respuestas 401
    - agrega migraciones, políticas RLS y cobertura de pruebas en backend y mobile

[33mcommit 177033f414a549979623eaa5b66f6627f4ede33c[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Tue Aug 25 12:45:28 2026 -0300

    chore: ignorar configuración local de VS Code

[33mcommit c156af774ae441033eb90ba724d876691a46b945[m
Merge: fd19af0 fdf2405
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Tue Aug 25 11:57:20 2026 -0300

    Merge pull request #44 from LuchoGomez3/epetrich9/vita-31-registrar-egresos-operativos
    
    registrar egresos operativos

[33mcommit fdf240519fc9155636a9fc2663ff340b5b26d3a7[m[33m ([m[1;31morigin/epetrich9/vita-31-registrar-egresos-operativos[m[33m, [m[1;32mepetrich9/vita-31-registrar-egresos-operativos[m[33m)[m
Merge: 01f8a1e fd19af0
Author: Ernesto <epetrich9@gmail.com>
Date:   Sat Aug 22 12:21:36 2026 -0300

    merge: integrar develop y resolver conflictos

[33mcommit 01f8a1e95a29b9a31143543ce79a4df30605d59b[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Sat Aug 22 12:15:36 2026 -0300

    refactor(egresos): mejorar validaciones, arquitectura y flujo offline-first
    
    - reemplazar mensajes de dominio por errores tipados de validación y persistencia
    - centralizar textos visibles en las strings de presentación
    - capturar y registrar únicamente excepciones esperadas de Brick, SQLite y REST
    - mover el catálogo base de categorías al dominio
    - validar categorías vacías en diálogo, Cubit y caso de uso
    - sincronizar egresos en segundo plano sin bloquear la UI
    - propagar rechazos de categorías personalizadas a egresos dependientes
    - extraer UUID, formatters monetarios e indicador de estado a core
    - reutilizar AppTextFormField en el formulario de egresos
    - corregir filtros globales y dependencias del dashboard
    - desacoplar la tarjeta de balance del Cubit y evitar balances simulados
    - centralizar textos y validar parámetros vacíos en el router
    - ampliar pruebas de dominio, repositorios, widgets y flujo offline

[33mcommit fd19af02109d667ed101ab2f238e7301822b3e34[m
Merge: 3e82d19 37ab5aa
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Thu Aug 20 20:08:55 2026 -0300

    Merge pull request #39 from LuchoGomez3/feature/registro-dueno
    
    Feature/registro dueno

[33mcommit f377010ca8b1432c8d2891dfb01da76de7ade972[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Thu Aug 20 11:41:27 2026 -0300

    reformateado enum.py

[33mcommit 6417ae1b8b46cde201c73d87ef15dde0a922428f[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Thu Aug 20 11:37:41 2026 -0300

    reformateado enum.py

[33mcommit 5b8d1c17936ba6499a8ee1f91167aee404cc9ab6[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Thu Aug 20 11:33:07 2026 -0300

    fix(egresos-operativos): reforzar categorías, autoría y conflictos de sincronización
    
    - documentar la relación entre CATEGORIAS_POR_TIPO y el trigger de PostgreSQL
    - agregar una prueba de contrato para detectar desincronizaciones del catálogo base
    - hacer inmutable cargado_por_id mediante un trigger BEFORE UPDATE
    - mantener la edición de egresos habilitada para miembros activos del establecimiento
    - conservar la asignación obligatoria del autor autenticado durante el INSERT
    - agregar un error de dominio específico para colisiones de UUID de categorías
    - diferenciar las colisiones de sincronización de los nombres de categoría duplicados
    - cubrir el nuevo conflicto con una prueba de aceptación
    - aclarar la diferencia entre egresos físicos de animales y egresos monetarios

[33mcommit 8747e6b4dcf756aebc5d4b19ae027a51eb7c5c52[m[33m ([m[1;32mAI-research[m[33m)[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Thu Aug 20 10:28:56 2026 -0300

    algunos modelos entrenados, hiperparametros hechos

[33mcommit 37ab5aae7a175eeb1b74445c8d105b258ad31f28[m[33m ([m[1;31morigin/feature/registro-dueno[m[33m)[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Wed Aug 19 18:08:02 2026 -0300

    fix(auth): resolver observaciones de revisión

[33mcommit 18ae08ec72414a8d4435d7dc346e664e372b20d7[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Tue Aug 18 22:29:53 2026 -0300

    buscando hiperparametros optimos

[33mcommit 97e5698f320ae121746196f5f975dab75116ecb3[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Tue Aug 18 08:34:22 2026 -0300

    primer modelo

[33mcommit 9c05f3a54687bb53016a8101158efd0d21db69c9[m
Merge: 535df62 3e82d19
Author: Ernesto <epetrich9@gmail.com>
Date:   Mon Aug 17 16:58:53 2026 -0300

    Merge branch 'develop' into epetrich9/vita-31-registrar-egresos-operativos

[33mcommit 535df62befb825c01ec7e7f7bfd603118f66984b[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Mon Aug 17 16:57:46 2026 -0300

    feat: implementado egreso operativo logica backend e integracion mobile en home

[33mcommit 43d15e10ae823720762d7659a6f76c0a54bf29b8[m
Merge: b85b743 3e82d19
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Thu Aug 13 18:24:31 2026 -0300

    Merge branch 'develop' into feature/registro-dueno

[33mcommit b85b743dbf3151ae1353d0898e58c96da6f03a5f[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Thu Aug 13 18:18:18 2026 -0300

    feat(auth): reforzar registro y seguridad de sesiones

[33mcommit e73cd039ce933a499391d8a2da1118bf19744bba[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Thu Aug 13 00:47:23 2026 -0300

    feat(auth): completar registro y manejo de sesión

[33mcommit 3e82d19d9491097c0b3aa483795c4405a419f42e[m
Merge: a604644 599767c
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Wed Aug 12 23:29:47 2026 -0300

    Merge pull request #37 from LuchoGomez3/feature/pantalla-campos
    
    feat(mobile): maquetar mapa, lista y detalle de campo y potreros

[33mcommit a60464475bedfedfb5b5dff53842b6c37f130b39[m
Merge: 1c08a33 b47c64e
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Wed Aug 12 23:29:12 2026 -0300

    Merge pull request #36 from LuchoGomez3/feature/specs-pantallas
    
    docs(specs): documentar pantallas pendientes del proyecto de diseño

[33mcommit b47c64e12e471a5652164c5c5f6127dc1d568ff4[m[33m ([m[1;31morigin/feature/specs-pantallas[m[33m)[m
Merge: f7ae9f3 1c08a33
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Wed Aug 12 23:27:18 2026 -0300

    Merge branch 'develop' into feature/specs-pantallas
    
    Resuelve conflicto agregar/agregar en estado-pantallas-diseno.md tomando
    la versión de esta rama, que ya incorporaba las actualizaciones que
    llegaron a develop por otra vía (fix de livestock_page.dart, sección
    "En progreso" para SENASA/dashboard) más la reorganización con links
    a los specs de cada flujo pendiente.

[33mcommit 599767cbc4b049b8fe248e3facfea6ca593003c3[m[33m ([m[1;31morigin/feature/pantalla-campos[m[33m)[m
Merge: 1c08a33 41db42e
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Wed Aug 12 23:26:11 2026 -0300

    Merge branch 'develop' into feature/pantalla-campos
    
    Resuelve conflictos de:
    - .claude/specs/estado-pantallas-diseno.md (agregar/agregar): se toma la
      versión de esta rama, que ya incorporaba las actualizaciones de develop
      (fix de livestock_page.dart, sección "En progreso") más la reorganización
      con links a los specs de cada flujo pendiente.
    - mobile/lib/app/router/app_router.dart y routes.dart: imports y rutas
      agregados en paralelo por establishment_register/rfid_scan (develop) y
      field (esta rama); se combinan ambos sin pérdida.
    - mobile/lib/core/widgets/widgets.dart: export agregado en paralelo,
      se combina manteniendo orden alfabético.

[33mcommit 1c08a3393c1fd03204c4cf8133120e51b8fa5de1[m
Merge: 8bebb0a cd3c6b8
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Wed Aug 12 23:05:06 2026 -0300

    Merge pull request #35 from LuchoGomez3/fix/claude-settings-json-invalido
    
    fix(config): corregir JSON inválido en .claude/settings.json

[33mcommit cd3c6b8dfc28c1e9563cc3c6f85f05c9135fb581[m[33m ([m[1;31morigin/fix/claude-settings-json-invalido[m[33m)[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Wed Aug 12 23:03:43 2026 -0300

    fix(config): corregir JSON inválido en .claude/settings.json
    
    Faltaba una coma entre dos entradas del array "allow", lo que generaba
    un warning de configuración inválida al cargar Claude Code.

[33mcommit c0e5e0608e1537448d6901a1662a40080e9c9bb4[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Wed Aug 12 20:29:14 2026 -0300

    fix(mobile): ajusta registro y sincronización tras integración

[33mcommit 99e4453762efcf61e1c617388724906006ffafef[m
Merge: a548e24 8bebb0a
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Wed Aug 12 20:22:36 2026 -0300

    Merge branch 'develop' into feature/registro-dueno

[33mcommit a548e244e547ac1497844b1bac7bedf9b3d73cac[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Wed Aug 12 19:39:28 2026 -0300

    pubspec

[33mcommit 838518f05af6194623f83795cb4da82c0b6a267c[m
Author: Franco Filippa <francofilippa40@gmail.com>
Date:   Wed Aug 12 19:38:03 2026 -0300

    feat(auth): completa flujo post-registro y protección de rutas

[33mcommit 8bebb0ae48be896c805e40ed6789294a70193ee3[m
Merge: 030d0c1 a48a02f
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Wed Aug 12 14:56:43 2026 -0300

    Merge pull request #33 from LuchoGomez3/gomezlucianoa33/vita-81-fe-pantalla-y-validaciones-de-formulario
    
    Gomezlucianoa33/vita 81 fe pantalla y validaciones de formulario

[33mcommit a48a02fef3edc34fee69dd4da73bdfea9296ffa0[m[33m ([m[1;31morigin/gomezlucianoa33/vita-81-fe-pantalla-y-validaciones-de-formulario[m[33m)[m
Merge: 7362f8f c778de5
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Wed Aug 12 14:56:29 2026 -0300

    fix(mobile): resolver merge con develop y alinear datasources

[33mcommit 030d0c183595af34ad673c0d1aa9eb55b13946fe[m
Merge: c778de5 04a8fcb
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Wed Aug 12 14:27:11 2026 -0300

    Merge pull request #32 from LuchoGomez3/feature/senasa-reporte-frontend
    
    feat: reporte SENASA

[33mcommit 04a8fcb29c47cca154a91a2d8b433744d1e1984d[m[33m ([m[1;31morigin/feature/senasa-reporte-frontend[m[33m)[m
Merge: 1dcfaa7 c778de5
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Tue Aug 11 12:27:49 2026 -0300

    merge con develop

[33mcommit 1dcfaa71492b32baa83fb459a297d6da88ec5932[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Tue Aug 11 12:23:12 2026 -0300

    fix(sync): corrige la carga inicial de Brick y mejora el historial SENASA
    
    - actualiza animales, categorías y pesajes en cada inicio de sesión
    - tolera campos opcionales y decimales enviados como texto por el backend
    - mantiene fijos el encabezado y el botón del historial SENASA
    - permite desplazar los archivos por debajo de ambos elementos
    - compacta las tarjetas y trunca nombres extensos con puntos suspensivos
    - unifica el espaciado inferior de las secciones principales

[33mcommit 7362f8f786706db6de0d45a37aa858b2e2e9e90c[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Tue Aug 11 00:39:25 2026 -0300

    fix(mobile): corregir hallazgos del review de establishment_register
    
    Aplica las correcciones confirmadas en el review de Ernesto sobre el
    alta de establecimiento (PR #33):
    
    - Redirige paso-2/paso-3/paso-4/revisar a paso-1: sin persistencia de
      borrador entre rutas, entrar directo a un paso intermedio siempre
      daba un BLoC con estado vacio.
    - Bloquea el envio real al backend mientras la ubicacion siga siendo
      el mock de "Usar mi ubicacion actual" (no se bloquea la navegacion
      del wizard).
    - Limpia el conflicto de RENSPA en submitResult cuando el usuario
      edita el CUIT o el RENSPA.
    - Captura http.ClientException en establishment_registration_repository_impl
      y en los 3 metodos de auth_repository_impl que comparten el mismo
      criterio de manejo de errores (register, signIn, refreshSession).
    - Corrige el overflow de AppOutlinedButton con labels largos + icono
      envolviendo el texto en Flexible.
    - Quita "consignatarios" del texto de invitacion de la revision: no
      corresponde a ningun rol real de RolUsuario.
    - Desacopla establishment_empty_state_page.dart de AuthSessionCubit:
      ahora recibe onSignOut inyectado desde el router, igual que
      ProfilePage.
    
    Pendiente, fuera de este commit: departamento/localidad dependientes
    de provincia (el propio review lo marca como no bloqueante por ahora)
    y el mapeo de roles invitables restantes (asset_manager/external_buyer)
    necesita definicion de copy con Ernesto antes de tocar el texto.
    
    Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>

[33mcommit 41db42e0c54d526442c4606bf80f1404556fa127[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Mon Aug 10 22:27:07 2026 -0300

    feat(mobile): maquetar mapa, lista y detalle de campo y potreros
    
    Etapa 1 (maquetado) del flujo de campo: mapa mosaico de potreros coloreado
    por densidad de carga, lista escaneable con chips de filtro, y ficha de
    detalle con KPIs, forraje/servicios, composición del rodeo e historial de
    ocupación. Sin validaciones ni conexión a backend (repositorio/backend de
    potreros no existe todavía).
    
    Introduce el widget compartido AppStatusChip. Acceso vía atajo de desarrollo
    en Hacienda, siguiendo el mismo patrón que animales.
    
    Ver .claude/specs/campo-y-potreros.md para el detalle de campos y datos mock.

[33mcommit c778de5940268482d0359a0b1b5e1e878d40ab71[m
Merge: 1f19d87 961b64c
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Sun Aug 9 23:38:35 2026 -0300

    Merge pull request #34 from LuchoGomez3/molinaagustinpr/vita-8-identificar-caravana-electronica
    
    feat(rfid): implementar identificación offline de animales por caravana electronica

[33mcommit 961b64c1a5942dc6eb6d13c8786cf10572755a7d[m[33m ([m[1;31morigin/molinaagustinpr/vita-8-identificar-caravana-electronica[m[33m)[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Sun Aug 9 23:32:55 2026 -0300

    feat(rfid): implementar identificación offline de animales por caravana electrónica

[33mcommit 0488127db55eaddff9e4256f62d9e91803f39215[m[33m ([m[1;32mfeature/senasa-reporte-frontend[m[33m)[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Sun Aug 9 21:34:07 2026 -0300

    refactor(senasa): separar responsabilidades de acceso a datos y composición

[33mcommit e479093fcce93e0c4b810d4074d8e6fc1db5e598[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Sun Aug 9 17:48:31 2026 -0300

    fix(senasa): centraliza strings y formatos de UI

[33mcommit 8e1ad825f499432cc76e6339ded25b32603df7ba[m
Author: Ernesto <epetrich9@gmail.com>
Date:   Sat Aug 8 20:23:11 2026 -0300

    feat(senasa): implementa declaración e historial de dispositivos electrónicos
    
    Implementa el flujo completo para generar declaraciones de dispositivos
    electrónicos compatibles con la importación de SIGSA, conservar un historial
    auditable y volver a descargar los archivos desde la aplicación móvil.
    
    Backend:
    - reemplaza el reporte genérico de eventos por una declaración específica de
      dispositivos electrónicos;
    - selecciona los animales por su fecha de creación en VITA, debido a que el
      registro se realiza al momento de aplicar la caravana;
    - mantiene la fecha de nacimiento únicamente como dato requerido dentro del
      archivo exportado;
    - genera archivos TXT sin encabezado con el formato requerido por SIGSA:
      RFID-SEXO-RAZA-MM/AAAA, separando los registros mediante punto y coma;
    - valida que cada RFID sea ASCII, numérico y tenga exactamente 15 dígitos;
    - valida sexo, raza y fecha de nacimiento antes de generar el archivo;
    - normaliza las razas y las convierte a sus códigos oficiales de SENASA;
    - evita generar parcialmente una declaración cuando existen animales con datos
      incompletos o incompatibles;
    - agrega un endpoint POST específico para generar la declaración y persistir el
      archivo;
    - agrega un endpoint independiente para validar los registros sin generar ni
      guardar una exportación;
    - conserva temporalmente el endpoint GET anterior como adaptador deprecado;
    - elimina el acta de vacunación como tipo de exportación admitido;
    - distingue el TXT oficial del PDF, que queda únicamente como resumen interno
      sin validez ante SENASA;
    - mantiene la reidentificación fuera del alcance actual y documenta su futura
      implementación como un flujo independiente.
    
    Historial y trazabilidad:
    - agrega la tabla exportaciones_senasa para almacenar los archivos generados;
    - conserva el contenido binario exacto para impedir que una modificación
      posterior del animal altere un documento histórico;
    - almacena el nombre, formato, tipo de exportación, media type, período,
      establecimiento, usuario generador y cantidad de animales;
    - calcula y persiste un hash SHA-256 del archivo para comprobar su integridad;
    - agrega la tabla exportaciones_senasa_animales para registrar la composición
      exacta de cada exportación;
    - permite listar las exportaciones de un establecimiento sin transferir
      innecesariamente su contenido binario;
    - permite volver a descargar exactamente el archivo originalmente generado;
    - responde con 404 cuando se intenta consultar una exportación perteneciente a
      otro establecimiento para no revelar recursos de otro tenant;
    - registra automáticamente todos los archivos y animales involucrados, sin
      requerir que el usuario mantenga estados manuales;
    - evita afirmar que una declaración fue informada o aceptada por SENASA, ya que
      VITA no recibe actualmente una confirmación oficial de SIGSA.
    
    Supabase:
    - agrega el script de creación de las tablas de exportaciones y sus índices;
    - incorpora claves foráneas hacia establecimientos, usuarios y animales;
    - agrega restricciones para formatos, hashes, cantidades y períodos válidos;
    - protege las exportaciones mediante triggers que impiden su modificación o
      eliminación;
    - habilita Row Level Security en ambas tablas;
    - agrega políticas para que solamente miembros activos del establecimiento
      puedan consultar o crear exportaciones;
    - valida que todos los animales relacionados pertenezcan al mismo
      establecimiento de la exportación;
    - revoca el acceso anónimo y limita los permisos autenticados a lectura e
      inserción;
    - incorpora un script de migración para instalaciones que ya utilizaron la
      versión anterior con la columna tipo_evento;
    - conserva valores históricos anteriores sin permitir que el backend genere
      nuevas actas de vacunación.
    
    Aplicación móvil:
    - reemplaza el flujo genérico de reportes por uno específico para declaración
      de dispositivos electrónicos;
    - elimina el selector de tipo de evento y la opción de acta de vacunación;
    - elimina la selección de PDF como formato oficial para SIGSA;
    - simplifica el formulario a establecimiento, período y nombre del archivo;
    - actualiza los textos para explicar que VITA prepara el archivo, pero que la
      declaración oficial debe completarse posteriormente en SIGSA;
    - integra el endpoint POST de validación sin efectos secundarios;
    - muestra la cantidad de animales que pueden exportarse;
    - presenta los animales con datos incompletos y los campos que deben
      corregirse;
    - impide avanzar con la generación cuando la validación detecta errores;
    - integra el endpoint POST que genera y almacena el TXT;
    - procesa correctamente el contenido binario y el nombre devuelto mediante
      Content-Disposition;
    - incorpora la consulta del historial remoto de exportaciones;
    - deja de depender exclusivamente de los archivos almacenados localmente para
      reconstruir el historial;
    - agrega la descarga de archivos históricos mediante su identificador;
    - permite guardar y compartir nuevamente una exportación descargada;
    - agrega casos de uso específicos para validar, consultar el historial y
      descargar archivos;
    - actualiza el repositorio de dominio y su implementación HTTP;
    - adapta las entidades Freezed a los nuevos requests, resultados de validación
      y metadatos de exportaciones;
    - agrega un cubit para gestionar el historial presentado en el menú SENASA;
    - actualiza la composición de dependencias del módulo;
    - ajusta la navegación entre menú, generación y pantalla de éxito;
    - mejora los estados de carga, error, validación y generación;
    - mantiene mensajes comprensibles ante errores de autenticación, conectividad,
      validación y servidor;
    - centraliza los nuevos textos de interfaz;
    - actualiza componentes visuales compartidos utilizados por el flujo;
    - elimina widgets y pruebas correspondientes al selector de eventos y al paso
      de selección de formato que dejaron de ser necesarios.
    
    Pruebas:
    - verifica la generación del TXT con el formato exigido por SIGSA;
    - comprueba el uso de punto y coma como separador entre dispositivos;
    - prueba la normalización de nombres de archivo, sexo y raza;
    - valida el rechazo de RFID no numéricos o con longitud inválida;
    - comprueba que los animales se seleccionen por created_at y no por su fecha de
      nacimiento;
    - verifica que un animal nacido anteriormente pueda declararse al ser
      caravaneado recientemente;
    - comprueba que la validación no cree registros en el historial;
    - verifica que el contenido histórico no cambie después de modificar el animal;
    - prueba el hash, los metadatos y la cantidad de animales almacenados;
    - comprueba el aislamiento entre establecimientos;
    - verifica el rechazo del tipo acta_vacunacion;
    - actualiza las pruebas del repositorio móvil para los nuevos endpoints y
      respuestas;
    - agrega cobertura para validación, generación, historial y descarga;
    - actualiza las pruebas del cubit y de las pantallas del flujo SENASA;
    - elimina pruebas de componentes que ya no forman parte del alcance funcional.

[33mcommit f7ae9f38cc3840491ba3896ba5603bd7b6d662da[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 22:11:36 2026 -0300

    docs(specs): documentar pantallas pendientes del proyecto de diseño
    
    Trae los dos specs base (índice de pantallas + registrar-establecimiento)
    desde la rama vita-81 sin arrastrar sus commits de validaciones/backend, y
    agrega un spec por flujo pendiente (campo, pesaje, sanidad, equipo, sync,
    ajustes) con las secciones, campos y datos mock del diseño de referencia.
    Marca Reportes SENASA como cubierto por el PR #32 en curso.

[33mcommit ffb57e45f879627efda4dda1b5a6affca62f5a28[m[33m ([m[1;32mgomezlucianoa33/vita-81-fe-pantalla-y-validaciones-de-formulario[m[33m)[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 21:27:16 2026 -0300

    style(backend): aplicar ruff format
    
    CI corre ruff format --check además de ruff check; estos 3 archivos habían
    quedado sin pasar por el formatter tras la Etapa 3 de establecimientos.

[33mcommit cf3936f29e3e2dbc586e42177f1bda09f7dff877[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 21:24:03 2026 -0300

    style(mobile): ordenar alfabéticamente los imports de app_router.dart
    
    Quedó desordenado tras resolver el conflicto de merge con develop.

[33mcommit 8bc07c89f1d42728d28d78a58e4dd4afb2cf6746[m
Merge: 4df0f4c 1f19d87
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 21:23:49 2026 -0300

    Merge remote-tracking branch 'origin/develop' into gomezlucianoa33/vita-81-fe-pantalla-y-validaciones-de-formulario
    
    # Conflicts:
    #       mobile/lib/app/router/app_router.dart
    #       mobile/lib/features/home/presentation/pages/home_page.dart
    #       mobile/lib/features/home/presentation/strings/home_strings.dart

[33mcommit 4df0f4ce90a0fff5d93adcb2b3773295baa65cc2[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 20:09:57 2026 -0300

    feat(mobile): conectar el registro de establecimiento al backend real
    
    Reemplaza el repositorio mock por una implementación real contra
    POST /api/v1/establecimientos, preservando el error.code del backend para
    distinguir RENSPA duplicado (vuelve al paso 2 con banner inline) de errores
    de conectividad (modal offline) del resto (snackbar genérico).
    
    Extiende el registro de dueño para hidratar el token en memoria con la
    sesión que el backend ya devuelve, sin persistirla ni correr sync inicial:
    resuelve que "Configurar mi establecimiento" no tenía token disponible tras
    el alta, sin convertir el registro en un login real.

[33mcommit ac96503b40bc972f06e9563ef9009643392baec7[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 20:09:42 2026 -0300

    feat(backend): el registro de usuario devuelve la sesión completa
    
    /api/v1/usuarios/registro ahora responde refresh_token + expires_in además
    del access_token, igual contrato que /auth/login. Es la base para que el
    mobile pueda encadenar el alta de establecimiento sin pedir login aparte.

[33mcommit f27a60ab40c3fba764a78d537535cc13d41af577[m
Author: Lucho Gomez <gomezluciano.a33@gmail.com>
Date:   Fri Jul 31 20:09:24 2026 -0300

    feat(backend): extraer validación de CUIT a módulo compartido y extender establecimientos
    
    Extrae normalizar_cuit/validar_cuit/CuitInvalidoError a api/shared/cuit.py
    para que usuarios y establecimientos usen la misma implementación. Suma
    descripcion, tipo_produccion, latitud/longitud y poligono (JSON, sin
    PostGIS) al modelo de establecimientos, con validación de formato de
    RENSPA/CUIT/superficie en el service y un nuevo PUT /api/v1/establecimientos/{id}.

[33mcommit f75b6276e5447685ab32dda58889151218470b14[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Thu Jul 30 18:58:39 2026 -0300

    feat(senasa): integra generación de reportes y navegación desde trámites

[33mcommit 1f19d87263efeecc904721a9667de5d725629156[m
Merge: 899f86c b13c76d
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Thu Jul 30 14:46:50 2026 -0300

    Merge pull request #31 from LuchoGomez3/navbar-front
    
    Navbar

[33mcommit b13c76da4e99177dedbf4e6b0b3d7c8eaee8fe76[m[33m ([m[1;31morigin/navbar-front[m[33m)[m
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Thu Jul 30 14:44:28 2026 -0300

    refactor(mobile): ordenar responsabilidades de auth sync y home

[33mcommit 2fabba25382226d71f6b58fa20bedd33b5c003fd[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Wed Jul 29 16:36:35 2026 -0300

    logo nuevo y nombre cambiado

[33mcommit 704cdf4763fd17152df99fe21582e87070b62376[m
Author: Ernesto Joaquin Petrich <epetrich9@gmail.com>
Date:   Wed Jul 29 15:49:56 2026 -0300

    rama creada y funcionalidad agregada

[33mcommit 0312e52d44a08c9eabbdc654b98f9043eb07e0bc[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:45:25 2026 -0300

    feat(mobile): agregar validaciones de campo al wizard de registro de establecimiento
    
    Etapa 2 del flujo: RegisterEstablishmentDraftValidation centraliza las
    reglas de cada paso (nombre y tipo de producción en identificación,
    CUIT/RENSPA con formato válido, ubicación confirmada por GPS, superficie
    positiva) y se usa tanto para habilitar/deshabilitar "Siguiente"/"Crear
    establecimiento" en la UI como para revalidar de forma defensiva antes
    de armar el request en el BLoC. El draft ya no arranca con datos
    ficticios (Etapa 1): ahora el usuario tiene que completar el formulario
    para poder avanzar.

[33mcommit d1359088dd1b37fb9c3ab4027975528562eb75a7[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:45:15 2026 -0300

    feat(mobile): agregar RenspaInputFormatter para validar el número de RENSPA
    
    Mismo patrón que CuitInputFormatter: aplica la máscara NN.NNN.N.NNNNN/NN
    en vivo y reporta si la entrada está incompleta, con caracteres
    inválidos o excede los 13 dígitos esperados.

[33mcommit eac786e269e40d0b57587f7f712d92c6851e7efc[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:27:23 2026 -0300

    feat(mobile): maquetar pantalla de éxito de registro de establecimiento
    
    Reemplaza el placeholder por la UI real de la pantalla de éxito: check de
    confirmación, tarjeta resumen del establecimiento (RENSPA, ubicación, chip
    Owner, mini-stats de superficie/cabezas/UP) y las 3 sugerencias de próximos
    pasos. Cierra la Etapa 1 (maquetado) del flujo de registro de
    establecimiento — actualiza el spec con el estado final.

[33mcommit c4b56a7efe7c3ce6868535f41b30a11a36049084[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:25:14 2026 -0300

    feat(mobile): maquetar pantalla de revisión de establecimiento
    
    Reemplaza el placeholder por la UI real de "Revisar y crear": 4 tarjetas de
    resumen (identificación, RENSPA y titular, ubicación, superficie) con enlace
    "Editar" que salta directo al paso correspondiente, y la nota de rol Owner.
    Extrae el polígono decorativo del paso 4 a FieldBoundaryPreview (widget
    compartido) para reusarlo como miniatura sin vértices en la tarjeta de
    superficie.

[33mcommit 81abae1e08b3566a1da12fd04e776a02e11ccf1d[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:21:11 2026 -0300

    feat(mobile): maquetar paso 4 de registro de establecimiento - delimitar superficie
    
    Reemplaza el placeholder por la réplica visual estática del paso 4: banner
    de instrucciones, mapa decorativo con polígono de 7 vértices numerados
    (CustomPainter, sin SDK de mapas real), chip flotante de superficie/vértices,
    herramientas decorativas (deshacer/borrar/capa) y hint inferior. Todo con
    valores fijos, sin interacción real de dibujo (decisión de producto).

[33mcommit 7bf29f46f5ea363d41280b69d3124ffedd65ed07[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:19:43 2026 -0300

    feat(mobile): maquetar paso 3 de registro de establecimiento - ubicación geográfica
    
    Reemplaza el placeholder por la UI real del paso 3: provincia, departamento,
    localidad, coordenadas del punto de referencia con confirmación de GPS
    (mock), botón "Usar mi ubicación actual" y vista previa de mapa decorativa
    (StaticMapPreview, sin SDK real).

[33mcommit 8e8d434f7995c5f264259fd2724bb62c135b3616[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:17:35 2026 -0300

    feat(mobile): maquetar paso 2 de registro de establecimiento - RENSPA y titular
    
    Reemplaza el placeholder por la UI real del paso 2: CUIT del titular, número
    de RENSPA con desglose visual (provincia/depto/actividad/titular/unidad
    productiva) y nota informativa de validación SENASA. Agrega tokens de
    tipografía mono (placeholder hasta sumar Source Code Pro) y un override de
    estilo opcional en AppTextFormField para poder aplicarlos.

[33mcommit ca01a9f8f532f996565779ab1fc6be095feb305d[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:11:50 2026 -0300

    feat(mobile): maquetar paso 1 de registro de establecimiento - identificación
    
    Reemplaza el placeholder por la UI real del paso 1: nombre, descripción
    opcional y tipo de producción (multi-selección). Extiende AppChoiceSelector
    con un callback isSelected opcional para soportar selección múltiple sin
    romper los usos existentes de selección única.

[33mcommit d15f2b6f3a1550b12dc2b7cb905c79dcb1d5a21e[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Wed Jul 29 00:09:03 2026 -0300

    feat(mobile): scaffold del flujo y pantalla de estado vacío
    
    Arma el scaffold completo de registrar-establecimiento (dominio, bloc de 5
    pasos, repositorio mock, rutas y composition root) y maqueta la pantalla de
    estado vacío, dejando el flujo navegable de punta a punta con placeholders
    en el resto de las pantallas. Documenta la lógica de negocio del flujo en
    .claude/specs/registrar-establecimiento.md.

[33mcommit 899f86c190793b69c70a9f4bf739ba78089cb675[m
Merge: df7483a 96b237a
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Tue Jul 28 22:24:59 2026 -0300

    Merge pull request #30 from LuchoGomez3/gomezlucianoa33/vita-117-be-corregir-validaciones-contrasena-nombre-y-apellido
    
    se agregaron validaciones en contraseña, nombre y apellido

[33mcommit 96b237a2637610c272f9953dd421dc6a4c6cbbcd[m[33m ([m[1;31morigin/gomezlucianoa33/vita-117-be-corregir-validaciones-contrasena-nombre-y-apellido[m[33m)[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Tue Jul 28 22:23:51 2026 -0300

    se agregaron validaciones en contraseña, nombre y apellido

[33mcommit df7483a40a7aa0fa9f5a81097a4f786647f4e438[m
Merge: 44dd0a0 1bc5e23
Author: Luciano Gomez <124113207+LuchoGomez3@users.noreply.github.com>
Date:   Tue Jul 28 22:15:51 2026 -0300

    Merge pull request #27 from LuchoGomez3/gomezlucianoa33/vita-111-qa-pruebas-funcionales-de-registro-y-validaciones-de-negocio
    
    Gomezlucianoa33/vita 111 qa pruebas funcionales de registro y validaciones de negocio

[33mcommit 1bc5e23bac0c152cfd4e06aa2fb907cd6e1be4b8[m[33m ([m[1;31morigin/gomezlucianoa33/vita-111-qa-pruebas-funcionales-de-registro-y-validaciones-de-negocio[m[33m)[m
Author: Lucho Gomez <luciano@blumb.ai>
Date:   Tue Jul 28 22:09:02 2026 -0300

    correccion de tests

[33mcommit 44dd0a031154010565393cefa5762b328eb9ffa9[m
Merge: 76904f9 bb498b4
Author: Agustin-Molina <molinaagustinpr@gmail.com>
Date:   Mon Jul 27 02:37:25 2026 -0300

    Merge pull request #8 from LuchoGomez3/feature/visualizar-animal-frontend
    
    Feature/visualizar animal frontend
