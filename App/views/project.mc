<%args>
    $.error
    $.message
    $.curr_f
    $.f
    $.action
    $.user
</%args>
% $.curr_f->('project');

<p>
  <a href="/project/<% $.f->('id') %>/chart">Gantt chart</a>
  <a href="/project/<% $.f->('id') %>/companies">companies</a>
  <a href="/project/<% $.f->('id') %>/users">users</a>
  <a href="/project/<% $.f->('id') %>/tasks">tasks</a>
<p>


% if (defined $.action) {

  <form id="<% $.curr_f->('project') %>"
        method="post"
        action="<% $.action %>" >

    <div class="message_box">
      <div class="message"><% $.message %></div>
      <div class="error"><% $.error %></div>
    </div>

    <table class="edit">
    <tr>
      <th>Name:</th>
      <td>
% if ($.action eq '/projects/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
      </td>
    </tr>
% if ($.action ne '/projects/add') {
    <tr>
      <th>Start date:</th>
      <td><% $.f->('start_date') %></td>
    </tr>
% }
    <tr>
      <th>Description:</th>
      <td>
        <textarea name="description"/
          ><% $.f->('description') %></textarea>
      </td>
    </tr>
    <tr>
      <td>
        <input type="submit" name="ok" value="submit" />
      </td>
    </tr>
    </table>
  </form>

% } else {
% $.curr_f->('project');

<h1>View project</h1>

  <div>
    <table class="edit">
    <tr>
      <th>Name:</th>
      <td><% $.f->('name') %></td>
    </tr>
    <tr>
      <th>Start date:</th>
      <td><% $.f->('start_date') %></td>
    </tr>
    <tr>
      <th>Description:</th>
      <td><% $.f->('description') %></td>
    </tr>
    </table>
  </div>

% }
