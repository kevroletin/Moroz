<%args>
    $.contracts
    $.user
</%args>
<%init>
    use App::Utils;
</%init>

% if ($.user()->{is_admin}) {
<a href="contracts/add">New contract</a>
% }

<h1>List of all contracts</h1>

<table class="list">
  <tr>
    <th>Name</th>
    <th>Company</th>
    <th>Project</th>
    <th>Status</th>
  </tr>

% my $i = 0;
% for my $u (@{$.contracts}) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td><a href="contract/<% $u->{id} %>">
        <% $u->{name} %></a>
    </td>
    <td> 
      <a href="/company/<% $u->{company_id} %>">
        <% $u->{company} %>
      </a>
    </td>
    <td> 
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
