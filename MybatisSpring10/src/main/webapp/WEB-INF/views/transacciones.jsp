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
<h3>Auditoria</h3>


<table border="1">
	
		<tr>
			<td>AUDITORIA_ID </td>
			<td>AUDITORIA_FECHA</td>
			<td>AUDITORIA_SCHEMA</td>
			<td>AUDITORIA_TRANSFERENCIA_ID</td>
		</tr>

		<c:forEach items="${lis}" var="o">
			<tr>
				<td>${o.AUDITORIA_ID }</td>
				<td>${o.AUDITORIA_FECHA}</td>
				<td>${o.AUDITORIA_SCHEMA}</td>
				<td>${o.AUDITORIA_TRANSFERENCIA_ID}</td>
			</tr>
		</c:forEach>

	</table>



</body>
</html>