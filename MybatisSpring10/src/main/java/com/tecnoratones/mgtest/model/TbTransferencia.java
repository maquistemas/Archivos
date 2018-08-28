package com.tecnoratones.mgtest.model;

import java.math.BigDecimal;

public class TbTransferencia {
    private BigDecimal TRANSFERENCIA_ID;

    private BigDecimal TRANSFERENCIA_USUARIO_ID;

    private BigDecimal TRANSFERENCIA_CUENTA_ORIGEN;

    private BigDecimal TRANSFERENCIA_CUENTA_DESTINO;

    private Short TRANSFERENCIA_MONTO;

    private String TRANSFERENCIA_TIPO;

    public BigDecimal getTRANSFERENCIA_ID() {
        return TRANSFERENCIA_ID;
    }

    public void setTRANSFERENCIA_ID(BigDecimal TRANSFERENCIA_ID) {
        this.TRANSFERENCIA_ID = TRANSFERENCIA_ID;
    }

    public BigDecimal getTRANSFERENCIA_USUARIO_ID() {
        return TRANSFERENCIA_USUARIO_ID;
    }

    public void setTRANSFERENCIA_USUARIO_ID(BigDecimal TRANSFERENCIA_USUARIO_ID) {
        this.TRANSFERENCIA_USUARIO_ID = TRANSFERENCIA_USUARIO_ID;
    }

    public BigDecimal getTRANSFERENCIA_CUENTA_ORIGEN() {
        return TRANSFERENCIA_CUENTA_ORIGEN;
    }

    public void setTRANSFERENCIA_CUENTA_ORIGEN(BigDecimal TRANSFERENCIA_CUENTA_ORIGEN) {
        this.TRANSFERENCIA_CUENTA_ORIGEN = TRANSFERENCIA_CUENTA_ORIGEN;
    }

    public BigDecimal getTRANSFERENCIA_CUENTA_DESTINO() {
        return TRANSFERENCIA_CUENTA_DESTINO;
    }

    public void setTRANSFERENCIA_CUENTA_DESTINO(BigDecimal TRANSFERENCIA_CUENTA_DESTINO) {
        this.TRANSFERENCIA_CUENTA_DESTINO = TRANSFERENCIA_CUENTA_DESTINO;
    }

    public Short getTRANSFERENCIA_MONTO() {
        return TRANSFERENCIA_MONTO;
    }

    public void setTRANSFERENCIA_MONTO(Short TRANSFERENCIA_MONTO) {
        this.TRANSFERENCIA_MONTO = TRANSFERENCIA_MONTO;
    }

    public String getTRANSFERENCIA_TIPO() {
        return TRANSFERENCIA_TIPO;
    }

    public void setTRANSFERENCIA_TIPO(String TRANSFERENCIA_TIPO) {
        this.TRANSFERENCIA_TIPO = TRANSFERENCIA_TIPO;
    }
}