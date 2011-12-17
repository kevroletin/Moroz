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

<div style="float: right">
% print( $.user ? $.user->{name} : 'not logined' );
% # <p><pre>
% #  use Data::Dumper; print Dumper $.user;
% # </pre></p>
  <a href="/logout">logout</a>
</div>


<div>
  <a href="/companies">companies</a>
  <a href="/contracts">contracts</a>
  <a href="/projects">projects</a>
  <a href="/users">users</a>
</div>

<hr />

<% inner() %>

<div id="footer">
<!-- Powered by <a href="http://perldancer.org/">Dancer</a> -->
</div>
</body>
</html>

</%augment>

