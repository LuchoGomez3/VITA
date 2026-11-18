# RFID scan

Esta feature identifica animales a partir de una caravana electronica sin
dependencia de conectividad. El MVP recibe lecturas desde bastones configurados
como teclado Bluetooth HID y usa Enter como delimitador de cada lectura.

`RfidReadingSource` es la frontera del transporte. BLE y Bluetooth serial
deberan implementar el mismo contrato cuando el producto requiera soportarlos.

Al encontrar un animal, el MVP usa vibracion nativa de Flutter como
confirmacion. El sonido queda pendiente: requerira elegir un paquete de audio y
un asset breve con licencia apta para la aplicacion.

El autocompletado consulta SQLite por prefijo. Una falla de lectura se expone
con `suggestionsFailed` en el estado inactivo, distinta de una lista vacia.
La pantalla conserva el texto manual y permite reintentar al escribir o buscar
la caravana completa. Data registra el tipo de error y stack, sin mensajes de
excepciones que puedan contener datos de animales o del establecimiento.
