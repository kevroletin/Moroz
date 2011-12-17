<%args>
    $.user
    $.tasks_sth
    $.project_id
</%args>
% use Data::Dumper;

% if ($.user()->{is_admin}) {
<a href="tasks/add">New task</a>
% }

<table>
% 
% while (my $u = $.tasks_sth->fetchrow_hashref()) { 
  <tr>
% #    <td>id: <% $u->{id} %></td>
    <td>Name: 
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
