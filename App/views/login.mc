<%args>
    $.error
    $.message
    $.curr_f
    $.f
</%args>

<form id="<% $.curr_f->('login') %>" method="post" action="/login">
  <div class="message_box">
    <div class="message"><% $.message %></div>
    <div class="error"><% $.error %></div>
  </div>
  <table class="edit">
    <tr>
      <th>Name:</th>
      <td>
        <input type="text" name="name" 
         value="<% $.f->('name') %>" />
      </td>
    </tr>
    <tr>
      <th>Password</th>
      <td>
        <input type="password" name="password" />
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="ok" />
      </td>
    </tr>
  </table>
</form>
