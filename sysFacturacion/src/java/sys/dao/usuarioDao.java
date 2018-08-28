
package sys.dao;

import sys.model.Usuario;


public interface usuarioDao {
    
    public Usuario obtenerdatosPorUsuario(Usuario usuario);
    
    public Usuario login(Usuario usuario);
    
    
    
    
}
