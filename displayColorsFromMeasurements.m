% This program shows the actual color coordinates obtained from
% measurement of spectrum data

% Rig1Display
% computerName = 'Rig1Display'; profileDate = '230423';
% measurementDate = '240423'; fileExtension = '.csv'; indexList = 1+(45:61); phiList = 0:22.5:360; numColors = 16; % Indices and phi values of DKL colors

% Rig4Analysis
computerName = 'Rig4Analysis'; profileDate = '200723';
measurementDate = '240423'; fileExtension = '.mat'; indexList = 1+(45:61); phiList = 0:10:360; numColors = 36; % Indices and phi values of DKL colors

% From ICC profile
% [CIEx,CIEy] = getMonitorCalibrationDetails(computerName,profileDate,'icc'); % colors based on ICC profile
% RGBTheoretical = generateDKLColors(numColors,CIEx,CIEy);
% displayColors(RGBTheoretical,CIEx,CIEy,[0.5 0.5 0.5],'s');

% From actual data
[CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(computerName,profileDate,'data'); % colors based on ICC profile
RGBTheoretical = generateDKLColors(numColors,CIEx,CIEy);
displayColors(RGBTheoretical,CIEx,CIEy,[0.5 0.5 0.5],'+');

% Get Data
readParentPath = fullfile(pwd,'MonitorCalibrationLogs',computerName);
if strcmp(fileExtension,'.csv')
    fileName      = [computerName '_' measurementDate '_XYZ' fileExtension];
    cieStimsAll = readtable(fullfile(readParentPath,fileName));
    xyYList(1,:) =  table2array(cieStimsAll(8,indexList));
    xyYList(2,:) =  table2array(cieStimsAll(9,indexList));
    xyYList(3,:) =  table2array(cieStimsAll(3,indexList));
end

% Get RGB values of the colors
xyYNormList = xyYList;
xyYNormList(3,:) = xyYList(3,:)/Y_Max;
XYZNormList = xyYToXYZ(xyYNormList);
M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);
RGBList = (M_RGB2XYZ) \ XYZNormList;

RGB_BG = [1 1 1]* Y_BG/Y_Max;
displayColors(RGBList',CIEx,CIEy,RGB_BG,'o');

figure;
% Plot colors in DKL space
for i=1:length(indexList)
    RGB = normalizeRGB(RGBList(:,i));
    plot(phiList(i),xyYList(3,i),'marker','o','color',RGB,'markerfacecolor',RGB);
    hold on;
end
axis([0 360 0 Y_Max]);
xlabel('DKLPhi (degrees); 360^o = gray'); ylabel('Luminance (cd/m2)');
