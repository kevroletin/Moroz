<%args>
    $.users
    $.user
</%args>

% if ($.user()->{is_admin}) {
<a href="users/add">New user</a>
% }

<table>
% 
% my $users = $.users;
% for my $u (@$users) { 
  <tr>
    <td>id: <% $u->{id} %></td>
    <td>Name: <% $u->{name} %></td>
    <td>Is admin: 
      <% ['not admin', 'admin']->[$u->{is_admin} ? 1 : 0] %>
    </td>
    <td>Company: <% $u->{company} %></td>
    <td>
      <a href="user/<% $u->{id} %>">viev</a>
    </td>
%     if ($.user()->{is_admin}) {
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

</table>
