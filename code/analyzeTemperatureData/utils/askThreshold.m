function num = askThreshold()
%ASKNUMBER Ask the user to enter a valid number between 0 and 200.
%   NUM = ASKNUMBER() shows "Insert threashold [0, 200]:" in the command window and 
%   waits until the user enters a valid numeric value in the range [0,200].
%
%   Example:
%       x = askNumber();

    valid = false;

    while ~valid
        userInput = input('Insert threashold [0, 200]: ', 's'); % leggo sempre come stringa
        num = str2double(userInput);    % provo a convertire in numero

        if ~isnan(num) && num >= 0 && num <= 200
            valid = true;
        else
            fprintf('Invalid input. Please enter a number between 0 and 200.\n');
        end
    end
end
