<%args>
    $.companies
    $.user
</%args>
<%init>
    use App::Utils;
</%init>

% if ($.user()->{is_admin}) {
<a href="/companies/add">New company</a>
% }

<h1>List of all companies:</h1>

<table class="list">
  <tr>
    <th>Name<th>
  <tr>
% my $i = 0;
% for my $u (@{$.companies}) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td><a href="/company/<% $u->{id} %>"><% $u->{name} %></a></td>
%     if ($.user()->{is_admin}) {
    <td>
        <a href="/company/<% $u->{id} %>/edit">edit</a>
    </td>
    <td>
        <form method="post" action="/company/<% $u->{id} %>/delete">
          <input type="submit" value="delete" />
        </form>
    </td>
%     }
    <td>
          
    </td>

  </tr>
% }
%

</table>
