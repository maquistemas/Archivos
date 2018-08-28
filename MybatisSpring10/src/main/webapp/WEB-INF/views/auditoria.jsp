<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%@taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>   
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>


<h3>Operación Extorno:</h3>


	<div >
	
		<div>
			<form id="form1">
				<table>
					<tr>
						<td>#Transacción Tipo(T)</td>
						<td>Usuario</td>
					</tr>
					<tr>
						<td><input type="text" name="TRANSF_ID"></td>
						<td><input type="text" name="USUARIO_ID"></td>
					</tr>
				</table>
				<input type="button" id="btnProcesar" value="Extorno">
			</form>

		</div>

		<div>
			<table border="1">

				<tr>
					<td>#TRANSACCION</td>
					<td>TIPO</td>
					<td>CTA_ORIGEN</td>
					<td>EMISOR</td>
					<td>CTA_DESTINO</td>
					<td>RECEPTOR</td>
					<td>MONTO</td>
				</tr>

				<c:forEach items="${lis}" var="o">
					<tr>
						<td>${o.TRANSACCION}</td>
						<td>${o.TIPO}</td>
						<td>${o.CTA_ORIGEN}</td>
						<td>${o.EMISOR}</td>
						<td>${o.CTA_DESTINO}</td>
						<td>${o.RECEPTOR}</td>
						<td>${o.MONTO}</td>
					</tr>
				</c:forEach>

			</table>

		</div>

	</div>











</body>




<script type="text/javascript">

  $("#btnProcesar").click(function(){
	  var data = $("#form1").serialize();
	  $.post("extorno",data,function(objJson){
		  alert(objJson.mensaje);
	  });
  });

</script>




</html>