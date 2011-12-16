<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
</%args>

<a href="/users">Users list</a>

% if (defined $.action) {
% my @comp = $.db->quick_select('companies', {});

  <form id="<% $.curr_f->('user') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

% if ($.action eq '/users/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }

    </p>
    <p> Password:
      <input type="text" name="password" value="<% $.f->('password') %>" />
    </p>
    <p>
      Admin?
% if ($.user->{is_admin}) {
      <input type="checkbox" name="is_admin" value="true" 
             <% $.f->('is_admin') ? 'checked="1"' : ''  %> />
% } else {
        <% $.f->('is_admin') ? 'yes' : 'no'  %>
% }
    </p>
    <p>Company:
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
    </p>

    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

% } else {
% $.curr_f->('user');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Password:
      <% $.f->('password') %>
    </p>
    <p>
      Admin? <% $.f->('is_admin') %>
    </p>
    <p>
      Company: <% $.f->('company') %>
    </p>

  </div>

% }
