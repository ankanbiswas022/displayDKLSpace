% generate color luminance gratings

targetY_Candela = 25;
computerName = 'Rig4Analysis'; profileDate = '200723'; sourceType = 'data';
[CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(computerName,profileDate,sourceType);

M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);

% Get monitor details
[xAxisDeg,yAxisDeg,monitorSpecifications,viewingDistanceCM] = getMonitorDetails;

% save Image Details
folderNameToSave = 'Images';
baseName='Image';fileformat='.tif';
folderSourceString = fullfile(pwd,folderNameToSave);
mkdir(folderSourceString);
% sf and ori List
index=1;
hueList = [0 0 120];
satList = [0 1 1];
sfList  = [0 0.5,1,2,4,8];                        % 6 sf values
oriListI = [0,22.5,45,67.5,90,112.5,135,157.5];   % 8 ori value

% Fixed properties
gaborStim.azimuthDeg=0;
gaborStim.elevationDeg=0;
gaborStim.sigmaDeg=1000;
gaborStim.radiusDeg=100; % FS
gaborStim.contrastPC=100;

for i=1:length(hueList)
    h=hueList(i); s = satList(i);
    gaborStim.sat = s;

    rgb = hsv2rgb([h/360 s 1]);
    XYZ = M_RGB2XYZ * rgb';
    Y_MaxThisColor_Candela = XYZ(2)*Y_Max;
    scalingFactor_Y = targetY_Candela/Y_MaxThisColor_Candela;

    for j=1:length(sfList)
        sf=sfList(j);
        if sf==0
            oriList=0;
        else
            oriList=oriListI;
        end

        for k=1:length(oriList)
            ori=oriList(k);
            
            gaborStim.spatialFreqCPD=sf;
            gaborStim.orientationDeg=ori;
            gaborStim.hueDeg = h;
            
            tmpPatch = makeGaborStimulus(gaborStim,xAxisDeg,yAxisDeg); % This progrma is in CommonPrograms (https://github.com/supratimray/CommonPrograms)

            targetPatchHSV = rgb2hsv(tmpPatch);
            targetPatchHSV(:,:,3) = targetPatchHSV(:,:,3)*scalingFactor_Y;
            targetPatchRGB = hsv2rgb(targetPatchHSV);

            % save Image:
            fileName=strcat(baseName,num2str(index),fileformat);
            filePath=fullfile(folderSourceString,fileName);
            imwrite(targetPatchRGB,filePath);
            index=index+1; % update Index
        end
    end
end