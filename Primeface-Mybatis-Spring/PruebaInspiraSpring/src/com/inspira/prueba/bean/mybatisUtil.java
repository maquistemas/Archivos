package com.inspira.prueba.bean;

import java.io.Reader;

import org.apache.ibatis.io.Resources;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.session.SqlSessionFactoryBuilder;

public class mybatisUtil {
	
	private String resource;
	private SqlSession session;
	
	public SqlSession getSession()
	{
		this.resource = "com/prueba/mybatis/mybatis-config.xml";
		
		try
		{
			Reader reader = Resources.getResourceAsReader(this.resource);
			SqlSessionFactory sqlMapper = new SqlSessionFactoryBuilder().build(reader);
			session = sqlMapper.openSession();
		}
		catch (Exception e)
		{
			e.printStackTrace();
		}
		
		return session;
	}

}
