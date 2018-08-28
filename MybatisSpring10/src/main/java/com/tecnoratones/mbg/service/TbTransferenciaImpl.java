package com.tecnoratones.mbg.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.tecnoratones.mgtest.dao.TbTransferenciaMapper;

@Service
public class TbTransferenciaImpl implements TbTransferenciaService {
	@Autowired
	TbTransferenciaMapper transferenciaMapper;

	@Override
	public void transPack(Integer USUARIO_ID, Integer CUENTA_ORIGEN,
			Integer CUENTA_DESTINO, Integer MONTO) throws Exception {
		transferenciaMapper.transPack(USUARIO_ID, CUENTA_ORIGEN, CUENTA_DESTINO, MONTO);
	}

	@Override
	public void extornoPack(Integer TRANSF_ID, Integer USUARIO_ID) throws Exception {
		transferenciaMapper.extornoPack(TRANSF_ID, USUARIO_ID);
	}

}
