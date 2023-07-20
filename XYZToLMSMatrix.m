% type: 'SS' for Stockman Sharpe; 'SP' for Smith Pokorny

% Note that LMS values are not what we get by simply integrating the CFs
% with the spectrum. Instead, they are scaled such that L+M = Luminance

function M = XYZToLMSMatrix(type)

if ~exist('type','var');        type='SP';                              end

if strcmp(type,'SS')
    % M_LMSToXYZ = [1.94735469 -1.41445123 0.36476327;
    %               0.68990272  0.34832189 0;
    %               0           0          1.93485343];
    % M = diag([0.68990272  0.34832189 0.0371597]) * inv(M_LMSToXYZ);

    M = [0.145277 0.5899342 -0.027387;
        -0.145277 0.4100658  0.027387;
        0         0          0.019205];

elseif strcmp(type,'SP')
    M = [0.15514 0.54312  -0.03286;
        -0.15514 0.45684  0.03286;
         0       0        0.01608];
end
end