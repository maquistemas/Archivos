package com.tecnoratones.mgtest.model;

import java.math.BigDecimal;

public class TbCuenta {
    private BigDecimal CUENTA;

    private Short CUENTA_SALDO;

    public BigDecimal getCUENTA() {
        return CUENTA;
    }

    public void setCUENTA(BigDecimal CUENTA) {
        this.CUENTA = CUENTA;
    }

    public Short getCUENTA_SALDO() {
        return CUENTA_SALDO;
    }

    public void setCUENTA_SALDO(Short CUENTA_SALDO) {
        this.CUENTA_SALDO = CUENTA_SALDO;
    }
}