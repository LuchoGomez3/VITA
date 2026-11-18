/// Medianoche comercial en Cordoba (UTC-3), igual que el contrato de ventas.
DateTime saleProductiveStatusChangedAt(DateTime operationDate) =>
    DateTime.utc(operationDate.year, operationDate.month, operationDate.day, 3);
