% octave --eval 'test engine.m' 2>&1 | grep -v /usr/share/octave/3.8.1
% trick to allow multiple functions
1;

% TODO: refactor output generation to wrap a step function in a loop to generate
%       tracks matrix for assertion to keep tests but be able to stream tsv out
% TODO: refactor force function applications to modular design
% TODO: beautify everything with base-n.de/matlab/code_beautifier.html

addpath('../lib/jsonlab');
addpath('../lib/catstruct');

global configuration;

function init (config)
  global configuration;
  defaults = loadjson('defaults.json');
  % if passed a filename, parse as JSON and use for config
  if (ischar(config) && exist(config, 'file'))
    config = loadjson(config);
  end
  configuration = catstruct(defaults, config);
  % disp(configuration);
end

% function tracks = looptest
%   buffer = zeros(configuration.buffer_size, configuration.agents * 2 + 2);
%   buffer(1, 1:2) = [1 0]; % frame 1 is time 0
%   global configuration;

%   % disp('start tracks')
%   tracks = buffer(1,:);
%   tsv_out(tracks);
%   for frame = 2 : configuration.frames
%     % disp('looping!')
%     % disp(frame)
%     % disp(buffer)
%     current_frame = timestep(frame, buffer);
%     % tsv_out(current_frame);
%     tracks = [tracks; current_frame];
%     % disp('-------')
%   end
% end

function loop
  global configuration;
  buffer = zeros(configuration.buffer_size, configuration.agents * 2 + 2);
  buffer(1, 1:2) = [1 0]; % frame 1 is time 0
  buffer(2, 1:2) = [2 1]; % frame 2 is time 1

  tsv_out(buffer(1,:));
  tsv_out(buffer(2,:));
  for frame = 3 : configuration.frames
    % disp('looping!')
    % disp(frame)
    % disp(buffer)
    current_frame = timestep(frame, buffer);
    tsv_out(current_frame);
    % disp('-------')
  end
end

function tsv_out(frame)
  disp(sprintf('%d\t', frame)(1:end-1))
end

function new_index = tminus(n, buffer_zero)
  global configuration;
  new_index = mod(buffer_zero - n - 1, configuration.buffer_size) + 1;
end

% must preload buffer with two frames
function current_frame = timestep(buffer_zero, buffer)
  global configuration;
  % closure to make buffer indexing less verbose
  tminus = @(n) tminus(n, buffer_zero);

  tminus2 = buffer(tminus(2), 3:end);
  tminus1 = buffer(tminus(1), 3:end);
  delta = tminus2-tminus1;

  % for theAgent = 1:configuration.agents
  %   % disp(theAgent)
    
  %   last_position = tminus1(i:1+i);
  %   last_delta = delta(i:1+i);
  %   % current_frame = [current_frame position];
  % end

  % increment frame # and time for current_frame
  frame_time = [buffer(tminus(1), 1) + 1, buffer(tminus(1), 2) + configuration.dt];
  buffer_slot = tminus(0);
  buffer(buffer_slot, :) = [frame_time delta];
  current_frame = buffer(buffer_slot, :);
  % disp('loop end')
end
