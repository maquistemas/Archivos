package com.tecnoratones.mbg.controllers;

import java.util.List;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

import com.tecnoratones.mbg.service.TbAuditoriaService;
import com.tecnoratones.mgtest.model.TbAuditoria;

@Controller
public class AuditoriaController {
	@Autowired
	TbAuditoriaService auditoriaService;
	
	 @RequestMapping(value="/auditoria")
		public ModelAndView Mostrar() {

			List<TbAuditoria> list = null;

			try {
				list = auditoriaService.audiView();
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("Error");
			}
			
			ModelAndView mv = new ModelAndView("auditoria");
			mv.addObject("lis", list);

			return mv;
		}
	
	 @RequestMapping(value="/transacciones")
		public ModelAndView ListarAuditoria() {

			List<TbAuditoria> list = null;

			try {
				list = auditoriaService.listaAudi();
			} catch (Exception e) {
				e.printStackTrace();
				System.out.println("Error");
			}
			
			ModelAndView mv = new ModelAndView("transacciones");
			mv.addObject("lis", list);

			return mv;
		}
	
	
	
}
