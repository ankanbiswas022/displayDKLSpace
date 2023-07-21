% This program returns the xy coordinates of the primaries, white point and
% maximum luminance value of the monitor. This information is obtained when
% the icc profile of the monitor is created. Hence a separate entry needs
% to be made for every icc profile.

% When the ICC profile is created, we need to set the brigthness (B) value,
% contrast (C) level and also the white point (usually D65). We include
% these details in the name of the ICC profile, along with name of the rig
% and the date.

% The x and y coordinates of the primaries are initially obtained from the
% ICC profile. Note that when the spectra are measured using the
% spectroradiometer and xyY values are calculated from those, the xy values
% of the primaries may be slightly different. We may choose to use either
% the ones from the ICC profile or the spectrum, but it must be
% consistently used in both Lablib and Matlab codes here.

% In addition, we store the luminance values of white and background (50%)
% using the spectroradiometer and save these values here. These are used to
% normalize the luminace values later.

function [CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(rigName,monitorName,profileDate,BCDVals)

if ~exist('rigName','var');     rigName = 'Rig1Display';                end
if ~exist('monitorName','var'); monitorName = 'BenQXL2411Z';            end
if ~exist('profileDate','var'); profileDate = '230423';                 end
if ~exist('BCDVals','var');     BCDVals = [25 50 65];                   end
    
profileName = [rigName '_' monitorName '_' profileDate '_B' num2str(BCDVals(1)) 'C' num2str(BCDVals(2)) 'D' num2str(BCDVals(3))];

if strcmp(profileName,'Rig1Display_BenQXL2411Z_230423_B25C50D65')

    % This was used for experiments on dona. We used xy coordinates from the
    % ICC profile
    CIEx.r = 0.645;
    CIEx.g = 0.327;
    CIEx.b = 0.160;

    CIEy.r = 0.329;
    CIEy.g = 0.608;
    CIEy.b = 0.066;

    % D65 white point (CIE 1931, 2 degree observer)
    CIEx.w = 0.31271; 
    CIEy.w = 0.32902;

    Y_Max = 122.5; % cd/m2 - obtained using the spectroradiometer data
    Y_BG = 55.06; % cd/m2 - obtained using the spectroradiometer data
end
end