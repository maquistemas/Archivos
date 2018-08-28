
package sys.clasesAuxiliares;

import javax.faces.application.NavigationHandler;
import javax.faces.context.FacesContext;
import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import javax.servlet.http.HttpSession;


//Tambien crear dentro WEB-INF el faces config de javaServerFaces  faces-config.xml

public class filtroUrl implements PhaseListener{

    @Override
    public void afterPhase(PhaseEvent event) {
        FacesContext facesContext  = event.getFacesContext();
        
        //capturamos el nombre de la página actual
        String currentPage = facesContext.getViewRoot().getViewId();
        
        //Creamos una variable booleana para comprobar si es la pagina de login la que se capturo.
        boolean isPageLogin = currentPage.lastIndexOf("login.xhtml") > -1 ? true: false;
        
        HttpSession session = (HttpSession) facesContext.getExternalContext().getSession(true);
        
        /*Recuperamos un object del String que se guardo, para ellos se toma de la sesion al usuario 
        que se definio en el loginBean
        */
        Object usuario = session.getAttribute("usuario");
        
        if (!isPageLogin && usuario==null) {//si no es la pagina de logueo y el usuario es nulo, lo redirigimos a la pagina login.xhtml
            NavigationHandler nHandler = facesContext.getApplication().getNavigationHandler();
            nHandler.handleNavigation(facesContext, null, "/login.xhtml");
        }
    }

    @Override
    public void beforePhase(PhaseEvent event) {
    }

    @Override
    public PhaseId getPhaseId() {
        return PhaseId.RESTORE_VIEW;
    }
    
}
