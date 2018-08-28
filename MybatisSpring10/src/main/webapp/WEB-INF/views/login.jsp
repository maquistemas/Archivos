<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

${mensaje}

<div id="_BODY">

	<h1>Login</h1>
	
	<form method="post" action="login3">
	
		Usuario:<br/> 
		<input type="text" name="usuario"><br/>
		
		Clave: <br/>
		<input type="password" name="password"><br/>
		
		<br/>
		<input type="submit" value="Login" />
	</form>



</div>

</body>
</html>