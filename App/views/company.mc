<%args>
    $.curr_f
    $.f
    $.action
    $.user
</%args>


% if (defined $.action) {

  

<h1>
  <% $.action eq '/companies/add' ? 'Add' : 'Edit' %> company
</h1>

  <form id="<% $.curr_f->('company') %>"
        method="post"
        action="<% $.action %>" >
    <table class="edit">
    <tr>
      <th> Name:</th>
      <td>  
% if ($.action eq '/companies/add') {
        <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
      </td>
    </tr><tr>
      <td><input type="submit" name="ok" value="submit" /></td>
      <td></td>
    </tr>
    </table>
  </form>

% } else {
% $.curr_f->('company');

  <h1>View of company</h1>
  <div>
    <table class="edit">
      <tr>
        <th>Name:</th>
        <td><% $.f->('name') %></td>
      <tr>
    </table>
  </div>

% }
