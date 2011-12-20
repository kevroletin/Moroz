<%args>
    $.error
    $.message
    $.data
    $.tasks
    $.extra
</%args>
<%init>
    use Data::Dumper;

    my $t = $.tasks;
    my $t_h = $.data;
    my $first_time = $.extra->{first_time};
    my $last_time = $.extra->{last_time};

print "<pre>";
#print Dumper $t, $t_h, $first_time, $last_time;
print Dumper $t_h;
print "</pre>";


</%init>

% my $svg_height = @$t * 20;
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:xlink="http://www.w3.org/1999/xlink"
     class="chart"
     width="1000" height="<% $svg_height %>"
     viewBox="0 0 1000 <% $svg_height %>"
     preserveAspectRatio="none">

  <desc>This graphic links to an external image
  </desc>

% my $coord_start = $first_time;
% my $coord_width = time() - $first_time; #$last_time - $first_time;
<g transform="translate(0, 0)">
<svg viewBox="<% $coord_start  %> 0 <% $coord_width %> <% $svg_height %>"
     preserveAspectRatio="none">

% my $i = 0;
% for (@$t) {
%    my ($id) = $_->[0];
%    my $y = $i * 20;
%    my $x1 = $t_h->{$id}{x1};
%    my $x2 = $t_h->{$id}{x2};
%    my $status = $t_h->{$id}{status} || 'not_started';
%    my $color = { not_started => 'yellow',
%                  in_progress => 'green',
%                  finished => 'blue' }->{$status};
%    $x1 ||= 0; $x2 ||= 0;
%

  <rect y="<% $y %>" x="<% $x1 %>" height="20" width="<% $x2 - $x1 %>" fill="<% $color %>" >
  </rect>

%   ++$i;
% }

</svg>

<svg viewBox="0 0 1000 <% $svg_height %>"
     preserveAspectRatio="none">


% $i = 0;
% for (@$t) {
%    my ($id, $name) = @$_;
%    my $y = $i*20 + 15;
%    my $x = 0;
  <text x="<% $x %>" y="<% $y %>"><% $id %>:<% $name %>:</text>
%   ++$i;
% }

</svg>

</g>

% for my $j (0 .. 10) {
%   my $x = 100 * $j;
<line x1="<% $x %>" x2="<% $x %>" y1="0" y2="<% $svg_height  %>" stroke="black" />
<%perl>
    my $date = $coord_start + ($coord_width / 10) * $j;
    my ($year,$month,$day, $h, $min) =
        Date::Calc::Time_to_Date($date);
</%perl>
    <text x=<% $x %> y=<% 15 %> >
      <% $month %>-<% $day %> <% $h %>:<% $min %>
    </text>
% }


</svg>




</pre>
