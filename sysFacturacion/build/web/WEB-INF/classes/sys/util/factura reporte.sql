SELECT concat(cliente.nombres," " ,cliente.apellidos) as nombreCliente, cliente.direccion, concat(vendedor.nombres, " ", vendedor.apellidos)
as nombreVendedor, detallefactura.*
FROM cliente, vendedor, detallefactura
WHERE cliente.codCliente=$P{codCliente} and
vendedor.codVendedor=$P{codVendedor} and
detallefactura.codfactura=$P{codFactura}
