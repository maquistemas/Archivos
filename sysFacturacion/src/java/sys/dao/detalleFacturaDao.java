
package sys.dao;

import org.hibernate.Session;
import sys.model.Detallefactura;


public interface detalleFacturaDao {
    
       //metodo para guardar el registro en la tabla detalleFactura en la base de datos
    public boolean guardarVentaDetalleFactura(Session session, Detallefactura detallefactura)throws Exception;
    
    
    
}
