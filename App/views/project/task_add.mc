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
</%args>
<%init>
    use Data::Dumper;

</%init>

  <form id="<% $.curr_f->('task') %>"
        action="<% '/project/' . $.project_id . '/tasks/add' %>" >

    <p> Name:

      <input type="text" name="name" value="<% $.f->('name') %>" />

    </p>
    <p> Estimate time: 
      <input type="text" name="estimate_time" value="<% $.f->('estimate_time') %>" /> 
    </p>

    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

