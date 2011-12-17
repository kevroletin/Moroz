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

  <form id="<% $.curr_f->('contract') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

% if ($.action eq '/contracts/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
    </p>
    <p> Company:
      <select name="company_id">
% for (@comp){
        <option value="<% $_->{id} %>"
          <% (defined $.f->('company_id') && 
              $_->{id} eq $.f->('company_id')) ? 'selected="selected"' : '' %>>
          <% $_->{name} %>
        </option>
% }
      </select>
    </p>
    <p> Project:
      <select name="project_id">
% for (@proj){
        <option value="<% $_->{id} %>"
          <% (defined $.f->('project_id') && 
              $_->{id} eq $.f->('project_id')) ? 'selected="selected"' : '' %>>
          <% $_->{name} %>
        </option>
% }
      </select>
    </p>
    <p>
      <input type="checkbox" name="is_active" value="true" 
        <% $.f->('is_active') ? 'checked="checked"' : '' %> />
        Active?
    </p>

    
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

<hr />

% } else {
% $.curr_f->('contract');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Company: 
      <a href="/company/<% $.f->('company_id') %>">
        <% $.f->('company') %>
      </a>
    </p>
    <p> Project: 
      <a href="/project/<% $.f->('project_id') %>">
        <% $.f->('project') %>
      </a>
    </p>
    <p> 
      <% $.f('is_active') ? 'active' : 'not active' %>
    </p>
  </div>

% }


