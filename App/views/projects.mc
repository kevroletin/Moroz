<%args>
    $.projects
    $.user
</%args>

% if ($.user()->{is_admin}) {
<a href="projects/add">New project</a>
% }

<table>
% 
% for my $u (@{$.projects}) { 
  <tr>
% #    <td>id: <% $u->{id} %></td>
    <td>Name: 
      <a href="project/<% $u->{id} %>"><% $u->{name} %>
    </td>
    <td>Start date: <% $u->{start_date} %></td>
    <td>
      
    </td>
%     if ($.user()->{is_admin}) {
    <td>
        <a href="project/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/project/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
%     }
  </tr>
% }
%

</table>
