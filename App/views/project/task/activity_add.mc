<%args>
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
SQL
);
    $users_sth->execute();
</%init>

<form id="activity" method="post"
      action="<% $base_path %>/activities/add" >
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
        <select name="user_project_item_id">
%  while (my $u = $users_sth->fetchrow_hashref()) {
          <option value="<% $u->{id} %>"><% $u->{user} %></option>
%  }
       </select>
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
    </table>
  
</form>

