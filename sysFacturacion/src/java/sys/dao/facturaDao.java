
package sys.dao;

import org.hibernate.Session;
import sys.model.Factura;


public interface facturaDao {
    
    //obtener el último registro de la tabla factura de la BD.
    public Factura obtenerUltimoRegistro(Session session) throws Exception;
    
    //Averiguar si la tabla factura tiene registros
    public Long obtenerTotalRegistrosEnFactura(Session session);
    
    //metodo para guardar el registro en la tabla factura en la base de datos
    public boolean guardarVentaFactura(Session session, Factura factura)throws Exception;
    
}
