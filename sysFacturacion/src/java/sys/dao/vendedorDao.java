
package sys.dao;

import java.util.List;
import sys.model.Vendedor;


public interface vendedorDao {
    
     public List<Vendedor> listarVendedors();
    public void newVendedor(Vendedor vendedor);
    public void updateVendedor(Vendedor vendedor);
    public void deleteVendedor(Vendedor vendedor);
    
    
}
