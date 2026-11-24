# Ventas de hacienda

El registro confirma la venta y la baja de sus animales en una transaccion
SQLite antes de encolar el alta remota. El historial reutiliza esa misma fuente
local y conserva el aislamiento por establecimiento:

```txt
presentation -> domain -> data -> BrickLivestockSaleStore -> SQLite
```

`Movimientos -> Ventas` es de solo lectura. Muestra el precio pactado, el cobro
inicial, el saldo y el estado de sincronizacion como conceptos separados. No
permite agregar cobros posteriores porque el backend todavia no ofrece ese
comando ni una cola offline para sincronizarlo.

El historial aplica en memoria filtros combinables por fecha, modalidad,
comprador y estado de cobro sobre las ventas ya leidas desde SQLite. Cambiar o
limpiar un filtro no requiere conectividad ni vuelve a consultar Brick.

Cada tarjeta abre un detalle de solo lectura mediante una ruta protegida. La
ruta transporta unicamente los UUID de la venta y del establecimiento: el
detalle vuelve a consultar SQLite a traves de dominio y data, por lo que no
depende de objetos en memoria ni de conectividad. Al volver, el historial
conserva sus filtros y posicion porque permanece en la pila de navegacion.
Los UUID asociados se resuelven en una lectura SQLite por lotes, siempre
acotada al establecimiento activo. El detalle muestra caravana visual, RFID,
categoria y lote cuando estan disponibles; si falta una copia local, informa
la degradacion sin ocultar el resto de la operacion.

La venta conserva localmente el UUID y el nombre visible del usuario que la
confirmo, junto con `createdAt`. Esos datos permiten mostrar trazabilidad sin
conexion y se mantienen durante la conciliacion. No se envian como autoridad:
el backend sigue determinando `registrada_por_id` exclusivamente desde el JWT.

El sync inicial descarga `GET /ventas` por cada establecimiento comercial y
concilia la respuesta en SQLite antes de que presentacion la consuma. Las altas
pendientes o rechazadas no se pisan con una descarga: conservan su UUID y su
payload local hasta recibir un resultado definitivo de la cola.
La copia descargada guarda tambien el cobrado y el saldo calculados por backend,
en lugar de inferirlos del primer cobro, para que futuros pagos posteriores se
vean correctamente y sigan disponibles sin conexion.

Mientras el historial o el detalle estan abiertos, ambos escuchan los cambios
confirmados por Brick en SQLite. Asi, una venta pendiente se refleja como
sincronizada, rechazada o reintentable cuando la cola termina de procesarla,
sin pedir una recarga manual ni depender de una consulta remota.

Los datos de demostracion de `jornada-poster` no forman parte de esta feature.
