package sys.model;
// Generated 30-mar-2016 21:16:11 by Hibernate Tools 4.3.1


import java.math.BigDecimal;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;

/**
 * Factura generated by hbm2java
 */
public class Factura  implements java.io.Serializable {


     private Integer codFactura;
     private Cliente cliente;
     private Vendedor vendedor;
     private int numeroFactura;
     private BigDecimal totalventa;
     private Date fechaRegistro;
     private Set<Detallefactura> detallefacturas = new HashSet<Detallefactura>(0);

    public Factura() {
    }

	
    public Factura(Cliente cliente, Vendedor vendedor, int numeroFactura, BigDecimal totalventa, Date fechaRegistro) {
        this.cliente = cliente;
        this.vendedor = vendedor;
        this.numeroFactura = numeroFactura;
        this.totalventa = totalventa;
        this.fechaRegistro = fechaRegistro;
    }
    public Factura(Cliente cliente, Vendedor vendedor, int numeroFactura, BigDecimal totalventa, Date fechaRegistro, Set<Detallefactura> detallefacturas) {
       this.cliente = cliente;
       this.vendedor = vendedor;
       this.numeroFactura = numeroFactura;
       this.totalventa = totalventa;
       this.fechaRegistro = fechaRegistro;
       this.detallefacturas = detallefacturas;
    }
   
    public Integer getCodFactura() {
        return this.codFactura;
    }
    
    public void setCodFactura(Integer codFactura) {
        this.codFactura = codFactura;
    }
    public Cliente getCliente() {
        return this.cliente;
    }
    
    public void setCliente(Cliente cliente) {
        this.cliente = cliente;
    }
    public Vendedor getVendedor() {
        return this.vendedor;
    }
    
    public void setVendedor(Vendedor vendedor) {
        this.vendedor = vendedor;
    }
    public int getNumeroFactura() {
        return this.numeroFactura;
    }
    
    public void setNumeroFactura(int numeroFactura) {
        this.numeroFactura = numeroFactura;
    }
    public BigDecimal getTotalventa() {
        return this.totalventa;
    }
    
    public void setTotalventa(BigDecimal totalventa) {
        this.totalventa = totalventa;
    }
    public Date getFechaRegistro() {
        return this.fechaRegistro;
    }
    
    public void setFechaRegistro(Date fechaRegistro) {
        this.fechaRegistro = fechaRegistro;
    }
    public Set<Detallefactura> getDetallefacturas() {
        return this.detallefacturas;
    }
    
    public void setDetallefacturas(Set<Detallefactura> detallefacturas) {
        this.detallefacturas = detallefacturas;
    }




}


