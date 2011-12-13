<%args>
    $.users
</%args>

<table>
% 
% my $users = $.users;
% for my $u (@$users) { 
  <tr>
    <td>id: <% $u->{id} %></td>
    <td>Name: <% $u->{name} %></td>
    <td>Is admin: 
      <% ['not admin', 'admin']->[$u->{is_admin}] %>
    </td>
  </tr>
% }
%

</table>
