<%args>
    $.users
    $.user
</%args>
<%init>
    use App::Utils;
</%init>

% if ($.user()->{is_admin}) {
<a href="users/add">New user</a>
% }

<h1>List of all users</h1>

<table class="list">
  <tr>
    <th>Name</th>
    <th>Permissions</th>
    <th>Company</th>
  </tr>

% my $i = 0;
% my $users = $.users;
% for my $u (@$users) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td>
        <a href="user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>
      <% ['not admin', 'admin']->[$u->{is_admin} ? 1 : 0] %>
    </td>
    <td>
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
