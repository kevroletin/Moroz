<%args>
    $.contracts
    $.user
</%args>

% if ($.user()->{is_admin}) {
<a href="contracts/add">New contract</a>
% }

<table>
% 
% for my $u (@{$.contracts}) { 
  <tr>
% #    <td>id: <% $u->{id} %></td>
    <td>Name: <a href="contract/<% $u->{id} %>">
        <% $u->{name} %></a>
    </td>
    <td>Company: 
      <a href="/company/<% $u->{company_id} %>">
        <% $u->{company} %>
      </a>
    </td>
    <td>Project: 
      <a href="/project/<% $u->{project_id} %>">
        <% $u->{project} %>
      </a>
    </td>
    <td>
      <% $u->{'is_active'} ? 'active' : 'not active' %>
    </td>
%     if ($.user()->{is_admin}) {
    <td>
        <a href="contract/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/contract/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
%     }
  </tr>
% }
%

</table>
