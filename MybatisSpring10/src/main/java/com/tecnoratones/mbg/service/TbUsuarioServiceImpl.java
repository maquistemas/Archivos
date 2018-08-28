package com.tecnoratones.mbg.service;


import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.tecnoratones.mgtest.dao.TbUsuarioMapper;
import com.tecnoratones.mgtest.model.TbUsuario;

@Service
public class TbUsuarioServiceImpl implements TbUsuarioService{

	@Autowired
	private TbUsuarioMapper usuarioMapper;
	
	@Transactional
	public void crearUsuario(TbUsuario usuario) throws Exception {
		usuarioMapper.insert(usuario);
	}

	@Override
	public TbUsuario getByPk(BigDecimal id) throws Exception {
		return usuarioMapper.selectByPrimaryKey(id);
	}

	@Override
	public TbUsuario getByUP(String use, BigDecimal pas) throws Exception {
		return usuarioMapper.logu(use, pas);
	}


	
	
	
}
