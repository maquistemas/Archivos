package com.tecnoratones.mbg.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.tecnoratones.mgtest.dao.TbCuentaMapper;
import com.tecnoratones.mgtest.model.TbCuenta;

@Service
public class TbCuentaImpl implements TbCuentaService {
	@Autowired
	TbCuentaMapper cuentaMapper;

	@Override
	public List<TbCuenta> listaCuenta() throws Exception {
		return cuentaMapper.listaCuenta();
	}

}
