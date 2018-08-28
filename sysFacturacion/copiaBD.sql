/*
SQLyog Enterprise - MySQL GUI v8.05 
MySQL - 5.5.13 : Database - facturacion
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/`facturacion` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci */;

USE `facturacion`;



DROP TABLE IF EXISTS `usuario`;

CREATE TABLE `usuario` (
  `codUsuario` int(11) NOT NULL AUTO_INCREMENT,
  `nombreUsuario` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_spanish_ci NOT NULL,
  `codVendedor` int(11) NOT NULL,
  PRIMARY KEY (`codUsuario`),
  KEY `FK_usuario_vendedor` (`codVendedor`),
  CONSTRAINT `FK_usuario_vendedor` FOREIGN KEY (`codVendedor`) REFERENCES `vendedor` (`codVendedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;



insert into usuario values(null,'john','123',1);
insert into usuario values(null,'william','123',2);





/*Table structure for table `cliente` */

DROP TABLE IF EXISTS `cliente`;

CREATE TABLE `cliente` (
  `codCliente` int(11) NOT NULL AUTO_INCREMENT,
  `nombres` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `apellidos` varchar(40) COLLATE utf8_spanish_ci NOT NULL,
  `direccion` varchar(150) COLLATE utf8_spanish_ci DEFAULT NULL,
  PRIMARY KEY (`codCliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `cliente` */

/*Table structure for table `detallefactura` */


/*
DROP TABLE IF EXISTS `detallefactura`;

CREATE TABLE `detallefactura` (
  `codDetalle` int(11) NOT NULL AUTO_INCREMENT,
  `codFactura` int(11) NOT NULL,
  `codProducto` int(11) NOT NULL,
  `precioVenta` decimal(10,0) NOT NULL,
  `cantidad` int(11) NOT NULL,
  PRIMARY KEY (`codDetalle`),
  KEY `FK_detallefactura_factura` (`codFactura`),
  KEY `FK_detallefactura_producto` (`codProducto`),
  CONSTRAINT `FK_detallefactura_producto` FOREIGN KEY (`codProducto`) REFERENCES `producto` (`codProducto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_detallefactura_factura` FOREIGN KEY (`codFactura`) REFERENCES `factura` (`codFactura`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

*/




DROP TABLE IF EXISTS `detallefactura`;
CREATE TABLE `detallefactura` (
  `codDetalle` int(11) NOT NULL AUTO_INCREMENT,
  `codFactura` int(11) NOT NULL,
  `codProducto` int(11) NOT NULL,
  `codBarra` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `nombreProducto` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `cantidad` int(11) NOT NULL,
  `precioVenta` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  PRIMARY KEY (`codDetalle`),
  KEY `FK_detallefactura_factura` (`codFactura`),
  KEY `FK_detallefactura_producto` (`codProducto`),
  CONSTRAINT `FK_detallefactura_producto` FOREIGN KEY (`codProducto`) REFERENCES `producto` (`codProducto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_detallefactura_factura` FOREIGN KEY (`codFactura`) REFERENCES `factura` (`codFactura`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;










/*Data for the table `detallefactura` */

/*Table structure for table `factura` */

/*

DROP TABLE IF EXISTS `factura`;

CREATE TABLE `factura` (
  `codFactura` int(11) NOT NULL AUTO_INCREMENT,
  `numeroFactura` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `codVendedor` int(11) NOT NULL,
  `codCliente` int(11) NOT NULL,
  `totalVenta` decimal(10,0) NOT NULL,
  `fechaRegistro` datetime NOT NULL,
  PRIMARY KEY (`codFactura`),
  KEY `FK_factura_vendedor` (`codVendedor`),
  KEY `FK_factura_cliente` (`codCliente`),
  CONSTRAINT `FK_factura_cliente` FOREIGN KEY (`codCliente`) REFERENCES `cliente` (`codCliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_factura_vendedor` FOREIGN KEY (`codVendedor`) REFERENCES `vendedor` (`codVendedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `factura` */


*/


DROP TABLE IF EXISTS `factura`;

CREATE TABLE `factura` (
  `codFactura` int(11) NOT NULL AUTO_INCREMENT,
  `numeroFactura` int(10) NOT NULL,
  `codVendedor` int(11) NOT NULL,
  `codCliente` int(11) NOT NULL,
  `totalVenta` decimal(10,2) NOT NULL,
  `fechaRegistro` datetime NOT NULL,
  PRIMARY KEY (`codFactura`),
  KEY `FK_factura_vendedor` (`codVendedor`),
  KEY `FK_factura_cliente` (`codCliente`),
  CONSTRAINT `FK_factura_cliente` FOREIGN KEY (`codCliente`) REFERENCES `cliente` (`codCliente`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_factura_vendedor` FOREIGN KEY (`codVendedor`) REFERENCES `vendedor` (`codVendedor`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=I

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `producto` 
alter table producto
  modify precioVenta decimal(10,2) NOT NULL;

*/

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `vendedor` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
