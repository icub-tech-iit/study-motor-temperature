function printDiagnosticMarkdown(timestamps, diagnostic)
% SHOWDIAGNOSTICTABLES — Print diagnostic results as aligned ASCII tables.

%% Percentages table
names  = fieldnames(diagnostic.percentage);
values = struct2array(diagnostic.percentage);

fprintf('\n=== Diagnostic Percentages ===\n');
fprintf('+----------------------+----------------+\n');
fprintf('| %-20s | %14s |\n', 'Condition', 'Percentage [%]');
fprintf('+----------------------+----------------+\n');

for i = 1:numel(names)
    fprintf('| %-20s | %14.2f |\n', names{i}, values(i));
end
fprintf('+----------------------+----------------+\n');

%% Overheat regions table
if isfield(diagnostic, 'regions') && isfield(diagnostic.regions, 'OVERHEAT')
    R = diagnostic.regions.OVERHEAT;
    if ~isempty(R)
        durations = timestamps(R.endIdx) - timestamps(R.startIdx);

        fprintf('\n=== Overheat Regions ===\n');
        fprintf('+-----------+-----------+------------------+--------------+\n');
        fprintf('| %-9s | %-9s | %-16s | %-12s |\n', ...
                'StartIdx','EndIdx','Length [samples]','Duration [s]');
        fprintf('+-----------+-----------+------------------+--------------+\n');

        for i = 1:height(R)
            fprintf('| %9d | %9d | %16d | %12.2f |\n', ...
                R.startIdx(i), R.endIdx(i), R.length(i), durations(i));
        end

        fprintf('+-----------+-----------+------------------+--------------+\n');
    else
        fprintf('\n=== Overheat Regions ===\n');
        fprintf('No overheat regions detected.\n');
    end
end

fprintf('\n'); % spacing
end
