<%args>
    $.user
    $.project
    $.project_id
    $.db
    $.log_sql
</%args>
<%init>
  use App::Utils;
  use Data::Dumper;
  my $project_id = $.project_id;
  my $q;

  my $usr_proj_sth = $.db->prepare( $q = <<SQL
select u.id, u.name, u.company, u.company, 
       u.company_id, role from users_full u 
  join user_project_items on user_id = u.id 
  where user_project_items.project_id = $project_id
SQL
);
  $.log_sql->($q);

  my $usr_not_proj_sth = $.db->prepare( $q = <<SQL
select * from users_full where company_id in ( 
  select company_id from contracts 
  where project_id = $project_id
)
and id not in (
  select user_id from user_project_items
  where project_id = $project_id
)
SQL
);
  $.log_sql->($q);
 
</%init>

<h1> Users working in project: </h1>

% my $i = 0;
<table class="list">
  <tr>
    <th>Name</th>
    <th>Company</th>
    <th>Role</th>
  </tr>

% $usr_proj_sth->execute();
% while (my $u = $usr_proj_sth->fetchrow_hashref()) { 
  <tr class="<% even_odd($i++) %>">
    <td>
      <a href="/user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>
      <a href="/company/<% $u->{company_id} %> ">
        <% $u->{company} %>
      </a>
    </td>
    <td><% $u->{role} %></td>
%   if ($.user()->{is_admin}) {
    <td>
      <form method="post" action="/project/<% $.project_id %>/users/delete">
        <input type="hidden" name="user_id" value="<% $u->{id} %>" />
        <input type="submit" value="remove" />
      </form>
    </td>
%   }
  </tr>
% }
%
</table>

% if ($.user()->{is_admin}) {

<br />
<br />
<h2> Add user to project: </h2>


<table class="list">
  <tr>
    <th>Name</th>
    <th>Company</th>
    <th>Role</th>
  </tr>

% my $i = 0;
% $usr_not_proj_sth->execute();
% while (my $u = $usr_not_proj_sth->fetchrow_hashref()) { 
  <tr class="<% even_odd($i++) %>">
    <td> 
      <a href="/user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>
      <a href="/company/<% $u->{company_id} %> ">
        <% $u->{company} %>
      </a>
    </td>
    <td>
        <form method="post" action="/project/<% $.project_id %>/users/add">
          <input type="hidden" name="user_id" value="<% $u->{id} %>" />
          <select name="role">
            <option value="manager">manager</option>
            <option value="developer">developer</option>
          </select>
          <input type="submit" value="add" />
        </form>
    </td>
  </tr>
% }
%
% }



</table>
