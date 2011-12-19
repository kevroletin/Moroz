<%args>
    $.error
    $.message
    $.curr_f
    $.f
    $.action
    $.user
    $.db
    $.project
    $.project_id
    $.log_sql
    $.is_manager
</%args>
<%init>
    use App::Utils;
    use Data::Dumper;

    my $is_manager = $.is_manager->();
    $.curr_f->('task');
    my $task_id = $.f->('id');

    my $q = 
"select * from tasks where project_id = " . $.project_id .
"\nand is_active = true ";

    $.log_sql->($q);
    my $tasks_sth = $.db->prepare($q);
    $tasks_sth->execute();
    my @tasks;
    while (my $u = $tasks_sth->fetchrow_hashref()) { push @tasks, $u }


     $q = <<SQL
select * from tasks where id in (
  select blocking_task_id from task_dependences
  where depended_task_id = $task_id
)
SQL
        ;
    $.log_sql->($q);
    my $tasks_blokers_sth = $.db->prepare($q);

    $q = <<SQL
select * from tasks where id in (
  select depended_task_id from task_dependences
  where blocking_task_id = $task_id
)
SQL
        ;
    $.log_sql->($q);
    my $tasks_depended_sth = $.db->prepare($q);

    $.curr_f->('task');
    my $base_path = '/project/' . $.project_id . '/task/' . $.f->('id');
</%init>

<a href="<% $base_path %>/activities">
  Activities on this task
</a>

% if (defined $.action) {

<h1>Edit task</h1>

<form id="<% $.curr_f->('task') %>"
        method="post"
        action="<% '/project/' . $.project_id . '/task/' . $.f->('id'). '/edit' %>" >


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
      <th>Estimate time:</th>
      <td>
        <input type="text" name="estimate_time" value="<% $.f->('estimate_time') %>" /> 
      </td>
    </tr>
    <tr>
      <th>Active</th>
      <td>
        <input type="checkbox" name="is_active" value="true" 
             <% $.f->('is_active') ? 'checked="1"' : '' %> />
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
% $.curr_f->('task');

<h1>View task</h1>

<table class="edit">
  <tr>
    <th>Name:</th>
    <td><% $.f->('name') %></td>
  </tr>
  <tr>
    <th>Estimate time:</th>
    <td><% $.f->('estimate_time') %></td>
  </tr>
  <tr>
    <th>Status</th>
    <td>
      <% $.f->('is_active') ? 'avtive' : 'not active' %>
    </td>
  </tr>
</table>

% }

<br />
<h2>Blocks</h2>
<table class="list">
% my $i = 0;
% $tasks_depended_sth->execute();
% while (my $u = $tasks_depended_sth->fetchrow_hashref()) {
  <tr class="<% even_odd($i++) %>">
    <td>
      <a href="/project/<% $.project_id %>/task/<% $u->{id} %>">
        <% $u->{name} %>
      </a>
    </td>
    <td>
      <% $u->{is_active} ? 'active' : 'finished' %>
    </td>
%   if ($.action && $.action eq 'edit') {
    <td>
      <form method="post" action="/project/<% $.project_id %>/task/<% $task_id %>/unlink">
        <input type="hidden" name="link_type" value="blocks" />
        <input type="hidden" name="another_task_id" value="<% $u->{id} %>" />
        <input type="submit" value="remove" />
      </form>
    </td>
%   }
  </tr>
% }
</table>

% if ($.action && $.action eq 'edit') {
<form id="link_task" method="post" 
      action="/project/<% $.project_id %>/task/<% $task_id %>/link">
  <input type="hidden" name="link_type" value="blocks" />
  <select name="another_task_id">
%   for my $u (@tasks) { 
   <option value="<% $u->{id} %>"><% $u->{name} %></option>
%   }
  </select>
  <input type="submit" value="link" />
</form>
% }


<br />
<h2>Blocked by</h2>
<table class="list">
% $i = 0;
% $tasks_blokers_sth->execute();
% while (my $u = $tasks_blokers_sth->fetchrow_hashref()) {
  <tr class="<% even_odd($i++) %>">
    <td>
      <a href="/project/<% $.project_id %>/task/<% $u->{id} %>">
        <% $u->{name} %>
      </a>
    </td>
    <td>
      <% $u->{is_active} ? 'active' : 'finished' %>
    </td>
%   if ($.action && $.action eq 'edit') {
    <td>
      <form method="post" action="/project/<% $.project_id %>/task/<% $task_id %>/unlink">
        <input type="hidden" name="link_type" value="blocked_by" />
        <input type="hidden" name="another_task_id" value="<% $u->{id} %>" />
        <input type="submit" value="remove" />
      </form>
    </td>
%   }
  </tr>
% }
</table>

% if ($.action && $.action eq 'edit') {
<form id="link_task" method="post" 
      action="/project/<% $.project_id %>/task/<% $task_id %>/link">
  <input type="hidden" name="link_type" value="blocked_by" />
  <select name="another_task_id">
%   for my $u (@tasks) { 
   <option value="<% $u->{id} %>"><% $u->{name} %></option>
%   }
  </select>
  <input type="submit" value="link" />
</form>
% }
