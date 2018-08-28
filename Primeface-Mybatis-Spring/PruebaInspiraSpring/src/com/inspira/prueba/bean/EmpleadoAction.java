package com.inspira.prueba.bean;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

import org.primefaces.event.SelectEvent;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import com.inspira.prueba.entity.Empleado;
import com.inspira.prueba.service.EmpleadoService;

@ManagedBean(name = "empleadoAction")
@SessionScoped
@Controller
public class EmpleadoAction {

	@Autowired
	EmpleadoService empleadoService;
	List<Empleado> emList;
	Empleado slcEmpleado = new Empleado();
	Empleado workEmpleado = new Empleado();
	boolean isIngreso = false;

	public EmpleadoAction() {

	}

	public void ir_mantenedor(SelectEvent event) throws IOException, Exception {
		this.workEmpleado = this.slcEmpleado;
		isIngreso = false;
	}

	public void prueba() {
		emList = empleadoService.getEmpleadoDet();
	}

	public void newCampo() {
		if (isIngreso) {
			Empleado e = new Empleado();
			e.setDNI(workEmpleado.getDNI());
			e.setNombre(workEmpleado.getNombre());
			e.setApellido(workEmpleado.getApellido());
			empleadoService.insertaEmpl(e);
			emList.add(e);
			isIngreso = true;
		} else {
			empleadoService.upEmpleado(workEmpleado);
		}

		workEmpleado = new Empleado();
		prueba();
	}

	public void delCampo() {
		try {
			empleadoService.delEmpleado(slcEmpleado);
			emList.remove(slcEmpleado);
			prueba();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public List<Empleado> getEmList() {
		return emList;
	}

	public void setEmList(List<Empleado> emList) {
		this.emList = emList;
	}

	public EmpleadoService getEmpleadoService() {
		return empleadoService;
	}

	public void setEmpleadoService(EmpleadoService empleadoService) {
		this.empleadoService = empleadoService;
	}

	public Empleado getSlcEmpleado() {
		return slcEmpleado;
	}

	public void setSlcEmpleado(Empleado slcEmpleado) {
		this.slcEmpleado = slcEmpleado;
	}

	public Empleado getWorkEmpleado() {
		return workEmpleado;
	}

	public void setWorkEmpleado(Empleado workEmpleado) {
		this.workEmpleado = workEmpleado;
	}

}
