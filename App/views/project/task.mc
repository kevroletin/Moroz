<%args>
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
and is_active = true
SQL
        ;
    $.log_sql->($q);
    my $tasks_blokers_sth = $.db->prepare($q);

    $q = <<SQL
select * from tasks where id in (
  select depended_task_id from task_dependences
  where blocking_task_id = $task_id
)
and is_active = true
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


  <form id="<% $.curr_f->('task') %>"
        method="post"
        action="<% '/project/' . $.project_id . '/task/' . $.f->('id'). '/edit' %>" >
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Estimate time: 
      <input type="text" name="estimate_time" value="<% $.f->('estimate_time') %>" /> 
    </p>

    <p>
      <input type="checkbox" name="is_active" value="true" 
             <% $.f->('is_active') ? 'checked="1"' : '' %> />
      Is active
    </p>
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

<h4>Blocks</h4>
<table>
% $tasks_depended_sth->execute();
% while (my $u = $tasks_depended_sth->fetchrow_hashref()) {
  <tr>
    <td>
      <a href="/project/<% $.project_id %>/task/<% $u->{id} %>">
        <% $u->{name} %>
      </a>
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

<form id="link_task" method="post" 
      action="/project/<% $.project_id %>/task/<% $task_id %>/link">
  <input type="hidden" name="link_type" value="blocks" />
  <select name="another_task_id">
% for my $u (@tasks) { 
   <option value="<% $u->{id} %>"><% $u->{name} %></option>
% }
  </select>
  <input type="submit" value="link" />
</form>


<h4>Blocked by</h4>
<table>
% $tasks_blokers_sth->execute();
% while (my $u = $tasks_blokers_sth->fetchrow_hashref()) {
  <tr>
    <td>
      <a href="/project/<% $.project_id %>/task/<% $u->{id} %>">
        <% $u->{name} %>
      </a>
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

<form id="link_task" method="post" 
      action="/project/<% $.project_id %>/task/<% $task_id %>/link">
  <input type="hidden" name="link_type" value="blocked_by" />
  <select name="another_task_id">
% for my $u (@tasks) { 
   <option value="<% $u->{id} %>"><% $u->{name} %></option>
% }
  </select>
  <input type="submit" value="link" />
</form>
