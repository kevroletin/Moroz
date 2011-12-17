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
% #    <td>id: <% $u->{id} %></td>
    <td>Name: 
        <a href="user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>
      <% ['not admin', 'admin']->[$u->{is_admin} ? 1 : 0] %>
    </td>
    <td>Company: 
      <a href="/company/<% $u->{company_id} %>">
        <% $u->{company} %>
      </a>
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
