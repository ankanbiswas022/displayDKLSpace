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
% consistently used in both Lablib and Matlab codes here. The input
% sourceType determines whether xy values are from 'icc' or 'data'

% In addition, we store the luminance values of white and background (50%)
% using the spectroradiometer and save these values here. These are used to
% normalize the luminace values later.

function [CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(computerName,profileDate,sourceType)

if ~exist('computerName','var');     computerName = 'Rig1Display';      end
if ~exist('profileDate','var'); profileDate = '230423';                 end
if ~exist('sourceType','var');  sourceType = 'icc';                     end

profileName = [computerName '_' profileDate];

if strcmp(profileName,'Rig1Display_230423')

    if strcmp(sourceType,'icc')
        % We use xy coordinates from the ICC profile
        CIEx.r = 0.645;
        CIEx.g = 0.327;
        CIEx.b = 0.160;

        CIEy.r = 0.329;
        CIEy.g = 0.608;
        CIEy.b = 0.066;

        % D65 white point (CIE 1931, 2 degree observer)
        CIEx.w = 0.3456; % expected - 0.31271 for D65;
        CIEy.w = 0.3586; % expected - 0.32902 for D65;

        Y_Max = 121; % from 'lumi' variable in ICC profile
        Y_BG = Y_Max/2;

    else 
        % We use xy coordinates from the spectroradiometer data.
        % Can be read from the csv file Rig1Display_240423_XYZ
        % M75: R, M76: G, M77: B, W: M78, Gray: M80.
        % indexList = 76:81;
        % cieStimsAll = readtable(fullfile("MonitorCalibrationLogs/Rig1Display/Rig1Display_240423_XYZ.csv"));
        % xList =  table2array(cieStimsAll(8,indexList));
        % yList =  table2array(cieStimsAll(9,indexList));
        % YList =  table2array(cieStimsAll(3,indexList));

        CIEx.r = 0.6411; % xList(1)
        CIEx.g = 0.3065; % xList(2)
        CIEx.b = 0.1530; % xList(3)

        CIEy.r = 0.3296; % yList(1)
        CIEy.g = 0.6113; % yList(2)
        CIEy.b = 0.0590; % yList(3)

        % White Point
        CIEx.w = 0.3179; % xList(6) - chosen for gray
        CIEy.w = 0.3352; % yList(6) - chosen for gray

        Y_Max = 122; % cd/m2 YList(4)
        Y_BG = 55.3; % cd/m2 YList(6)
    end

elseif strcmp(profileName,'Rig4Analysis_200723')

    if strcmp(sourceType,'icc')
        CIEx.r = 0.644;
        CIEx.g = 0.325;
        CIEx.b = 0.160;

        CIEy.r = 0.329;
        CIEy.g = 0.606;
        CIEy.b = 0.065;

        % D65 white point (CIE 1931, 2 degree observer)
        CIEx.w = 0.3456; % expected - 0.31271 for D65;
        CIEy.w = 0.3586; % expected - 0.32902 for D65;
        
        Y_Max = 119.57; % from 'lumi' variable in ICC profile
        Y_BG = Y_Max/2;
    else
        % tmp = load(fullfile("MonitorCalibrationLogs/Rig4Analysis/Rig4Analysis_220723_DCM.mat"));
        % %        Indices for 50% Gray: 6, white: 11, Red: 22, Green: 33 and Blue: 44.
        % xyYGray = [tmp.LumValues(6).xyYJudd];
        % xyYW = [tmp.LumValues(11).xyYJudd];
        % xyYR = [tmp.LumValues(22).xyYJudd];
        % xyYG = [tmp.LumValues(33).xyYJudd];
        % xyYB = [tmp.LumValues(44).xyYJudd];

        CIEx.r = 0.6405; % xyYR(1)
        CIEx.g = 0.3092; % xyYG(1)
        CIEx.b = 0.1568; % xyYB(1)

        CIEy.r = 0.3332; % xyYR(2)
        CIEy.g = 0.6156; % xyYG(2)
        CIEy.b = 0.0713; % xyYB(2)

        % White Point
        CIEx.w = 0.3230; % xyYGray(1)
        CIEy.w = 0.3478; % xyYGray(2)

        Y_Max = 125.1697; % cd/m2 xyYW(3)
        Y_BG = 65.0850; % cd/m2 xyYGray(3)
    end
end
end