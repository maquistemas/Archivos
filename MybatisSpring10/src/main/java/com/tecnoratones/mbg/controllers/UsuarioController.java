package com.tecnoratones.mbg.controllers;

import java.math.BigDecimal;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.tecnoratones.mbg.service.TbUsuarioService;
import com.tecnoratones.mgtest.model.TbUsuario;


@Controller
public class UsuarioController {
	
	@Autowired
	TbUsuarioService usuarioService; 
	
	@RequestMapping(value="/login", method=RequestMethod.GET)
	public ModelAndView login1(){
		ModelAndView mv = new ModelAndView("login");
		return mv;
	}
	
		
	
	
	@RequestMapping(value="/login3", method=RequestMethod.POST)
	public ModelAndView log3(
			@RequestParam("usuario") String usuario,
			@RequestParam("password") Integer password,
			HttpServletRequest request
			){
		ModelAndView mv = new ModelAndView();
		
		
		try{
		BigDecimal pas = new BigDecimal(password);
		TbUsuario tbUsuario = usuarioService.getByUP(usuario, pas);
		mv.addObject("usua",tbUsuario.getUSUARIO_NAME());
		request.getSession().setAttribute("u", tbUsuario);
		mv.setViewName("home");
			
		}catch(Exception e){
			mv.addObject("mensaje", e.getMessage());
			mv.setViewName("login");
		}
		
		
		return mv;
	}
	
	
	@RequestMapping(value="/contacto")
	public ModelAndView contacto(){
		ModelAndView mv = new ModelAndView("contacto");
				
		return mv;
	}
	
	
	
	
}
