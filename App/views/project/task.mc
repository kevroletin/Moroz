<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
    $.project
    $.project_id
</%args>
% if (defined $.action) {


  <form id="<% $.curr_f->('task') %>"
        method="post"
%   my $action = $.action eq 'add' ? 
%                  '/project/' . $.project_id . '/tasks/add':
%                  '/project/' . $.project_id . '/task/' . $.f->('id') . '/edit';
        action="<% $action %>" >

    <p> Name:

% if ($.action eq 'add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
    </p>
    <p> Estimate time: 
      <input type="text" name="estimate_time" value="<% $.f->('estimate_time') %>" /> 
    </p>

% if ($.action ne 'add') {
    <p>
      <input type="checkbox" name="is_active" value="true" 
             <% $.f->('is_active') ? 'checked="1"' : '' %> />
    </p>
% }
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

% } else {
% $.curr_f->('task');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Estimate time:
      <% $.f->('estimate_time') %>
    </p>
    <p> 
      <% $.f->('is_active') ? 'avtive' : 'not active' %>
    </p>
  </div>

% }

