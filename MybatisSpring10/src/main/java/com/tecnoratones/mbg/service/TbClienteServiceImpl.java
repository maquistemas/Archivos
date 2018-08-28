package com.tecnoratones.mbg.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.tecnoratones.mgtest.dao.TbClienteMapper;

@Service
public class TbClienteServiceImpl implements TbClienteService {
	
	@Autowired
	private TbClienteMapper clienteMapper;

	@Override
	public void insertPack(String nombre, String apellido, Integer user)throws Exception {
		
		clienteMapper.insertPack(nombre, apellido, user);
		
	}

}
