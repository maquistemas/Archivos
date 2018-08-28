package com.tecnoratones.mgtest.model;

import java.math.BigDecimal;

public class TbUsuario {
    private BigDecimal USUARIO_ID;

    private String USUARIO_NAME;

    private BigDecimal USUARIO_PASSWORD;

    public BigDecimal getUSUARIO_ID() {
        return USUARIO_ID;
    }

    public void setUSUARIO_ID(BigDecimal USUARIO_ID) {
        this.USUARIO_ID = USUARIO_ID;
    }

    public String getUSUARIO_NAME() {
        return USUARIO_NAME;
    }

    public void setUSUARIO_NAME(String USUARIO_NAME) {
        this.USUARIO_NAME = USUARIO_NAME;
    }

    public BigDecimal getUSUARIO_PASSWORD() {
        return USUARIO_PASSWORD;
    }

    public void setUSUARIO_PASSWORD(BigDecimal USUARIO_PASSWORD) {
        this.USUARIO_PASSWORD = USUARIO_PASSWORD;
    }
}