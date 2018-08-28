package com.tecnoratones.mbg.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.tecnoratones.mbg.service.TbCuentaService;
import com.tecnoratones.mgtest.model.TbCuenta;

@Controller
public class CuentaController {
	@Autowired
	TbCuentaService cuentaService;
	
	@RequestMapping(value="/cuentas")
	public ModelAndView MostrarCuentas(){
		ModelAndView mv = new ModelAndView("cuentas");
		
		try{
			
			List<TbCuenta> list = cuentaService.listaCuenta();
			mv.addObject("lis", list);
			
		}catch(Exception e){
			e.printStackTrace();
		}
		
		return mv;
	}
	
	
}
