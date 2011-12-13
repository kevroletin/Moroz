<%args>
    $.error
    $.message
</%args>

<form id="login_form" method="post" action="/login">
  <div class="message">
% print($.message);
  </div>
  <div class="error">
% print($.error);
  </div>
  <input type="text" name="name"></input>
  <input type="password" name="password"></input>
  <input type="submit" name="ok" value="ok"></input>  
</form>
