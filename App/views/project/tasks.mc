<%args>
    $.user
    $.tasks_sth
    $.project
    $.project_id
    $.is_manager
</%args>
<%init>
    use App::Utils;
    use Data::Dumper;
</%init>

% if ($.is_manager->()) {
<a href="tasks/add">New task</a>
% }

<h1>List of task for current project</h1>
<h2>Project: <% $.project->{name} %> </h2>

<table class="list">
  <tr>
    <th>Name</th>
    <th>Status</th>
  </tr>

% my $i = 0;
% while (my $u = $.tasks_sth->fetchrow_hashref()) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td>
        <a href="task/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td><% $u->{is_active} ? 'active' : 'not active' %>
    </td>

% #     if ($.is_manager->();) {
    <td>
        <a href="task/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/project/<% $.project_id %>/task/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
% #    }
  </tr>
% }
%

</table>
