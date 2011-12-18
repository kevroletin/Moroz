<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
</%args>

% if (defined $.action) {
% my @comp = $.db->quick_select('companies', {});

<h1><% $.action eq '/users/add' ? 'Add' : 'Edit' %> user</h1>

  <form id="<% $.curr_f->('user') %>"
        method="post"
        action="<% $.action %>" >
    <table class="edit">
    <tr>
      <th>Name:</th>
      <td>
% if ($.action eq '/users/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
      </td>
    </tr>
    <tr>
      <th>Password:</th>
      <td>
        <input type="text" name="password" value="<% $.f->('password') %>" />
      </td>
    </tr>
    <tr>
      <th>Admin:</th>
      <td>
% if ($.user->{is_admin}) {
      <input type="checkbox" name="is_admin" value="true" 
             <% $.f->('is_admin') ? 'checked="1"' : ''  %> />
% } else {
        <% $.f->('is_admin') ? 'yes' : 'no'  %>
% }
      </td>
    </tr>
    <tr>
      <th>Company:</th>
      <td>
        <select name="company_id">
% unless (defined $.f->('company_id')) {
        <option value=""></option>
% }
% for (@comp) {
        <option value="<% $_->{id} %>"               
          <% (defined $.f->('company_id') && 
              $_->{id} eq $.f->('company_id')) ? 'selected="selected"' : '' %>>
          <% $_->{name} %>
        </option>
% }
      </select>
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
    </table>
  </form>

% } else {
% $.curr_f->('user');

<h1>View user</h1>

<table class="edit">
  <tr>
    <th>Name:</th>
    <td><% $.f->('name') %></td>
  </tr>
  <tr>
    <th>Permissions:</th> 
    <td><% $.f->('is_admin') ? 'admin' : 'not admin' %></td>
  </tr>
  <tr>
    <th>Company:</th>
    <td>
      <a href="/company/<% $.f->('company_id') %>">
        <% $.f->('company') %>
      </a>
    </td>
  </tr>
</table>

% }
