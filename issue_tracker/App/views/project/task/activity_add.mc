<%args>
    $.error
    $.message
    $.user
    $.task_id
    $.project_id
    $.db
    $.role
    $.curr_f
    $.f
</%args>
<%init>
    use Data::Dumper;
    
    my $project_id = $.project_id;
    my $base_path = "/project/" . $.project_id . "/task/" . $.task_id;
    my $users_sth = $.db()->prepare( <<SQL
select * from user_project_items_full 
where project_id = $project_id
and user_id not in (
  select u.id from users u
    join user_project_items up on u.id = up.user_id
    join activity_on_task a on up.id = a.user_project_item_id
  where a.finish_time is null
)
SQL
);

</%init>

<h1>Add activity on current task</h1>

<form id="activity" method="post"
      action="<% $base_path %>/activities/add" >

  <div class="message_box">
    <div class="message"><% $.message %></div>
    <div class="error"><% $.error %></div>
  </div>

  <table class="edit">
    <tr>
      <th>Name</th>
      <td>
        <input type="text" name="name" />
      </td>
    </tr>
    <tr>
      <th>Desctiption:</th>
      <td>
        <textarea name="description"></textarea>
      </td>
    </tr>
    <tr>
      <th>Assigned to:</th>
      <td>
%  if ($.role eq 'manager') {
        <select name="user_project_item_id">
%      $users_sth->execute();
%      while (my $u = $users_sth->fetchrow_hashref()) {
          <option value="<% $u->{id} %>"><% $u->{user} %></option>
%      }
       </select>
%  } else {
       <% $.user->{name} %>
%  }
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
    </table>
  
</form>

