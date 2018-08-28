package com.tecnoratones.mgtest.dao;

import com.tecnoratones.mgtest.model.TbUsuario;

import java.math.BigDecimal;


public interface TbUsuarioMapper {
    int deleteByPrimaryKey(BigDecimal USUARIO_ID);

    int insert(TbUsuario record);

    int insertSelective(TbUsuario record);

    TbUsuario selectByPrimaryKey(BigDecimal USUARIO_ID);

    int updateByPrimaryKeySelective(TbUsuario record);

    int updateByPrimaryKey(TbUsuario record);
    
    
    TbUsuario logu(String USUARIO_NAME, BigDecimal USUARIO_PASSWORD);
    
   
   
    
}