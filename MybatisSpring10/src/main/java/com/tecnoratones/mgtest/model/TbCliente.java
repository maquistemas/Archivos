package com.tecnoratones.mgtest.model;

import java.math.BigDecimal;

public class TbCliente {
    private BigDecimal CLIENTE_CUENTA;

    private String CLIENTE_NOMBRE;

    private String CLIENTE_APELLIDO;

    private BigDecimal CLIENTE_USUARIO_ID;

    public BigDecimal getCLIENTE_CUENTA() {
        return CLIENTE_CUENTA;
    }

    public void setCLIENTE_CUENTA(BigDecimal CLIENTE_CUENTA) {
        this.CLIENTE_CUENTA = CLIENTE_CUENTA;
    }

    public String getCLIENTE_NOMBRE() {
        return CLIENTE_NOMBRE;
    }

    public void setCLIENTE_NOMBRE(String CLIENTE_NOMBRE) {
        this.CLIENTE_NOMBRE = CLIENTE_NOMBRE;
    }

    public String getCLIENTE_APELLIDO() {
        return CLIENTE_APELLIDO;
    }

    public void setCLIENTE_APELLIDO(String CLIENTE_APELLIDO) {
        this.CLIENTE_APELLIDO = CLIENTE_APELLIDO;
    }

    public BigDecimal getCLIENTE_USUARIO_ID() {
        return CLIENTE_USUARIO_ID;
    }

    public void setCLIENTE_USUARIO_ID(BigDecimal CLIENTE_USUARIO_ID) {
        this.CLIENTE_USUARIO_ID = CLIENTE_USUARIO_ID;
    }
}