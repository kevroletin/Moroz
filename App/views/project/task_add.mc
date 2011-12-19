<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
    $.project
    $.project_id
    $.log_sql
    $.is_manager
    $.error
    $.message
</%args>
<%init>
    use Data::Dumper;
</%init>

<h1>Add new task for current project</h1>

<form id="<% $.curr_f->('task') %>"
      method="post"
      action="<% '/project/' . $.project_id . '/tasks/add' %>" >

  <div class="message_box">
    <div class="message"><% $.message %></div>
    <div class="error"><% $.error %></div>
  </div>

  <table class="edit">
    <tr>
      <th>Name:</th>
      <td>
        <input type="text" name="name" />
      </td>
    </tr>
    <tr>
      <th>Estimate time:</th>
      <td>
        <input type="text" name="estimate_time" value="00:00:00" /> 
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
  </table>
</form>

