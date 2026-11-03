# ADR-0013: inferencia local con recursos por captura

- Fecha: 2026-10-26
- Estado: propuesto para revisión humana
- Historia: VITA-141

## Contexto

La recuperación de pesaje por visión toma código de una rama de presentación.
El código original conservaba un intérprete y un worker globales sin cierre.
Los modelos y sus márgenes son experimentales y quedan fuera de esta rama.
La captura, revisión y calibración deben seguir funcionando sin red ni modelo.

## Decisión

Mantener el contrato de inferencia en Domain e implementar TFLite en Data.
Cargar solo assets locales. Cada inferencia ejecuta codec, preprocesamiento,
creación del intérprete y ejecución en `compute`, y cierra el intérprete en
`finally`. El Cubit descarta resultados tardíos al cerrar o repetir la sesión.
La ausencia o incompatibilidad del paquete se representa con una excepción
tipada: se conserva la captura para revisión, se muestra la limitación y se
impide guardar un peso IA sin resultado válido.

## Consecuencias

No hay handles nativos ni isolates globales para liberar desde el router.
Un procesamiento iniciado puede terminar después de salir y libera sus propios
recursos. El costo de cargar el modelo se repite por captura; falta medirlo en
dispositivos antes de proponer precarga o un worker con dueño explícito.

La rama no ofrece estimaciones reales hasta incorporar un modelo y margen
aprobados con su declaración de assets. Los tests verifican contrato y flujo,
sin usar pesos experimentales ni acreditar precisión ganadera.
