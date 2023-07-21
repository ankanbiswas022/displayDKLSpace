% This program shows the actual color coordinates obtained from
% measurement of spectrum data

% Enter the x and y coordinates of the stimulus
readParentPath = fullfile(pwd,'Measurements','Rig1Display');
fileNames      = 'Rig1DisplayProfilingPR655_cieCoordinates';
cieStimsAll = readtable(fullfile(readParentPath,fileNames));

[CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails;

XYZ_List(1,:) =  table2array(cieStimsAll(2,2:end));
XYZ_List(2,:) =  table2array(cieStimsAll(3,2:end));
XYZ_List(3,:) =  table2array(cieStimsAll(4,2:end));

xyY_List = XYZToxyY(XYZ_List);
xyYNorm_List = xyY_List;
xyYNorm_List(3,:) = xyY_List(3,:)/Y_Max;
XYZNorm_List = xyYToXYZ(xyYNorm_List);

M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);
RGB_List = (M_RGB2XYZ) \ XYZNorm_List;
RGB_BG = [1 1 1]* Y_BG/Y_Max;
displayColors(RGB_List',CIEx,CIEy,RGB_BG,'o');