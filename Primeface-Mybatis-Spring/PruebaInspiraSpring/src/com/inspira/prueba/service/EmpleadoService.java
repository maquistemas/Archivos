package com.inspira.prueba.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.inspira.prueba.dao.EmpleadoMapper;
import com.inspira.prueba.entity.Empleado;

@Service
public class EmpleadoService {
	@Autowired
	EmpleadoMapper empleadoMapper;

	public List<Empleado> getEmpleadoDet() {
		return empleadoMapper.getEmpleadoDet();
	}

	public void insertaEmpl(Empleado emp) {
		empleadoMapper.insertaEmpl(emp);
	}
	public void delEmpleado(Empleado emp){
		empleadoMapper.delEmpleado(emp);
	}
	public void upEmpleado(Empleado emp){
		empleadoMapper.upEmpleado(emp);
	}
}
