
package sys.imp;

import org.hibernate.Query;
import org.hibernate.Session;
import sys.dao.facturaDao;
import sys.model.Factura;


public class facturaDaoImp implements facturaDao{

    @Override
    public Factura obtenerUltimoRegistro(Session session) throws Exception {
        String hql = "FROM Factura ORDER BY codFactura DESC";
        
        //Obtiene el máximo resultado sólo uno
        Query q = session.createQuery(hql).setMaxResults(1);
        return (Factura) q.uniqueResult();
    }

    @Override
    public Long obtenerTotalRegistrosEnFactura(Session session) {
         String hql = "SELECT COUNT(*) FROM Factura";
         Query q = session.createQuery(hql);
         return (Long) q.uniqueResult();
    }

    @Override
    public boolean guardarVentaFactura(Session session, Factura factura) throws Exception {
        session.save(factura);
        return true;
    }
    
}
