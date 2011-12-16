<%args>
    $.curr_f
    $.f
    $.action
    $.user
</%args>

% if (defined $.action) {

  <form id="<% $.curr_f->('company') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

% if ($.action eq '/companies/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
    </p>
    
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

% } else {
% $.curr_f->('company');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
  </div>

% }
