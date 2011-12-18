<%args>
    $.task_id
    $.project_id
    $.db
    $.role
    $.curr_f
    $.f
    $.action
    $.user
    $.can_modify
</%args>
<%init>
    use Data::Dumper;
    
    my $base_path = "/project/" . $.project_id . "/task/" . $.task_id;
</%init>

<a href="<% $base_path %>/activities">All activities</a>

% if ($.can_modify) {
% $.curr_f->('activity');
% my $change_type = defined $.f->('finish_time') ? 'open' : 'close';
<form id='open_close_activity' method="post"
      action="<% $base_path %>/activity/<% $.f->('id') %>/<% $change_type %>" >
  <input type="submit" name="change_type"
         value="<% $change_type %>" />
</form>
% }

% $.curr_f->('activity');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p>User: 
      <a href="/user/<% $.f->('user_id') %>">
        <% $.f->('user') %>
      </a>
    </p>
    <p>Started: <% $.f->('start_time') %>
    </p>
    <p>Finished: <% $.f->('finish_time') %>

% if (defined $.action) {

  <form id="<% $.curr_f->('activity') %>"
        method="post"
        action="<% $base_path %>/activity/<% $.f->('id') %>/edit" >
  <p> Desctiption:
    <textarea name="description"
      ><% $.f->('description') %></textarea>
  </p>
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

% } else {

    </p>
    <p> Description: <% $.f->('description') %>
    </p>

% }

  </div>

