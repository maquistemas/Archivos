
<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %> 
<%@ page session="true" %>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title></title>
<meta name="keywords" content="" />
<meta name="description" content="" />
<link href="http://fonts.googleapis.com/css?family=Source+Sans+Pro:200,300,400,600,700,900" rel="stylesheet" />
<link href='<c:url value="/resources/css/default.css"/>' rel="stylesheet" type="text/css" media="all" />
<link href='<c:url value="/resources/css/fonts.css"/>' rel="stylesheet" type="text/css" media="all" />

<!--[if IE 6]><link href="default_ie6.css" rel="stylesheet" type="text/css" /><![endif]-->

</head>
<body>
<div id="header-wrapper">
  <div id="header" class="container">
    <div id="logo">
      <h1><a href="#">Transacciones</a></h1>
      
      <table width="10%">
    		<tr>
    			<td><img alt="" src="<c:url value='/resources/images/${usua}.jpg' />" /></td>
    			
    			<td>
    				${sessionScope.u.USUARIO_NAME}
    				
    			</td>
    		</tr>
    	</table>
      
      
      
</div>
    <div id="menu">
      <ul>
        <li class="current_page_item"><a href="#" accesskey="1" title="">Homepage</a></li>
        <li><a href="javascript:fnCargarPagina('login')" accesskey="2" title="">Login</a></li>
        <li><a href="javascript:fnCargarPagina('cuentas')" accesskey="2" title="">Cuentas</a></li>
        <li><a href="javascript:fnCargarPagina('transacciones')" accesskey="3" title="">Auditoria</a></li>
        <li><a href="javascript:fnCargarPagina('auditoria')" accesskey="4" title="">Transacciones</a></li>
        <li><a href="javascript:fnCargarPagina('contacto')" accesskey="5" title="">Contact Us</a></li>
      </ul>
    </div>
  </div>
</div>
<div id="header-featured" style="overflow-y: scroll;">





 </div>

<div id="wrapper">
  <div id="featured-wrapper">
    <div id="featured" class="container">
      <div class="column1"> <span class="icon icon-cogs"></span>
        <div class="title">
          <h2>Maecenas lectus sapien</h2>
        </div>
        <p>In posuere eleifend odio. Quisque semper augue mattis wisi. Pellentesque viverra vulputate enim. Aliquam erat volutpat.</p>
      </div>
      <div class="column2"> <span class="icon icon-legal"></span>
        <div class="title">
          <h2>Praesent scelerisque</h2>
        </div>
        <p>In posuere eleifend odio. Quisque semper augue mattis wisi. Pellentesque viverra vulputate enim. Aliquam erat volutpat.</p>
      </div>
      <div class="column3"> <span class="icon icon-unlock"></span>
        <div class="title">
          <h2>Fusce ultrices fringilla</h2>
        </div>
        <p>In posuere eleifend odio. Quisque semper augue mattis wisi. Pellentesque viverra vulputate enim. Aliquam erat volutpat.</p>
      </div>
      <div class="column4"> <span class="icon icon-wrench"></span>
        <div class="title">
          <h2>Etiam posuere augue</h2>
        </div>
        <p>In posuere eleifend odio. Quisque semper augue mattis wisi. Pellentesque viverra vulputate enim. Aliquam erat volutpat.</p>
      </div>
    </div>
  </div>
  
</div>

<div id="copyright" class="container">
  <p>&copy; Untitled. All rights reserved. | Photos by <a href="#">Fotogrph</a> | Design by <a href="#" rel="nofollow">TEMPLATED</a>.</p>
</div>
</body>
</html>









<script type="text/javascript" src="<c:url value='/resources/jquery/jquery-1.11.2.min.js'/>"></script>
<script type="text/javascript">

  function fnCargarPagina(pagina){
	$("#header-featured").load(pagina);
  }	

</script>	








