# Pendiente: exportación de reidentificaciones

La reidentificación queda fuera del alcance actual. Antes de implementarla se debe:

- modelar el evento sin crear un animal nuevo;
- conservar el identificador original y el nuevo;
- distinguir pérdidas parciales y pérdida del binomio completo;
- generar el TXT específico `DISPOSITIVO_ORIGINAL-DISPOSITIVO_NUEVO`;
- definir el tratamiento de casos donde se desconoce la identificación original;
- agregar pruebas de trazabilidad y aislamiento por establecimiento.

No reutilizar el generador de declaración inicial: su estructura
`RFID-SEXO-RAZA-MM/AAAA` corresponde a otro trámite de SIGSA.
