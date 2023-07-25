% generate color luminance gratings
% 

computerName = 'Rig4Analysis'; profileDate = '200723'; sourceType = 'data';
targetY_Max = 20;
[CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(computerName,profileDate,sourceType);

M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);

hsvR = rgb2hsv([1 0 0]);

[xAxisDeg,yAxisDeg,monitorSpecifications,viewingDistanceCM] = getMonitorDetails;

gaborStim.azimuthDeg=0;
gaborStim.elevationDeg=0;
gaborStim.sigmaDeg=100000; 
gaborStim.radiusDeg=100; % FS
gaborStim.contrastPC=100;
gaborStim.spatialFreqCPD=1;
gaborStim.orientationDeg=0;
gaborStim.hueDeg = 0;
gaborStim.sat = 1;
tmpPatch = makeGaborStimulus(gaborStim,xAxisDeg,yAxisDeg);

targetPatchHSV = rgb2hsv(tmpPatch);
targetPatchHSV(:,:,3) = targetPatchHSV(:,:,3)*targetY_Max/Y_Max;
imagesc(xAxisDeg,yAxisDeg,hsv2rgb(targetPatchHSV)); colorbar;
