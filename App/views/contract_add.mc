<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
</%args>
% $.curr_f->('contract');
% my $contract_id = $.f->('id');

  <form id="<% $.curr_f->('contract') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

      <input type="text" name="name" value="<% $.f->('name') %>" />
    </p>
    
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

