<%args>
    $.error
    $.message
    $.curr_f
    $.f
</%args>

<form id="<% $.curr_f->('login') %>" method="post" action="/login">
  <div class="message">
% print($.message);
  </div>
  <div class="error">
% print($.error);
  </div>
  <input type="text" name="name" 
         value="<% $.f->('name') %>" />
  <input type="password" name="password" />
  <input type="submit" name="ok" value="ok" />
</form>
