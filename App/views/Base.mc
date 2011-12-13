<%args>
    $.session
    $.user
</%args>

<%augment wrap>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

</head>
<body>

<div>
% print( $.user ? $.user->{name} : 'not logined' );
</div>


<% inner() %>

<div id="footer">
Powered by <a href="http://perldancer.org/">Dancer</a> 
</div>
</body>
</html>

</%augment>

