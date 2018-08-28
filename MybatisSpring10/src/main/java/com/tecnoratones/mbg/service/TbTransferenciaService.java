package com.tecnoratones.mbg.service;

public interface TbTransferenciaService {
	
	public void transPack(Integer USUARIO_ID, Integer CUENTA_ORIGEN, Integer CUENTA_DESTINO, Integer MONTO) throws Exception;
	public void extornoPack(Integer TRANSF_ID, Integer USUARIO_ID) throws Exception;
}
