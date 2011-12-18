<%args>
    $.projects
    $.user
</%args>
<%init>
    use App::Utils;
</%init>

% if ($.user()->{is_admin}) {
<a href="projects/add">New project</a>
% }

<h1>List of all projects</h1>

<table class="list">
  <tr>
    <th>Name</th>
    <th>Start date</th>
    <th>Project</th>
  </tr>
% my $i = 0;
% for my $u (@{$.projects}) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td>
      <a href="project/<% $u->{id} %>"><% $u->{name} %>
    </td>
    <td><% $u->{start_date} %></td>
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
