package com.tecnoratones.mbg.service;

import java.util.List;

import com.tecnoratones.mgtest.model.TbAuditoria;

public interface TbAuditoriaService {
	public List<TbAuditoria> audiView()  throws Exception;
	public List<TbAuditoria>listaAudi() throws Exception;
}
