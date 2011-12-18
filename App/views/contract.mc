<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
</%args>
% $.curr_f->('contract');
% my $contract_id = $.f->('id');
% my @proj = $.db->quick_select('projects', {});
% my @comp = $.db->quick_select('companies', {});

% if (defined $.action) {

<h1>
  <% $.action eq '/contracts/add' ? 'Add' : 'Edit' %> contract
</h1>

  <form id="<% $.curr_f->('contract') %>"
        method="post"
        action="<% $.action %>" >
    <table class="edit">
    <tr>
      <th>Name:</th>
      <td>
%   if ($.action eq '/contracts/add') {
        <input type="text" name="name" value="<% $.f->('name') %>" />
%   } else {
      <% $.f->('name') %>
%   }
      </td>
    </tr><tr>
      <th> Company:</th>
      <td>
        <select name="company_id">
%   for (@comp){
          <option value="<% $_->{id} %>"
            <% (defined $.f->('company_id') && 
              $_->{id} eq $.f->('company_id')) ? 'selected="selected"' : '' %>>
            <% $_->{name} %>
          </option>
%   }
        </select>
      </td>
    </tr><tr>
      <th> Project:</th>
      <td>
        <select name="project_id">
%   for (@proj){
          <option value="<% $_->{id} %>"
            <% (defined $.f->('project_id') && 
              $_->{id} eq $.f->('project_id')) ? 'selected="selected"' : '' %>>
            <% $_->{name} %>
          </option>
%   }
        </select>
      </td>
    </tr>
%   if ($.action ne '/contracts/add') {
    <tr>
      <th>Active:</th>
      <td>
        <input type="checkbox" name="is_active" value="true" 
          <% $.f->('is_active') ? 'checked="checked"' : '' %> />
      </td>
    </tr>
%   }
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
    </table>
  </form>

% } else {
% $.curr_f->('contract');

<h1>View contract</h1>

<table class="edit">
  <tr>
    <th>Name:</th>
    <td><% $.f->('name') %></td>
  </tr>
  <tr>
    <th>Company:</th>
    <td>
      <a href="/company/<% $.f->('company_id') %>">
        <% $.f->('company') %>
        </a>
    </td>
  </tr>
  <tr>
    <th>Project:</th>
    <td>
      <a href="/project/<% $.f->('project_id') %>">
        <% $.f->('project') %>
      </a>
    </td>
  </tr>
  <tr>
    <th>Status:</th>
    <td><% $.f('is_active') ? 'active' : 'not active' %></td>
    </tr>
</table>

% }


