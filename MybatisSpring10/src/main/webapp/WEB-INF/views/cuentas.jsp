<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    <%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>   
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

<h3>Cuentas</h3>


	<table border="1">
	
		<tr>
			<td>Cuenta</td>
			<td>Monto</td>
			
		</tr>

		<c:forEach items="${lis}" var="o">
			<tr>
				<td>${o.CUENTA}</td>
				<td>${o.CUENTA_SALDO}</td>
				
			</tr>
		</c:forEach>

	</table>
	
	
	<br><br>
	
	<form id="form1">
	<table>
	<tr>
	<td>USUARIO_ID</td><td>CUENTA_ORIGEN</td><td>CUENTA_DESTINO</td><td>MONTO</td>
	</tr>
	<tr>
	<td><input type="text" name="USUARIO_ID"></td><td><input type="text" name="CUENTA_ORIGEN"></td>
	<td><input type="text" name="CUENTA_DESTINO"></td><td><input type="text" name="MONTO"></td>
	</tr>
	</table>
	<input type="button" id="btnProcesar" value="Transferencia">
	</form>
	
	
	

</body>








<script type="text/javascript">

  $("#btnProcesar").click(function(){
	  var data = $("#form1").serialize();
	  $.post("trans",data,function(objJson){
		  alert(objJson.mensaje);
	  });
  });

</script>



</html>










