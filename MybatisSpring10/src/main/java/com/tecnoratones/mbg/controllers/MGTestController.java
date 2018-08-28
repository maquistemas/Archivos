package com.tecnoratones.mbg.controllers;

import java.math.BigDecimal;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.tecnoratones.mgtest.model.TbUsuario;
import com.tecnoratones.mbg.service.TbUsuarioService;

@Controller
public class MGTestController {

	@Autowired
	private TbUsuarioService usuarioService;
	
	@RequestMapping("/test")
	public ModelAndView test(HttpServletRequest request, HttpServletResponse response) {
		TbUsuario usuario = new TbUsuario();
		BigDecimal cod = new BigDecimal(13);
		BigDecimal pas = new BigDecimal(123);
		usuario.setUSUARIO_ID(cod);
		usuario.setUSUARIO_NAME("guita");
		usuario.setUSUARIO_PASSWORD(pas);
		try {
			//usuarioService.crearUsuario(usuario);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return new ModelAndView("test","mensaje","Se guardo el nuevo registro");
	}
	
}
