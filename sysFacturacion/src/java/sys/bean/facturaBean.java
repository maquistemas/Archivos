package sys.bean;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ManagedProperty;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.servlet.ServletContext;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.primefaces.context.RequestContext;
import org.primefaces.event.RowEditEvent;
import sys.clasesAuxiliares.reporteFactura;
import sys.dao.clienteDao;
import sys.dao.detalleFacturaDao;
import sys.dao.facturaDao;
import sys.dao.productoDao;
import sys.imp.clienteDaoImp;
import sys.imp.detalleFacturaDaoImp;
import sys.imp.facturaDaoImp;
import sys.imp.productoDaoImp;
import sys.model.Cliente;
import sys.model.Detallefactura;
import sys.model.Factura;
//import sys.dao.Detallefactura;
import sys.model.Producto;
import sys.model.Vendedor;
import sys.util.HibernateUtil;

@ManagedBean
@ViewScoped
public class facturaBean {

    Session session = null;
    Transaction transaction = null;
    
    //Acceder al loginBean para obtener a la session del vendedor
    @ManagedProperty("#{loginBean}")
    private loginBean lBean;

    private Cliente cliente;
    private Integer codigoCliente;

    private Producto producto;
    private String codigoBarra;

    private List<Detallefactura> listaDetalleFactura;

    //Se cambia a String para validaciones
    //private Integer cantidadProducto;
    private String cantidadProducto;

    private String productoSeleccionado;
    private Factura factura;

    //Se cambia a String para validaciones
    //private Integer cantidadProducto2;
    private String cantidadProducto2;
    
    private Long numeroFactura;
    
    private BigDecimal totalVentaFactura;
    
    private Vendedor vendedor;
    
    

    public facturaBean() {
        this.factura = new Factura();
        this.listaDetalleFactura = new ArrayList<>();
        this.vendedor = new Vendedor();
        this.cliente = new Cliente();
    }

    public Cliente getCliente() {
        return cliente;
    }

    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }

    public Integer getCodigoCliente() {
        return codigoCliente;
    }

    public void setCodigoCliente(Integer codigoCliente) {
        this.codigoCliente = codigoCliente;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public String getCodigoBarra() {
        return codigoBarra;
    }

    public void setCodigoBarra(String codigoBarra) {
        this.codigoBarra = codigoBarra;
    }

    public List<Detallefactura> getListaDetalleFactura() {
        return listaDetalleFactura;
    }

    public void setListaDetalleFactura(List<Detallefactura> listaDetalleFactura) {
        this.listaDetalleFactura = listaDetalleFactura;
    }

    public String getCantidadProducto() {
        return cantidadProducto;
    }

    public void setCantidadProducto(String cantidadProducto) {
        this.cantidadProducto = cantidadProducto;
    }

    public String getProductoSeleccionado() {
        return productoSeleccionado;
    }

    public void setProductoSeleccionado(String productoSeleccionado) {
        this.productoSeleccionado = productoSeleccionado;
    }

    public Factura getFactura() {
        return factura;
    }

    public void setFactura(Factura factura) {
        this.factura = factura;
    }

    public String getCantidadProducto2() {
        return cantidadProducto2;
    }

    public void setCantidadProducto2(String cantidadProducto2) {
        this.cantidadProducto2 = cantidadProducto2;
    }

    public Long getNumeroFactura() {
        return numeroFactura;
    }

    public void setNumeroFactura(Long numeroFactura) {
        this.numeroFactura = numeroFactura;
    }

    public BigDecimal getTotalVentaFactura() {
        return totalVentaFactura;
    }

    public void setTotalVentaFactura(BigDecimal totalVentaFactura) {
        this.totalVentaFactura = totalVentaFactura;
    }

    public Vendedor getVendedor() {
        return vendedor;
    }

    public void setVendedor(Vendedor vendedor) {
        this.vendedor = vendedor;
    }

    public loginBean getlBean() {
        return lBean;
    }

    public void setlBean(loginBean lBean) {
        this.lBean = lBean;
    }
    
    
    
    
    

    //Metodo para agregar los datos de los clientes por medio del dialogo dialogClientes
    public void agregarDatosCliente(Integer codCliente) {
        this.session = null;
        this.transaction = null;

        try {
            this.session = HibernateUtil.getSessionFactory().openSession();
            clienteDao cDao = new clienteDaoImp();
            this.transaction = this.session.beginTransaction();

            //Obtener los datos del cliente en variale objeto cliente segun codigo de cliente
            this.cliente = cDao.obtenerClientePorCodigo(this.session, codCliente);
            this.transaction.commit();
            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Correcto", "Datos del cliente Agregado"));
        } catch (Exception e) {
            if (this.transaction != null) {
                System.out.println(e.getMessage());
                transaction.rollback();
            }
        } finally {
            if (this.session != null) {
                this.session.close();
            }
        }

    }

    //Metodo para agregar los datos del cliente busado por codCliente
    public void agregarDatosCliente2() {
        this.session = null;
        this.transaction = null;

        //si es null el cursor se mantienen en el mismo elemento
        try {
            if (this.codigoCliente == null) {
                return;
            }

            this.session = HibernateUtil.getSessionFactory().openSession();
            clienteDao cDao = new clienteDaoImp();
            this.transaction = this.session.beginTransaction();

            //Obtener los datos del cliente en variale objeto cliente segun codigo de cliente
            this.cliente = cDao.obtenerClientePorCodigo(this.session, this.codigoCliente);

            if (this.cliente != null) {
                //limpiamos variable
                this.codigoCliente = null;
                FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Correcto", "Datos del cliente Agregado"));
            } else {
                this.codigoCliente = null;
                FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Cliente No encontrados"));
            }

            this.transaction.commit();

        } catch (Exception e) {
            if (this.transaction != null) {
                System.out.println(e.getMessage());
                transaction.rollback();
            }
        } finally {
            if (this.session != null) {
                this.session.close();
            }
        }

    }

    //Metodo para solicitar la cantidad de producto a vender
    public void pedirCantidadProducto(String codBarra) {
        this.productoSeleccionado = codBarra;
    }

    //Metodo para agregar los datos de los productos por medio del dialogProductos
    public void agregarDatosProducto() {
        this.session = null;
        this.transaction = null;

        try {

            //validacion
            if (!(this.cantidadProducto.matches("[0-9]*")) || this.cantidadProducto.equals("0") || this.cantidadProducto.equals("")) {

                FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "La cantidad es incorrecta"));
                //limpiamos la variable
                this.cantidadProducto = "";

            } else {

                this.session = HibernateUtil.getSessionFactory().openSession();
                productoDao pDao = new productoDaoImp();
                this.transaction = this.session.beginTransaction();

                //Obtener los datos del producto en variale objeto producto segun codigo de barra
                this.producto = pDao.obtenerProductoPorCodBarra(this.session, this.productoSeleccionado);

                this.listaDetalleFactura.add(new Detallefactura(null, null, this.producto.getCodBarra(),
                        this.producto.getNombreProducto(), Integer.parseInt(this.cantidadProducto), this.producto.getPrecioVenta(),
                        BigDecimal.valueOf(Integer.parseInt(this.cantidadProducto) * this.producto.getPrecioVenta().floatValue())));

                this.transaction.commit();
                FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Correcto", "Producto Agregado al Detalle"));

                this.cantidadProducto = "";

                //llamada al metodo calcular totalFacturaVenta()
                //this.totalFacturaVenta();
                this.calcularTotalFactura();
            }

        } catch (Exception e) {
            if (this.transaction != null) {
                System.out.println(e.getMessage());
                transaction.rollback();
            }
        } finally {
            if (this.session != null) {
                this.session.close();
            }
        }

    }

    //Metodo Para Mostrar el dialogCantidadProducto2
    public void mostrarCantidadProducto2() {

        this.session = null;
        this.transaction = null;

        //si esta vacío el cursor se mantienen en el mismo elemento
        try {
            if (this.codigoBarra.equals("")) {
                return;
            }

            this.session = HibernateUtil.getSessionFactory().openSession();
            productoDao pDao = new productoDaoImp();
            this.transaction = this.session.beginTransaction();

            //Obtener los datos del producto en variale objeto producto segun codigo de barra
            this.producto = pDao.obtenerProductoPorCodBarra(this.session, codigoBarra);

            if (this.producto != null) {

                //Solicitar mostrar el dialogCantidadProducto2
                RequestContext context = RequestContext.getCurrentInstance();
                context.execute("PF('dialogCantidadProducto2').show();");

                this.codigoBarra = null;

            } else {
                this.codigoBarra = null;
                FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "Producto No encontrados"));
            }

            this.transaction.commit();

        } catch (Exception e) {
            if (this.transaction != null) {
                System.out.println(e.getMessage());
                transaction.rollback();
            }
        } finally {
            if (this.session != null) {
                this.session.close();
            }
        }

    }

    //Metodo para agregar los datos del Producto busado por codBarra
    public void agregarDatosProducto2() {

        //validacion
        if (!(this.cantidadProducto2.matches("[0-9]*")) || this.cantidadProducto2.equals("0") || this.cantidadProducto2.equals("")) {

            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, "Error", "La cantidad es incorrecta"));
            //limpiamos la variable
            this.cantidadProducto2 = "";

        } else {

            this.listaDetalleFactura.add(new Detallefactura(null, null, this.producto.getCodBarra(),
                    this.producto.getNombreProducto(), Integer.parseInt(this.cantidadProducto2), this.producto.getPrecioVenta(),
                    BigDecimal.valueOf(Integer.parseInt(this.cantidadProducto2) * this.producto.getPrecioVenta().floatValue())));

            //limpiamos variable
            this.cantidadProducto2 = "";
            FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Correcto", "Producto Agregado al Detalle"));

            //Llamada al metodo calcularTotalFactura
            this.calcularTotalFactura();

        }

    }

    //Metodo para calcular el total a vender en la factura
    public void calcularTotalFactura() {
        //BigDecimal totalFacturaVenta = new BigDecimal("0");
        this.totalVentaFactura = new BigDecimal("0");

        try {
            for (Detallefactura item : listaDetalleFactura) {
                BigDecimal totalVentaPorProducto = item.getPrecioVenta().multiply(new BigDecimal(item.getCantidad()));
                item.setTotal(totalVentaPorProducto);
                totalVentaFactura = totalVentaFactura.add(totalVentaPorProducto);
            }

            //this.factura.setTotalVenta(totalVentaFactura);
            this.factura.setTotalventa(totalVentaFactura);

        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

    }
    
    
    
    
    //Metodo para quitar un producto de la factura
    public void quitarProductoDetalleFactura(String codBarra, Integer filaSeleccionada){
        try {
            int i=0;
            for (Detallefactura item : this.listaDetalleFactura) {
                if (item.getCodBarra().equals(codBarra) && filaSeleccionada.equals(i)) {
                    this.listaDetalleFactura.remove(i);
                    break;
                }
                i++;
            }
            
             FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_WARN, "Información", "Se retiró producto de la factura"));
             //Invocamos al metodo calcularTotalfactura para actualizar el total a vender
             this.calcularTotalFactura();
            
        } catch (Exception e) {
              FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_FATAL, "Error", e.getMessage()));
            
        }
    }
    
    
    
    
    
    //Metodos para editar la cantidad de productos en la tabla productosFactura
    public void onRowEdit(RowEditEvent event) {
        FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Información", "Se Modificó la cantidad"));
        //Invocar al metodo totalFactura para actualizar el total a vender
        this.calcularTotalFactura();
    }
     
    public void onRowCancel(RowEditEvent event) {
       FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Información", "No se hizo ningún cambio"));
         
    }
    
    
    
    
    //Metodo para generar el numero de factura
    public void numeracionFactura(){
        this.session = null;
        this.transaction = null;
        
        try {
            this.session = HibernateUtil.getSessionFactory().openSession();
            this.transaction = this.session.beginTransaction();
            facturaDao fDao = new facturaDaoImp();
            
            //verificar si hay registros en la tabla factura de la BD
            this.numeroFactura = fDao.obtenerTotalRegistrosEnFactura(this.session);
            
            if (this.numeroFactura <=0 || this.numeroFactura==null) {
                this.numeroFactura = Long.valueOf("1");
            }else{
                //recuperamos el ultimo registro que exista en la tabla factura de la BD
                this.factura = fDao.obtenerUltimoRegistro(this.session);
                this.numeroFactura = Long.valueOf(this.factura.getNumeroFactura()+1);
                
                //Limpiar la variable totalVentafactura
                this.totalVentaFactura = new BigDecimal("0");
                
            }
            this.transaction.commit();
            
        } catch (Exception e) {
            if (this.transaction!=null) {
                this.transaction.rollback();
            }
            System.out.println(e.getMessage());
        }finally{
            if (this.session!=null) {
                this.session.close();
            }
        }
        
    }
    
    
    
    
    
    //metodo para limpiar factura
    public void limpiarFactura(){
        this.cliente = new Cliente();
        this.factura = new Factura();
        this.listaDetalleFactura = new ArrayList<>();
        this.numeroFactura = null;
        this.totalVentaFactura = null;
        
        //invocar al método para desactivar controles en la factura
        this.disableButton();
        
    }
    
    
    
    
    //metodo para guardar venta
    public void guardarVenta(){
        this.session = null;
        this.transaction = null;
        this.vendedor.setCodVendedor(lBean.getUsuario().getVendedor().getCodVendedor()); //Debe mejorar para que no sea estatico
        
        try {
            this.session = HibernateUtil.getSessionFactory().openSession();
            productoDao pDao = new productoDaoImp();
            facturaDao fDao = new facturaDaoImp();
            detalleFacturaDao dfDao = new detalleFacturaDaoImp();
            
            this.transaction = this.session.beginTransaction();
            
            //datos para guardar en la tabla factura de la bd
            this.factura.setNumeroFactura(this.numeroFactura.intValue());
            this.factura.setCliente(this.cliente);
            this.factura.setVendedor(this.vendedor);
            
            this.factura.setFechaRegistro(new Date()); //Le agregue Fecha del sistema porque sino daba error
            
            //Hacemos el insert en la tabla factura de la BD
            fDao.guardarVentaFactura(this.session, this.factura);
            
            //Recuperar el ultimo registro de la tabla factura
            this.factura = fDao.obtenerUltimoRegistro(this.session);
            
            //Recorremos el ArrayList para guardar cada registro en la bd
            for (Detallefactura item : listaDetalleFactura) {
                this.producto = pDao.obtenerProductoPorCodBarra(this.session, item.getCodBarra());
                item.setFactura(this.factura);
                item.setProducto(this.producto);
                
                //Hacemos el insert en la tabla detalleFactura de la BD
                dfDao.guardarVentaDetalleFactura(this.session, item);
                
            }
            
            this.transaction.commit();
             FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_INFO, "Correcto", "Venta Registrada"));
             
             //limpiar factura
             this.limpiarFactura();
            
        } catch (Exception e) {
            
            System.out.println(e.getMessage());
            if (this.transaction!=null) {
                this.transaction.rollback();
            }
        }finally{
            if(this.session!=null){
                this.session.close();
            }
         
        }
        
        
        
    }
    
    
    
    
    
    
    //metodos para activar o desactivar los controles en la factura
    private boolean enabled;
    
    public boolean isEnabled() {
        return enabled;
    }
    
    public void enableButton(){
        enabled = true;
    }
    
    public void disableButton(){
        enabled = false;
    }
    
    
    
    
    //Recuperar fecha del sistema
    private String fechaSistema;
               
      public String getFechaSistema() {
          Calendar fecha = new GregorianCalendar();
          
          int anio = fecha.get(Calendar.YEAR);
          int mes = fecha.get(Calendar.MONTH);
          int dia = fecha.get(Calendar.DAY_OF_MONTH);
          
          this.fechaSistema = (dia + "/" + (mes+1) + "/" + anio);
          
        return fechaSistema;
    }

    
    
    
    
    
    
      
      

/*Para el bean, facturaBean*/ 
 //Metodo para invocar el reporte y enviarle los parametros
    public void verReporte() throws SQLException, ClassNotFoundException, InstantiationException, IllegalAccessException {

        this.vendedor.setCodVendedor(lBean.getUsuario().getVendedor().getCodVendedor());
        int cc = this.cliente.getCodCliente();
        int cv = this.vendedor.getCodVendedor();
        int cf = this.factura.getCodFactura() + 1;        

        //invocamos al metodo guardarVenta, para almacenar la venta en las tablas correspondientes
        this.guardarVenta();

        //Instancia hacia la clase reporteFactura        
        reporteFactura rFactura = new reporteFactura();

        FacesContext facesContext = FacesContext.getCurrentInstance();
        ServletContext servletContext = (ServletContext) facesContext.getExternalContext().getContext();
        String ruta = servletContext.getRealPath("/reportes/factura.jasper");

        System.out.println("Cliente: " + cc);
        System.out.println("Vendedor: " + cv);
        System.out.println("Factura: " + cf);

        rFactura.getReporte(ruta, cc, cv, cf);
        FacesContext.getCurrentInstance().responseComplete();
               
    }
    
    
    
    
    
    
    
    
    
    
    
 
    
    
    
    
    
    
    
    
    

    //Metodo para calcular el total a vender en la factura
//    public void totalFacturaVenta() {
//        BigDecimal totalFacturaVenta = new BigDecimal("0");
//
//        try {
//            for (Detallefactura item : listaDetalleFactura) {
//                BigDecimal totalVentaPorProducto = item.getPrecioVenta().multiply(new BigDecimal(item.getCantidad()));
//                item.setTotal(totalVentaPorProducto);
//                totalFacturaVenta = totalFacturaVenta.add(totalVentaPorProducto);
//            }
//
//            this.factura.setTotalVenta(totalFacturaVenta);
//
//        } catch (Exception e) {
//            System.out.println(e.getMessage());
//        }
//
//    }

  
    
    
    
    
    
    
    
    
    
    
    
}
