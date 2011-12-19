<%args>
    $.session
    $.user
</%args>

<%augment wrap>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

<!-- LIVERELOAD -- >
  <script src="/livereload/src/content.js"></script>
  <script src="/livereload/src/background.js"></script>
  <script src="/livereload/src/xbrowser/livereload.js"></script>
  <script>
    window.onload = function(){
      livereload.run();
    };
  </script>
< !-- LIVERELOAD -->

  <link rel="stylesheet" type="text/css" href="/css/clear.css" />
  
  <link rel="stylesheet" type="text/css" href="/css/main.css" />

</head>
<body>



<div id="container">
<div class="header_filler"></div>
<div id="header">

  <div class="toolbar_login">
% if ($.user) {
  <a href="/user/<% $.user->{id} %>" >
% }
   <% $.user ? $.user->{name} : 'not logined' %>
  </a> |
% # <p><pre>
% #  use Data::Dumper; print Dumper $.user;
% # </pre></p>
    <a href="/logout">logout</a>
  </div>
  
  <div>
    <a href="/activities">activities</a>
    <a href="/companies">companies</a>
    <a href="/contracts">contracts</a>
    <a href="/projects">projects</a>
    <a href="/users">users</a>
  </div>
  
</div>


<div id="before_content_cpacer">
  <div id="before_content_filler"></div>
</div>
<div id="content">

<% inner() %>

</div>


<div id="footer">
  <div id="footer_filler">
    Powered by <a href="http://perldancer.org/">Dancer</a>
  </div>
</div>

</div>

</body>
</html>

</%augment>

