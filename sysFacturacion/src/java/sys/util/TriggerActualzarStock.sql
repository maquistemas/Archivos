DELIMITER $$
CREATE TRIGGER trgActualizarStock BEFORE INSERT ON detallefactura
FOR EACH ROW
BEGIN
SET @stockAntiguo = (SELECT stockActual FROM producto WHERE codProducto = new.codProducto);
UPDATE producto
SET stockActual = @stockAntiguo - new.cantidad WHERE codProducto = new.codProducto;
END;
$$
DELIMITER;

