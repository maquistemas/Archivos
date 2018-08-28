package com.inspira.prueba.dao;

import java.util.List;

import com.inspira.prueba.entity.Empleado;

public interface EmpleadoMapper {
	public List<Empleado> getEmpleadoDet();
	void insertaEmpl(Empleado emp);
	void delEmpleado(Empleado emp);
	void upEmpleado(Empleado emp);
}
