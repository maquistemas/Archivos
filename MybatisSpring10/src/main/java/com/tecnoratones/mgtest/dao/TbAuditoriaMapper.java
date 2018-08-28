package com.tecnoratones.mgtest.dao;

import com.tecnoratones.mgtest.model.TbAuditoria;

import java.math.BigDecimal;
import java.util.List;

public interface TbAuditoriaMapper {
    int deleteByPrimaryKey(BigDecimal AUDITORIA_ID);

    int insert(TbAuditoria record);

    int insertSelective(TbAuditoria record);

    TbAuditoria selectByPrimaryKey(BigDecimal AUDITORIA_ID);

    int updateByPrimaryKeySelective(TbAuditoria record);

    int updateByPrimaryKey(TbAuditoria record);
    
    
    
    public List<TbAuditoria> audiView();
    
    public List<TbAuditoria>listaAudi();
    
    
    
}