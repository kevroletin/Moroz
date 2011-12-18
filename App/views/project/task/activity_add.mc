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
  
  <p> Name:
    <input type="text" name="name" />
  </p>
  <p> Desctiption:
    <textarea name="description"></textarea>
  </p>
  <p>Assigned to:
    <select name="user_project_item_id">
%  while (my $u = $users_sth->fetchrow_hashref()) {
      <option value="<% $u->{id} %>"><% $u->{user} %></option>
%  }
    </select>
  </p>

  <p>
    <input type="submit" name="ok" value="submit" />
  </p>
  
</form>

