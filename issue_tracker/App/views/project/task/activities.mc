<%args>
    $.activities
    $.task_id
    $.project_id
    $.project
    $.db
    $.role
    $.work_on_activity
</%args>
<%init>
    use App::Utils;
    use Data::Dumper;
    
    my $base_path = "/project/" . $.project_id . "/task/" . $.task_id;
</%init>

% if (defined $.role) {
%   if ($.role eq 'developer' && defined $.work_on_activity) {
Can't add new activity. Currently working on
<a href="<% $base_path %>/activity/<% $.work_on_activity->{id} %>">
 <% $.work_on_activity->{name} %>
</a>
%   } else {
<a href="<% $base_path %>/activities/add">New activity</a>
%   }
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

%     if (0 && $.role eq 'manager') {
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
