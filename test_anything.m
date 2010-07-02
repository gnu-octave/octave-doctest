function test_anything(results, verbose)

out = 1;

fprintf(out, 'TAP version 13\n')
fprintf(out, '1..%d\n', numel(results));
for I = 1:length(results)
    if results(I).pass
        ok = 'ok';
    else
        ok = 'not ok';
    end
    
    fprintf(out, '%s %d - "%s"\n', ok, I, results(I).source);
    if verbose
        fprintf(out, '    expected: %s\n', results(I).want);
        fprintf(out, '    got     : %s\n', results(I).got);
    end
end
