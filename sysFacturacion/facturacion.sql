/*
SQLyog Enterprise - MySQL GUI v8.05 
MySQL - 5.5.37 : Database - facturacion
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/`facturacion` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci */;

USE `facturacion`;

/*Table structure for table `cliente` */

DROP TABLE IF EXISTS `cliente`;

CREATE TABLE `cliente` (
  `codCliente` int(11) NOT NULL AUTO_INCREMENT,
  `nombres` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `apellidos` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` varchar(150) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`codCliente`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `cliente` */

insert  into `cliente`(`codCliente`,`nombres`,`apellidos`,`direccion`) values (2,'CARLOS ANTONIO','SERMEÑO AGUILAR','SANTA ANA'),(3,'SANDRA','BONILLA','SAN SALVADOR'),(4,'JOSUE','COREAS','SAN MIGUEL'),(5,'MARIA ','ARTERO GOMEZ','SAN SALVADOR');

/*Table structure for table `detallefactura` */

DROP TABLE IF EXISTS `detallefactura`;

CREATE TABLE `detallefactura` (
  `codDetalle` int(11) NOT NULL AUTO_INCREMENT,
  `codFactura` int(11) NOT NULL,
  `codProducto` int(11) NOT NULL,
  `codBarra` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `nombreProducto` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precioVenta` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`codDetalle`),
  KEY `FK_detallefactura_factura` (`codFactura`),
  KEY `FK_detallefactura_producto` (`codBarra`),
  KEY `FK_detallefactura_prodcto` (`codProducto`),
  CONSTRAINT `FK_detallefactura_factura` FOREIGN KEY (`codFactura`) REFERENCES `factura` (`codFactura`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_detallefactura_prodcto` FOREIGN KEY (`codProducto`) REFERENCES `producto` (`codProducto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `detallefactura` */

insert  into `detallefactura`(`codDetalle`,`codFactura`,`codProducto`,`codBarra`,`nombreProducto`,`cantidad`,`precioVenta`,`total`) values (1,39,1,'10101010','TECLADO USB',10,'6.55','65.50'),(2,40,1,'10101010','TECLADO USB',5,'6.55','32.75'),(3,40,3,'10101012','PANTALLA LED 24 °',2,'250.30','500.60'),(4,40,1,'10101010','TECLADO USB',2,'6.55','13.10'),(5,41,1,'10101010','TECLADO USB',3,'6.55','19.65'),(6,42,1,'10101010','TECLADO USB',5,'6.55','32.75'),(7,43,1,'10101010','TECLADO USB',5,'6.55','32.75'),(8,43,3,'10101012','PANTALLA LED 24 °',5,'250.30','1251.50'),(9,44,1,'10101010','TECLADO USB',2,'6.55','13.10'),(10,45,1,'10101010','TECLADO USB',3,'6.55','19.65'),(11,46,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(12,47,1,'10101010','TECLADO USB',1,'6.55','6.55'),(13,48,1,'10101010','TECLADO USB',2,'6.55','13.10'),(14,48,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(15,49,3,'10101012','PANTALLA LED 24 °',3,'250.30','750.90'),(16,49,1,'10101010','TECLADO USB',3,'6.55','19.65'),(17,50,1,'10101010','TECLADO USB',1,'6.55','6.55'),(18,51,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(19,52,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(20,53,1,'10101010','TECLADO USB',2,'6.55','13.10'),(21,53,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(22,54,1,'10101010','TECLADO USB',1,'6.55','6.55'),(23,55,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(24,56,1,'10101010','TECLADO USB',2,'6.55','13.10'),(25,56,3,'10101012','PANTALLA LED 24 °',3,'250.30','750.90'),(26,57,3,'10101012','PANTALLA LED 24 °',1,'250.30','250.30'),(27,58,5,'10101014','LAMPARA CF',2,'75.00','150.00'),(28,59,6,'10101015','MEMORIA RAM DDR3',2,'20.00','40.00'),(29,60,5,'10101014','LAMPARA CF',3,'75.00','225.00'),(30,61,4,'10101013','CASE ATX',2,'20.50','41.00'),(31,62,6,'10101015','MEMORIA RAM DDR3',2,'20.00','40.00'),(32,62,7,'10101016','DICO DURO 300GB',3,'50.00','150.00'),(33,62,6,'10101015','MEMORIA RAM DDR3',2,'20.00','40.00'),(34,62,3,'10101012','PANTALLA LED 24 °',2,'250.30','500.60'),(35,63,1,'10101010','TECLADO USB',2,'6.55','13.10'),(36,63,4,'10101013','CASE ATX',2,'20.50','41.00'),(37,64,5,'10101014','LAMPARA CF',5,'75.00','375.00'),(38,65,6,'10101015','MEMORIA RAM DDR3',2,'20.00','40.00'),(39,66,6,'10101015','MEMORIA RAM DDR3',2,'20.00','40.00'),(40,66,7,'10101016','DICO DURO 300GB',2,'50.00','100.00'),(41,66,3,'10101012','PANTALLA LED 24 °',2,'250.30','500.60'),(42,67,3,'10101012','PANTALLA LED 24 °',2,'250.30','500.60'),(43,67,7,'10101016','DICO DURO 300GB',2,'50.00','100.00'),(44,67,5,'10101014','LAMPARA CF',4,'75.00','300.00'),(45,68,1,'10101010','TECLADO USB',2,'6.55','13.10'),(46,68,5,'10101014','LAMPARA CF',1,'75.00','75.00'),(47,68,6,'10101015','MEMORIA RAM DDR3',1,'20.00','20.00'),(48,68,7,'10101016','DICO DURO 300GB',2,'50.00','100.00'),(49,69,7,'10101016','DICO DURO 300GB',10,'50.00','500.00'),(50,70,7,'10101016','DICO DURO 300GB',10,'50.00','500.00');

/*Table structure for table `factura` */

DROP TABLE IF EXISTS `factura`;

CREATE TABLE `factura` (
  `codFactura` int(11) NOT NULL AUTO_INCREMENT,
  `numeroFactura` int(11) NOT NULL,
  `codVendedor` int(11) NOT NULL,
  `codCliente` int(11) NOT NULL,
  `totalVenta` decimal(10,2) NOT NULL,
  `fechaRegistro` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`codFactura`),
  KEY `FK_factura_vendedor` (`codVendedor`),
  KEY `FK_factura_cliente` (`codCliente`),
  CONSTRAINT `FK_factura_cliente` FOREIGN KEY (`codCliente`) REFERENCES `cliente` (`codCliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_factura_vendedor` FOREIGN KEY (`codVendedor`) REFERENCES `vendedor` (`codVendedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=71 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `factura` */

insert  into `factura`(`codFactura`,`numeroFactura`,`codVendedor`,`codCliente`,`totalVenta`,`fechaRegistro`) values (39,1,2,2,'65.50','2015-11-28 16:35:57'),(40,2,2,3,'546.45','2015-11-28 16:35:57'),(41,3,2,2,'19.65','2015-11-28 16:35:57'),(42,4,2,2,'32.75','2015-11-28 16:35:57'),(43,5,2,3,'1284.25','2015-11-28 16:35:57'),(44,6,2,3,'13.10','2015-11-28 16:35:57'),(45,7,1,2,'19.65','2015-11-28 16:35:57'),(46,8,1,3,'250.30','2015-11-28 16:35:57'),(47,9,2,2,'6.55','2015-11-28 16:35:57'),(48,10,1,2,'263.40','2015-11-28 16:35:57'),(49,11,2,3,'770.55','2015-11-28 16:35:57'),(50,12,1,2,'6.55','2015-11-28 16:35:57'),(51,13,1,3,'250.30','2015-11-28 16:35:57'),(52,14,1,2,'250.30','2015-11-28 16:35:57'),(53,15,2,3,'263.40','2015-11-28 16:35:57'),(54,16,2,2,'6.55','2015-11-28 16:35:57'),(55,17,2,3,'250.30','2015-11-28 16:35:57'),(56,18,2,2,'764.00','2015-11-28 16:35:57'),(57,19,2,3,'250.30','2015-11-28 16:35:57'),(58,20,2,4,'150.00','2015-11-28 16:35:57'),(59,21,2,5,'40.00','2015-11-28 16:35:57'),(60,22,2,3,'225.00','2015-11-28 16:35:57'),(61,23,1,2,'41.00','2015-11-28 16:35:57'),(62,24,1,5,'730.60','2015-11-28 16:35:57'),(63,25,1,3,'54.10','2015-11-28 16:35:57'),(64,26,2,5,'375.00','2015-11-28 16:35:57'),(65,27,2,4,'40.00','2015-11-28 16:35:57'),(66,28,2,2,'640.60','2015-11-28 16:35:57'),(67,29,2,2,'900.60','2015-11-28 16:35:57'),(68,30,2,4,'208.10','2015-11-28 16:35:57'),(69,31,2,4,'500.00','2015-11-28 16:35:57'),(70,32,1,2,'500.00','2015-11-28 16:35:57');

/*Table structure for table `producto` */

DROP TABLE IF EXISTS `producto`;

CREATE TABLE `producto` (
  `codProducto` int(11) NOT NULL AUTO_INCREMENT,
  `nombreProducto` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `precioVenta` decimal(10,2) NOT NULL,
  `stockMinimo` int(11) NOT NULL,
  `stockActual` int(11) NOT NULL,
  `codBarra` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`codProducto`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `producto` */

insert  into `producto`(`codProducto`,`nombreProducto`,`precioVenta`,`stockMinimo`,`stockActual`,`codBarra`) values (1,'TECLADO USB','6.55',10,46,'10101010'),(3,'PANTALLA LED 24 °','250.30',10,94,'10101012'),(4,'CASE ATX','20.50',10,46,'10101013'),(5,'LAMPARA CF','75.00',5,5,'10101014'),(6,'MEMORIA RAM DDR3','20.00',15,39,'10101015'),(7,'DICO DURO 300GB','50.00',25,126,'10101016');

/*Table structure for table `usuario` */

DROP TABLE IF EXISTS `usuario`;

CREATE TABLE `usuario` (
  `codUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombreUsuario` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_spanish_ci NOT NULL,
  `codVendedor` int(11) NOT NULL,
  PRIMARY KEY (`codUsuario`),
  KEY `FK_usuario_vendedor` (`codVendedor`),
  CONSTRAINT `FK_usuario_vendedor` FOREIGN KEY (`codVendedor`) REFERENCES `vendedor` (`codVendedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `usuario` */

insert  into `usuario`(`codUsuario`,`nombreUsuario`,`password`,`codVendedor`) values (1,'BCAGUILAR','3627909a29c31381a071ec27f7c9ca97726182aed29a7ddd2e54353322cfb30abb9e3a6df2ac2c20fe23436311d678564d0c8d305930575f60e2d3d048184d79',1),(2,'PMLEMUS','878ae65a92e86cac011a570d4c30a7eaec442b85ce8eca0c2952b5e3cc0628c2e79d889ad4d5c7c626986d452dd86374b6ffaa7cd8b67665bef2289a5c70b0a1',2),(3,'CEAGUIRRE','e16d6b316f3bef1794c548b7a98b969a6aacb02f6ae5138efc1c443ae6643a6a77d92a0e33e382d6cbb7758f9ab25ab0f97504554d1904620a41fed463796fc2',3);

/*Table structure for table `vendedor` */

DROP TABLE IF EXISTS `vendedor`;

CREATE TABLE `vendedor` (
  `codVendedor` int(11) NOT NULL AUTO_INCREMENT,
  `nombres` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `apellidos` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `dui` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `celular` varchar(8) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` varchar(150) COLLATE utf8_spanish_ci NOT NULL,
  PRIMARY KEY (`codVendedor`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `vendedor` */

insert  into `vendedor`(`codVendedor`,`nombres`,`apellidos`,`dui`,`celular`,`direccion`) values (1,'BLANCA CAROLINA','AGUILAR','012451454','78455124','SAN SALVADOR'),(2,'PEDRO MIGUEL','LEMUS ROJAS','45126398','78451253','SAN SALVADOR'),(3,'CECILIA','AGUIRRE','15231315','7894566','SAN MIGUEL');

/* Trigger structure for table `detallefactura` */

DELIMITER $$

/*!50003 DROP TRIGGER*//*!50032 IF EXISTS */ /*!50003 `trgActualizarStock` */$$

/*!50003 CREATE */ /*!50017 DEFINER = 'root'@'localhost' */ /*!50003 TRIGGER `trgActualizarStock` BEFORE INSERT ON `detallefactura` FOR EACH ROW BEGIN
SET @stockAntiguo =(SELECT stockActual FROM producto WHERE codProducto=new.codProducto);
UPDATE	producto
SET stockActual=@stockAntiguo-new.cantidad where codProducto=new.codProducto;
end */$$


DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
