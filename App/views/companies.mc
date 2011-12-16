<%args>
    $.companies
    $.user
</%args>

% if ($.user()->{is_admin}) {
<a href="companies/add">New company</a>
% }

<table>
% 
% for my $u (@{$.companies}) { 
  <tr>
    <td>id: <% $u->{id} %></td>
    <td>Name: <% $u->{name} %></td>
    <td>
      <a href="company/<% $u->{id} %>">viev</a>
    </td>
%     if ($.user()->{is_admin}) {
    <td>
        <a href="company/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/company/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
%     }
  </tr>
% }
%

</table>
