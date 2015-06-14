function summary = doctestdrv(what, directives, summary)

% for now, always print to stdout
fid = 1;

% get terminal color codes
[color_ok, color_err, color_warn, reset] = doctest_colors(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect all targets to be tested.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
targets = [];
for i=1:numel(what)
  targets = [targets; doctest_collect(what{i})];
end


summary.num_targets = summary.num_targets + length(targets);


% run all tests
for i=1:numel(targets)
  % run doctests for target and update statistics
  target = targets(i);
  fprintf(fid, '%s %s ', target.name, repmat('.', 1, 55 - numel(target.name)));

  % extraction error?
  if target.error
    summary.num_targets_with_extraction_errors = summary.num_targets_with_extraction_errors + 1;
    fprintf(fid, [color_err  'EXTRACTION ERROR' reset '\n\n']);
    fprintf(fid, '    %s\n\n', target.error);
    continue;
  end

  % run doctest
  results = doctest_run(target.docstring, directives);

  % determine number of tests passed
  num_tests = numel(results);
  num_tests_passed = 0;
  for j=1:num_tests
    if results(j).passed
      num_tests_passed = num_tests_passed + 1;
    end
  end

  % update summary
  summary.num_tests = summary.num_tests + num_tests;
  summary.num_tests_passed = summary.num_tests_passed + num_tests_passed;
  if num_tests_passed == num_tests
    summary.num_targets_passed = summary.num_targets_passed + 1;
  end
  if num_tests == 0
    summary.num_targets_without_tests = summary.num_targets_without_tests + 1;
  end

  % pretty print outcome
  if num_tests == 0
    fprintf(fid, 'NO TESTS\n');
  elseif num_tests_passed == num_tests
    fprintf(fid, [color_ok 'PASS %4d/%-4d' reset '\n'], num_tests_passed, num_tests);
  else
    fprintf(fid, [color_err 'FAIL %4d/%-4d' reset '\n\n'], num_tests - num_tests_passed, num_tests);
    for j = 1:num_tests
      if ~results(j).passed
        fprintf(fid, '   >> %s\n\n', results(j).source);
        fprintf(fid, [ '      expected: ' '%s' '\n' ], results(j).want);
        fprintf(fid, [ '      got     : ' color_err '%s' reset '\n' ], results(j).got);
        fprintf(fid, '\n');
      end
    end
  end
end

end
