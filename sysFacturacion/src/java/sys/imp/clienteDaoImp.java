/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package sys.imp;

import java.util.List;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.Transaction;
import sys.dao.clienteDao;
import sys.model.Cliente;
import sys.util.HibernateUtil;

/**
 *
 * @author john
 */
public class clienteDaoImp  implements clienteDao{

    @Override
    public List<Cliente> listarClientes() {
        List<Cliente> lista = null;
        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction t = session.beginTransaction();
        String hql = "FROM Cliente";
        
        try{
            lista = session.createQuery(hql).list();
            t.commit();
            session.close();
        }catch(Exception e){
            t.rollback();
        }
        
        return lista;
    
    }

    @Override
    public void newCliente(Cliente cliente) {
        Session session = null;
        try{
            session = HibernateUtil.getSessionFactory().openSession();
            session.beginTransaction();
            session.save(cliente);
            session.getTransaction().commit();
        }catch(Exception e){
            System.out.println(e.getMessage());
            session.getTransaction().rollback();
        }finally{
            if(session!=null){
                session.close();
            }
        }
    
    }

    @Override
    public void updateCliente(Cliente cliente) {
        Session session = null;
        try{
            session = HibernateUtil.getSessionFactory().openSession();
            session.beginTransaction();
            session.update(cliente);
            session.getTransaction().commit();
        }catch(Exception e){
            System.out.println(e.getMessage());
            session.getTransaction().rollback();
        }finally{
            if(session!=null){
                session.close();
            }
        }

    }

    @Override
    public void deleteCliente(Cliente cliente) {
         Session session = null;
        try{
            session = HibernateUtil.getSessionFactory().openSession();
            session.beginTransaction();
            session.delete(cliente);
            session.getTransaction().commit();
        }catch(Exception e){
            System.out.println(e.getMessage());
            session.getTransaction().rollback();
        }finally{
            if(session!=null){
                session.close();
            }
        }

    
    }

    @Override
    public Cliente obtenerClientePorCodigo(Session session, Integer codCliente) throws Exception {
        String hql = "FROM Cliente WHERE codCliente =:codCliente";
        Query q = session.createQuery(hql);
        q.setParameter("codCliente", codCliente);
        
        return (Cliente) q.uniqueResult();
    }
    
}
