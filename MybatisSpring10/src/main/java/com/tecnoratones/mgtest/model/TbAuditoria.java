package com.tecnoratones.mgtest.model;

import java.math.BigDecimal;
import java.util.Date;

public class TbAuditoria {
    private BigDecimal AUDITORIA_ID;

    private Date AUDITORIA_FECHA;

    private String AUDITORIA_SCHEMA;

    private BigDecimal AUDITORIA_TRANSFERENCIA_ID;

    public BigDecimal getAUDITORIA_ID() {
        return AUDITORIA_ID;
    }

    public void setAUDITORIA_ID(BigDecimal AUDITORIA_ID) {
        this.AUDITORIA_ID = AUDITORIA_ID;
    }

    public Date getAUDITORIA_FECHA() {
        return AUDITORIA_FECHA;
    }

    public void setAUDITORIA_FECHA(Date AUDITORIA_FECHA) {
        this.AUDITORIA_FECHA = AUDITORIA_FECHA;
    }

    public String getAUDITORIA_SCHEMA() {
        return AUDITORIA_SCHEMA;
    }

    public void setAUDITORIA_SCHEMA(String AUDITORIA_SCHEMA) {
        this.AUDITORIA_SCHEMA = AUDITORIA_SCHEMA;
    }

    public BigDecimal getAUDITORIA_TRANSFERENCIA_ID() {
        return AUDITORIA_TRANSFERENCIA_ID;
    }

    public void setAUDITORIA_TRANSFERENCIA_ID(BigDecimal AUDITORIA_TRANSFERENCIA_ID) {
        this.AUDITORIA_TRANSFERENCIA_ID = AUDITORIA_TRANSFERENCIA_ID;
    }
}