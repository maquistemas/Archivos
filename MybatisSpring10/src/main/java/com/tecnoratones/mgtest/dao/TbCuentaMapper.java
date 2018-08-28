package com.tecnoratones.mgtest.dao;

import com.tecnoratones.mgtest.model.TbCuenta;

import java.math.BigDecimal;
import java.util.List;

public interface TbCuentaMapper {
    int deleteByPrimaryKey(BigDecimal CUENTA);

    int insert(TbCuenta record);

    int insertSelective(TbCuenta record);

    TbCuenta selectByPrimaryKey(BigDecimal CUENTA);

    int updateByPrimaryKeySelective(TbCuenta record);

    int updateByPrimaryKey(TbCuenta record);
    
    
    
    
    
    
    
    
    List<TbCuenta>listaCuenta();
    
    
    
}