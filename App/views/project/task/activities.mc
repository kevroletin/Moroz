<%args>
    $.activities
    $.task_id
    $.project_id
    $.project
    $.db
    $.role
</%args>
<%init>
    use Data::Dumper;
    
    my $base_path = "/project/" . $.project_id . "/task/" . $.task_id;
</%init>

% if (defined $.role) {
<a href="<% $base_path %>/activities/add">New activity</a>
% }

<table>
% 
% my $activities = $.activities;
% for my $u (@$activities) { 
  <tr>
% #    <td>id: <% $u->{id} %></td>
    <td>Name: 
        <a href="<% $base_path %>/activity/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>User: 
      <a href="/user/<% $u->{user_id} %>">
        <% $u->{user} %>
      </a>
    </td>
    <td>Started: <% $u->{start_time} %>
    </td>
    <td>Finished: <% $u->{finish_time} %>
    </td>
    <td>
    </td>

%     if (0 && $.user()->{is_admin}) {
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
