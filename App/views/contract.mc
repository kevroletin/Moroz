<%args>
    $.curr_f
    $.f
    $.action
    $.user
    $.db
</%args>
% $.curr_f->('contract');
% my $contract_id = $.f->('id');
% my @proj = $.db->quick_select('projects', {});

% if (defined $.action) {

  <form id="<% $.curr_f->('contract') %>"
        method="post"
        action="<% $.action %>" >
    <p> Name:

% if ($.action eq '/contracts/add') {
      <input type="text" name="name" value="<% $.f->('name') %>" />
% } else {
    <% $.f->('name') %>
% }
    </p>
    <p> Project:
      <select name="project_id">
% for (@proj){
        <option value="<% $_->{id} %>"
          <% (defined $.f->('project_id') && 
              $_->{id} eq $.f->('project_id')) ? 'selected="selected"' : '' %>>
          <% $_->{name} %>
        </option>
% }
      </select>
    </p>
    
    <p>
      <input type="submit" name="ok" value="submit" />
    </p>

  </form>

<hr />

% if ($.user->{is_admin}) {
%   $.curr_f->('contract');
%   my $sub_q = 
% "select company_id from company_contract_items " .
% "  where contract_id = " . $.f->('id');
%   my $q = 
% "select * from companies where id not in ($sub_q)";
%   print STDERR "********************\n$q\n";
%   my $sth = $.db->prepare($q);
%   $sth->execute();
%   my @comp; 
%   while(my $r = $sth->fetchrow_hashref()) { push @comp, $r };

%   if (@comp) {
<form method="post"
      action="/contract/<% $.f->('id') %>/companies/add">
  <p>Add new company:</p>
  <p>
    <select name="company_id">
%     for (@comp) {
     <option value="<% $_->{id} %>">
      <% $_->{name} %>
      </option>
%     }
    </select>
    <input type="submit" name="ok" value="add" />
  </p>
</form>
%   }

% }


% } else {
% $.curr_f->('contract');

  <div>
    <p> Name:
      <% $.f->('name') %>
    </p>
    <p> Project: 
      <a href="/project/<% $.f->('project_id') %>">
        <% $.f->('project') %>
      </a>
  </div>

% }

<p>Companies working on this contract:</p>
<table>
% my $q = 
% "select * from company_contract_items " .
% " join companies on company_id = id ".
% "where contract_id = $contract_id";
% my $sth = $.db->prepare($q);
% $sth->execute();
% while (my $r = $sth->fetchrow_hashref) {
  <tr>
    <td>Name: <a href='/company/<% $r->{company_id} %>'>
        <% $r->{name} %>
        </a>
    </td>
%   if ($.user()->{is_admin}) {
    <td>
        <form method="post" 
              action="/contract/<% $contract_id %>/company/<% $r->{id} %>/delete" >
          <input type="submit" value="remove" />
        </form>
    </td>
%   }

  </tr>
% }
</table>
