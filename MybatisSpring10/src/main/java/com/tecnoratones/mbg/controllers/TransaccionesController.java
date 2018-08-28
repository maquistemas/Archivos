package com.tecnoratones.mbg.controllers;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import com.google.gson.Gson;
import com.tecnoratones.mbg.service.TbTransferenciaService;

@Controller
public class TransaccionesController {
	@Autowired
	TbTransferenciaService transferenciaService;
	
	@RequestMapping(value="trans", method=RequestMethod.POST, produces = "application/json")
	public @ResponseBody String Transferir(HttpServletRequest request){
			 
			 Integer USUARIO_ID = Integer.parseInt(request.getParameter("USUARIO_ID"));
			 Integer CUENTA_ORIGEN= Integer.parseInt(request.getParameter("CUENTA_ORIGEN"));
			 Integer CUENTA_DESTINO= Integer.parseInt(request.getParameter("CUENTA_DESTINO"));
			 Integer MONTO= Integer.parseInt(request.getParameter("MONTO"));
			
			 Map<String, Object> rpta = new HashMap<String, Object>();
		
		try{
			transferenciaService.transPack(USUARIO_ID, CUENTA_ORIGEN, CUENTA_DESTINO, MONTO);
			rpta.put("code", 1);
			rpta.put("mensaje", "Transaferencia ejecutada correctamente.");
		}catch(Exception e){
			rpta.put("code", -1);
			rpta.put("mensaje", e.getMessage());
		}
		
		
		Gson gson = new Gson();
		return gson.toJson(rpta);
	}
	
	
	
	
	@RequestMapping(value="/extorno", method=RequestMethod.POST, produces = "application/json")
	public @ResponseBody String Extorno(HttpServletRequest request){
			
		  Integer TRANSF_ID = Integer.parseInt(request.getParameter("TRANSF_ID"));
		  Integer USUARIO_ID = Integer.parseInt(request.getParameter("USUARIO_ID"));
		  
		  Map<String, Object> rpta = new HashMap<String, Object>();
		
		try{
			transferenciaService.extornoPack(TRANSF_ID, USUARIO_ID);
			rpta.put("code", 1);
			rpta.put("mensaje", "Extorno ejecutado correctamente");
		}catch(Exception e){
			rpta.put("code", -1);
			rpta.put("mensaje", e.getMessage());
		}
		
		Gson gson = new Gson();
		return gson.toJson(rpta);
	}
	

}
