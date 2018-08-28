package com.tecnoratones.mgtest.dao;

import com.tecnoratones.mgtest.model.TbCliente;
import java.math.BigDecimal;

public interface TbClienteMapper {
    int deleteByPrimaryKey(BigDecimal CLIENTE_CUENTA);

    int insert(TbCliente record);

    int insertSelective(TbCliente record);

    TbCliente selectByPrimaryKey(BigDecimal CLIENTE_CUENTA);

    int updateByPrimaryKeySelective(TbCliente record);

    int updateByPrimaryKey(TbCliente record);
    
    
    
    int insertPack(String nombre, String apellido, Integer user);
    
    
    
    
}