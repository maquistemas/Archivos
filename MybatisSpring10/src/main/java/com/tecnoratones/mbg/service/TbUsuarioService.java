package com.tecnoratones.mbg.service;


import java.math.BigDecimal;

import com.tecnoratones.mgtest.model.TbUsuario;

public interface TbUsuarioService {
	
	public void crearUsuario(TbUsuario usuario) throws Exception;
	public TbUsuario getByPk(BigDecimal id) throws Exception;
	
	public TbUsuario getByUP(String use, BigDecimal pas) throws Exception;

}
