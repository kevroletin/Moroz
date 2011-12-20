<%args>
    $.activities_sth
    $.users_sth
    $.tasks_sth,
    $.duration,
    $.projects_sth
    $.project
    $.db
    $.role
    $.work_on_activity
    $.curr_f
    $.f
</%args>
<%init>
    use App::Utils;
    use Data::Dumper;

</%init>

<h1>List of all activities</h1>

<form id="<% $.curr_f->('filter') %>">
  <table class="edit">
    <tr>
      <th>User</th>
      <th>Project</th>
      <th>Task</th>
    </tr>
    <tr>
      <td>
        <select name="user_id">
          <option value="">*</option>
% while (my $u = $.users_sth->fetchrow_hashref()) {
          <option value="<% $u->{id} %>" 
                 <% (defined $u->{id} &&
                     defined $.f->('task_id') &&
                     $u->{id} eq $.f->('user_id')) ? 'selected="selected"' : '' %> >
            <% $u->{name} %>
          </option>
% }
        </select>
      </td>
      <td>
        <select name="project_id">
          <option value="">*</option>
% while (my $u = $.projects_sth->fetchrow_hashref()) {
          <option value="<% $u->{id} %>" 
                 <% (defined $u->{id} && 
                     defined $.f->('task_id') &&
                     $u->{id} eq $.f->('project_id')) ? 'selected="selected"' : '' %> >
            <% $u->{name} %>
          </option>
% }
        </select>
      </td>
      <td>
        <select name="task_id">
          <option value="">*</option>
% while (my $u = $.tasks_sth->fetchrow_hashref()) {
          <option value="<% $u->{id} %>" 
                 <% (defined $u->{id} && 
                     defined $.f->('task_id') &&
                     $u->{id} eq $.f->('task_id') ) ? 'selected="selected"' : '' %> >
            <% $u->{name} %>
          </option>
% }
        </select>
      </td>
      <td>
        <input type="submit" value="filter" />
      </td>
    </tr>
  </table>
</form>


<table class="list">
  <tr>
    <th>Name</th>
    <th>User</th>
    <th>Project</th>
    <th>Task</th>
    <th>Started</th>
    <th>Finished</th>
    <th>Duration</th>
  </tr>

% my $i = 0;
% while (my $u = $.activities_sth->fetchrow_hashref()) { 
  <tr class="<% even_odd($i++) %>">
    <td>
      <a href="/project/<% $u->{project_id} %>/task/<% $u->{task_id} %>/activity/<% $u->{id} %>">
        <% $u->{name} %>
      </a>
    </td>
    <td>
      <a href="/user/<% $u->{user_id} %>">
        <% $u->{user} %>
      </a>
    </td>
    <td>
      <a href="/project/<% $u->{project_id} %>">
        <% $u->{project} %>
      </a>
    </td>
    <td>
      <a href="/project/<% $u->{project_id} %>/task/<% $u->{task_id} %>">
        <% $u->{task} %>
      </a>
    </td>
    <td><% $u->{start_time}  =~ /(.*)\./, $1 %>
    </td>
    <td><% $u->{finish_time} ? ($u->{finish_time} =~ /(.*)\./, $1) : '' %>
    </td>
    <td>
      <% $u->{duration} ? ($u->{duration} =~ /(.*)\./, $1) : ''  %>
    </td>

%     if (0 && $.role eq 'manager') {
    <td>
        <a href="user/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/user/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
%     }
  </tr>
% }
%

  <tr>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <th><% $.duration ? ($.duration =~ /(.*)\./, $1) : '' %></th>
  </tr>

</table>
