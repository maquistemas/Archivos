package sys.bean;

import java.awt.event.ActionEvent;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.servlet.http.HttpSession;
import org.primefaces.context.RequestContext;
import sys.dao.usuarioDao;
import sys.imp.usuarioDaoImp;
import sys.model.Usuario;

@ManagedBean
@SessionScoped
public class loginBean {

    private Usuario usuario;
    
    private String nombreUsuario;
    private String password;

      public loginBean() {
          this.usuario = new Usuario();
    }

   
      
      public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario usuario) {
        this.usuario = usuario;
    }
          
    public String getNombreUsuario() {
        return nombreUsuario;
    }

    public void setNombreUsuario(String nombreUsuario) {
        this.nombreUsuario = nombreUsuario;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void login(ActionEvent event) {
        RequestContext context = RequestContext.getCurrentInstance();
        FacesMessage message = null;
        boolean loggedIn = false;
        String ruta ="";
        
        usuarioDao uDao = new usuarioDaoImp();
        this.usuario = uDao.login(this.usuario);

        if (this.usuario != null) {
           
            //Esta linea es para usarla en filtroUrl Object usuario = session.getAtribute("usuario");
            FacesContext.getCurrentInstance().getExternalContext().getSessionMap().put("usuario", this.usuario.getNombreUsuario());
            
            loggedIn = true;
            message = new FacesMessage(FacesMessage.SEVERITY_INFO, "Bienvenid@", this.usuario.getNombreUsuario());
            ruta = "/sysFacturacion/faces/views/Bienvenido.xhtml";
        } else {
            loggedIn = false;
            message = new FacesMessage(FacesMessage.SEVERITY_WARN, "Error de acceso", "Usuario o Password es incorrecto");
            this.usuario = new Usuario();
        }

        FacesContext.getCurrentInstance().addMessage(null, message);
        context.addCallbackParam("loggedIn", loggedIn);
         context.addCallbackParam("ruta", ruta);
    }
    
    
    //Metodo ara cerrar la session
    public String cerrarSession(){
        this.nombreUsuario = null;
        this.password = null;
        
        HttpSession httpSession = (HttpSession) FacesContext.getCurrentInstance().getExternalContext().getSession(false);
        httpSession.invalidate();//para borrar la session
        return "/login";
    }
    

}
