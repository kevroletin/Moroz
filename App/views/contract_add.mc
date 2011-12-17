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
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>
