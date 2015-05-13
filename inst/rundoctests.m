function varargout = rundoctests(directory, recursion, logfile)
% Run all doctests in given directory.
%
% Usage
% =====
%
% rundoctests DIRECTORY
% rundoctests(DIRECTORY, RECURSION)
% rundoctests(DIRECTORY, RECURSION, LOGFILE)
% SUCCESS = rundoctests(...)
%
% The parameter DIRECTORY contains the name of the directory for which to run
% all doctests. It can also be a cell array of directories.
%
% If the optional parameter RECURSION is true then rundoctests recurses into
% all subdirectories. By default, RECURSION is 0.
%
% The optional parameter LOGFILE is not implemented yet.
% 
%
% When called with a single return value, return whether all tests have
% succeeded.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process parameters.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% print usage?
if nargin < 1
  help rundoctests;
  return;
end

% if given a single object, wrap it in a cell array
if ~iscell(directory)
  directory = {directory};
end

% mode is always 'normal'
if nargin < 2
  recursion = 0;
end

% by default, do not print to a logfile
if nargin < 3
  logfile = '';
else
  error('NOT IMPLEMENTED YET.');
end

% determine if running with octave
try
  OCTAVE_VERSION;
  running_octave = 1;
catch
  running_octave = 0;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find all test targets.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% determine absolute paths
for i=1:numel(directory)
  directory{i} = abspath(directory{i});
end

% collect targets
targets = {};
for i=1:numel(directory)
  targets = [targets; find_targets(directory{i}, recursion)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run all tests.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
success = doctest(targets);

if nargout == 1
  varargout = {success};
end


function absdir = abspath(dir)
  if running_octave
    % make absolute filename (XXX: does not work in matlab)
    absdir = make_absolute_filename(dir);

    % if that one does not exist, try to find match in path
    if ~exist(absdir, 'dir')
      absdir = find_dir_in_path(dir);
    end
  else
    % build absolute path following Jonathan Karr's recipe from http://www.mathworks.com/matlabcentral/fileexchange/29768-absolutepath (XXX: replace by something more sane)
    file = java.io.File([dir]);
    absdir = char(file.getCanonicalPath());
  end
  if isempty(absdir)
    error('DIRECTORY not found: %s', dir);
  end
end

function targets = find_targets(directory, recursion)
  targets = {};
  files = dir(directory);
  for i=1:numel(files)
    % skip ., .., and private folders (XXX: should we skip the latter?)
    f = files(i).name;
    if strcmp(f, '.') || strcmp(f, '..') || strcmpi(f, 'private')
      continue
    end
    abspath = fullfile(directory, f);

    % matlab file?
    if length(f) > 2 && strcmpi(f(end - 1:end), '.m')
      targets = [targets; abspath];
      continue
    end

    % recurse? (always recurse into classes)
    if files(i).isdir && (f(1) == '@' || recursion)
      targets = [targets; find_targets(abspath, recursion)];
    end
  end
end

end
