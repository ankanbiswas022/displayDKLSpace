% This program generates iso-luminant colors on a line connecting the white
% point and the three primaries. Depending on the target luminance, not all
% colors between white point and primary can be generated.

targetY_Candela = 25; % cd/m2
computerName = 'Rig4Analysis'; profileDate = '200723'; sourceType = 'data';
[CIEx,CIEy,Y_Max,Y_BG] = getMonitorCalibrationDetails(computerName,profileDate,sourceType);
targetY = targetY_Candela/Y_Max;

M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);
M_XYZ2RGB = inv(M_RGB2XYZ);

numPointsTest = 100; % generate the coordinates of these many points between the white point and primary.
numPointsDisplay = 5;

RGBListFinal = cell(1,3);

for colorIndex=1:3 % for the three primaries

    switch colorIndex
        case 1
            xEndPoints = [CIEx.w CIEx.r];
            yEndPoints = [CIEy.w CIEy.r];

        case 2
            xEndPoints = [CIEx.w CIEx.g];
            yEndPoints = [CIEy.w CIEy.g];

        case 3
            xEndPoints = [CIEx.w CIEx.b];
            yEndPoints = [CIEy.w CIEy.b];
    end
    
    [xPoints,yPoints] = getPointsOnLine(xEndPoints,yEndPoints,numPointsTest);

    % Get the RGB Values for the generated CIE values
    xyYtmp = [xPoints(:) yPoints(:) repmat(targetY,numPointsTest,1)]';
    rgbtmp = M_RGB2XYZ \ xyYToXYZ(xyYtmp);
    maxVals = max(abs(rgbtmp),[],1);

    maxPos = find(maxVals<=1, 1, 'last' );

    [xPointsFinal,yPointsFinal] = getPointsOnLine([xPoints(1) xPoints(maxPos)],[yPoints(1) yPoints(maxPos)],numPointsDisplay);
    xyYtmp = [xPointsFinal(:) yPointsFinal(:) repmat(targetY,numPointsDisplay,1)]';
    RGBListFinal{colorIndex} = M_RGB2XYZ \ xyYToXYZ(xyYtmp);
end

% Display the final colors
RGBList = [RGBListFinal{1} RGBListFinal{2} RGBListFinal{3}]';
RGB_BG = [1 1 1]*targetY;
displayColors(RGBList,CIEx,CIEy,RGB_BG,'o');

function [xP,yP] = getPointsOnLine(xEP,yEP,nP)
dx = (xEP(2)-xEP(1))/nP; dy = (yEP(2)-yEP(1))/nP;
xP = xEP(1): dx : xEP(2)-dx;
yP = yEP(1): dy : yEP(2)-dy;
end