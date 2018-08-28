
package sys.dao;

import java.util.List;
import org.hibernate.Session;
import sys.model.Cliente;


public interface clienteDao {
    
    public List<Cliente> listarClientes();
    public void newCliente(Cliente cliente);
    public void updateCliente(Cliente cliente);
    public void deleteCliente(Cliente cliente);
    
    
    //Este metodo se usara en la facturaBean
    public Cliente obtenerClientePorCodigo(Session sesion, Integer codCliente) throws Exception;
}
