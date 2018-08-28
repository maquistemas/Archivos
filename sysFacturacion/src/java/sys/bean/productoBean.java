
package sys.bean;

import java.util.List;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import sys.dao.productoDao;
import sys.imp.productoDaoImp;
import sys.model.Producto;


@ManagedBean
@ViewScoped
public class productoBean {
    
    private List<Producto> listaProductos;
    private Producto producto;

    public productoBean() {
        producto = new Producto();
    }

   
    public void setListaProductos(List<Producto> listaProductos) {
        this.listaProductos = listaProductos;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }
    
    
     public List<Producto> getListaProductos() {
         productoDao vDao = new productoDaoImp();
         listaProductos = vDao.listarProductos();
        return listaProductos;
    }
    
    
    public void prepararNuevoProducto(){
        producto = new Producto();
    }
    
    public void nuevoProducto(){
        productoDao vDao = new productoDaoImp();
        vDao.newProducto(producto);
    }
    
     public void modificarProducto(){
        productoDao vDao = new productoDaoImp();
        vDao.updateProducto(producto);
        producto = new Producto();
    }
    
      public void eliminarProducto(){
        productoDao vDao = new productoDaoImp();
        vDao.deleteProducto(producto);
        producto = new Producto();
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}
