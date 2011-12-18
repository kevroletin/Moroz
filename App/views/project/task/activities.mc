<%args>
    $.activities
    $.task_id
    $.project_id
    $.project
    $.db
    $.role
</%args>
<%init>
    use App::Utils;
    use Data::Dumper;
    
    my $base_path = "/project/" . $.project_id . "/task/" . $.task_id;
</%init>

% if (defined $.role) {
<a href="<% $base_path %>/activities/add">New activity</a>
% }

<h1>Activities on current task</h1>

<table class="list">
  <tr>
    <th>Name</th>
    <th>User</th>
    <th>Started</th>
    <th>Finished</th>
  </tr>


% my $i = 0;
% my $activities = $.activities;
% for my $u (@$activities) { 
  <tr class="<% even_odd($i++) %>">
% #    <td>id: <% $u->{id} %></td>
    <td>
      <a href="<% $base_path %>/activity/<% $u->{id} %>"><% $u->{name} %></a>
    </td>
    <td>
      <a href="/user/<% $u->{user_id} %>">
        <% $u->{user} %>
      </a>
    </td>
    <td><% $u->{start_time}  =~ /(.*)\./, $1 %>
    </td>
    <td><% $u->{finish_time} ? ($u->{finish_time} =~ /(.*)\./, $1) : '' %>
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
