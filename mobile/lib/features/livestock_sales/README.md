# Ventas de hacienda

El registro confirma la operación y la baja de los animales en una única
transacción SQLite. El precio total es obligatorio; una venta puede quedar sin
cobro inicial, pero no sin precio pactado.

En **Movimientos → Ventas** se consulta el historial local del establecimiento
activo, ordenado por fecha de operación de la más reciente a la más antigua.
Cada tarjeta muestra comprador, animales, total, cobrado y saldo pendiente.

Las ventas con condición `pendiente` y sin cobro inicial permiten confirmar la
recepción del total pactado y elegir el medio de pago. El cambio se valida y
persiste sin volver a dar de baja los animales. La transacción comprueba otra
vez que la venta pertenezca al establecimiento y no tenga un cobro, para impedir
que una pantalla desactualizada sobrescriba un pago existente.

La lectura y el cobro siguen esta dependencia:

```txt
presentation (Cubit) → domain (casos de uso y contrato)
                    → data (mapper y repositorio) → Brick → SQLite
```

La aplicación compone las secciones de Movimientos mediante el router; egresos
no importa widgets ni implementaciones internas de ventas.

## Alcance temporal de la presentación

En modo demo, cada inicio elimina las ventas antes de restaurar los animales
de ejemplo, incluso sin `DEMO_RESET`. Después restaura una venta sintética
cobrada por $1.200.000 y marca su animal como vendido. Fuera del modo demo no
se ejecuta esta limpieza ni la siembra de ejemplos.

La confirmación posterior de cobro se conserva **solo en SQLite**. El backend
actual expone el POST de alta de venta con cobro inicial, pero todavía no un
comando para cobrar ventas existentes. No se reenvía el POST de alta para
simular ese comando. Antes de usar esta acción con backend hay que implementar
su endpoint y su cola offline. Los cobros parciales creados en el registro se
visualizan; el historial no agrega cobros posteriores a esas operaciones.

## Balance operativo de Inicio

Inicio suma el precio total de las ventas vigentes y resta los gastos del mismo
alcance de establecimientos. Trabaja en centavos enteros para evitar errores de
precisión. Incluye ventas pendientes de cobro: el balance representa operaciones
comerciales registradas, no dinero disponible en caja. Con los ejemplos iniciales,
$1.200.000 de ventas menos $508.100 de gastos dan $691.900 de balance.
