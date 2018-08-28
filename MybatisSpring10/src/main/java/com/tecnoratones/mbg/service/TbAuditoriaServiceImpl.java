package com.tecnoratones.mbg.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.tecnoratones.mgtest.dao.TbAuditoriaMapper;
import com.tecnoratones.mgtest.model.TbAuditoria;

@Service
public class TbAuditoriaServiceImpl implements TbAuditoriaService {
	@Autowired
	TbAuditoriaMapper auditoriaMapper;

	@Override
	public List<TbAuditoria> audiView()  throws Exception {
		return auditoriaMapper.audiView();
	}

	@Override
	public List<TbAuditoria> listaAudi() throws Exception {
		return auditoriaMapper.listaAudi();
	}

}
