<%args>
    $.error
    $.message
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

% $.curr_f->('activity');

<h1>
  <% defined $.action ? 'Edit' : 'View' %> activity on current task
</h1>

% if (!defined $.action && $.can_modify) {
<a href="<% $base_path %>/activity/<% $.f->('id')  %>/edit">
  Edit
</a>
% }


<div class="message_box">
  <div class="message"><% $.message %></div>
  <div class="error"><% $.error %></div>
</div>

<table class="edit">
  <tr>
    <th>Name:</th>
    <td><% $.f->('name') %></td>
  </tr>
  <tr>
    <th>User:</th>
    <td>
      <a href="/user/<% $.f->('user_id') %>">
        <% $.f->('user') %>
      </a>
    </td>
  </tr>
  <tr>
    <th>Started:</th>
    <td><% $.f->('start_time') =~ /(.*)\./, $1 %></td>
  </tr>
  <tr>
    <th>Finished:</th>
    <td><% $.f->('finish_time') ? ($.f->('finish_time') =~ /(.*)\./, $1) : '' %>
% if ($.can_modify) {
% $.curr_f->('activity');
% my $change_type = defined $.f->('finish_time') ? 'open' : 'close';
<form id='open_close_activity' method="post"
      action="<% $base_path %>/activity/<% $.f->('id') %>/<% $change_type %>" >
  <input type="submit" name="change_type"
         value="<% $change_type %>" />
</form>
% }
    </td>
  </tr>



  <tr>
    <th>Desctiption:</th>
    <td>
% if (defined $.action) {
      <form id="<% $.curr_f->('activity') %>"
            method="post"
            action="<% $base_path %>/activity/<% $.f->('id') %>/edit" >
        <textarea name="description"
          ><% $.f->('description') %></textarea>
        <br />
        <input type="submit" name="ok" value="submit" />
      </form>
% } else {
      <% $.f->('description') %>
% }
    </td>
  </tr>
</table>

