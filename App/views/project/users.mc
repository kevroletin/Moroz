<%args>
    $.user
    $.project
    $.project_id
    $.db
</%args>
% use Data::Dumper;

<h4> Users working in project: </h4>

<table>
% my $usr_in_proj_q;
% my $sth = $.db->prepare( $usr_in_proj_q =
% "select u.id, u.name, u.company, role from users_full u " .
% "  join user_project_items on user_id = u.id " .
% "  where user_project_items.project_id = " .$.project_id );
% $sth->execute();
%
% while (my $u = $sth->fetchrow_hashref()) { 
  <tr>
    <td>id: <% $u->{id} %></td>
% #    <td><pre><% Dumper $u %></pre></td>

    <td>Name: 
      <a href="/user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>Company: <% $u->{company} %></td>
    <td>Role: <% $u->{role} %></td>
%   if ($.user()->{is_admin}) {
    <td>
      <form method="post" action="/project/<% $.project_id %>/users/delete">
        <input type="hidden" name="user_id" value="<% $u->{id} %>" />
        <input type="submit" value="delete" />
      </form>
    </td>
%   }
  </tr>
% }
%
</table>

<h4> Add user to project: </h4>

% if ($.user()->{is_admin}) {

<table>
% my $q;
% $sth = $.db->prepare( $q = 
% "select * from users_full where company_id in ( " .
% "  select company_id from company_contract_items " .
% "  where contract_id in ( " .
% "    select id from contracts where project_id = " . 
%        $.project_id . " )) " .
% "and id not in ( " .
% "  select user_id from user_project_items " .
% "  where project_id = " . $.project_id . " ) " );
% print STDERR "**********: $q";
% $sth->execute();
%
% while (my $u = $sth->fetchrow_hashref()) { 
  <tr>
    <td>Name: 
      <a href="/user/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>Company: <% $u->{company} %></td>
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
