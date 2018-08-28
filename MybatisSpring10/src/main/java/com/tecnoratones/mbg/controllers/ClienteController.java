package com.tecnoratones.mbg.controllers;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.tecnoratones.mbg.service.TbClienteService;


@Controller
public class ClienteController {
	
	@Autowired
	private TbClienteService clienteService;

@RequestMapping(value="/cliente")
public ModelAndView agregar(){
	
	try {
		String nombre="juliana";
		String apellido="sosa";
		Integer user=6;
		clienteService.insertPack(nombre, apellido, user);
	} catch (Exception e) {
		// TODO Auto-generated catch block
		e.printStackTrace();
	}
	
	
	
	ModelAndView mv = new ModelAndView("test","mensaje","Se guardo el nuevo registro");
	return mv;
}
	

}
