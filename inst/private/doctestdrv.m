function summary = doctestdrv(what, directives, summary, recursive, fid)

% get terminal color codes
[color_ok, color_err, color_warn, reset] = doctest_colors(fid);


if (exist(what, 'dir'))
  if (~ strcmp(what, '.'))
    fprintf(fid, 'Descending into directory "%s"\n', what);
  end
  oldcwd = chdir(what);
  files = dir('.');
  for i=1:numel(files)
    f = files(i).name;
    if strcmp(f, '.') || strcmp(f, '..') || strcmpi(f, 'private')
      % skip ., .., and private folders (TODO)
      continue
    end
    if (f(1) == '@')
      % strip the @, prevents processing as a directory
      f = f(2:end);
    elseif (~ recursive && exist(f, 'dir'))
      % skip directories
      continue
    end
    summary = doctestdrv(f, directives, summary, recursive, fid);
  end
  chdir(oldcwd);
  return
end


targets = doctest_collect(what);

% update summary
summary.num_targets = summary.num_targets + numel(targets);


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
