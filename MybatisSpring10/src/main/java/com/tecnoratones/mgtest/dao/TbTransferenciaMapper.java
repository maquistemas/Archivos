package com.tecnoratones.mgtest.dao;

import com.tecnoratones.mgtest.model.TbTransferencia;
import java.math.BigDecimal;

public interface TbTransferenciaMapper {
    int deleteByPrimaryKey(BigDecimal TRANSFERENCIA_ID);

    int insert(TbTransferencia record);

    int insertSelective(TbTransferencia record);

    TbTransferencia selectByPrimaryKey(BigDecimal TRANSFERENCIA_ID);

    int updateByPrimaryKeySelective(TbTransferencia record);

    int updateByPrimaryKey(TbTransferencia record);
    
    
    int transPack(Integer USUARIO_ID, Integer CUENTA_ORIGEN, Integer CUENTA_DESTINO, Integer MONTO);
    int extornoPack(Integer TRANSF_ID, Integer USUARIO_ID);
    
}