<%args>
    $.curr_f
    $.f
    $.action
    $.user
</%args>
% $.curr_f->('project');

<p>
<a href="/project/<% $.f->('id') %>/companies">companies</a>
<a href="/project/<% $.f->('id') %>/users">users</a>
<a href="/project/<% $.f->('id') %>/tasks">tasks</a>
<p>


% if (defined $.action) {

  <form id="<% $.curr_f->('project') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

% if ($.action eq '/projects/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
    </p>
% if ($.action ne '/projects/add') {
    <p> Start date: <% $.f->('start_date') %> </p>
% }
    <p> Description:
        <textarea name="description"/
          ><% $.f->('description') %></textarea>
    </p>
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

% } else {
% $.curr_f->('project');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Start date:
      <% $.f->('start_date') %>
    </p>
    <p> Description:
      <% $.f->('description') %>
    </p>
  </div>

% }
