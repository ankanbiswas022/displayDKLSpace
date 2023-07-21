% This code generates DKL colors on a circle. The logic here is
% different from the code generateDKLColors in which we find colors on an
% ellipse on the DKL space

[CIEx,CIEy] = getMonitorCalibrationDetails;

numColors = 8;
RGB_List = generateDKLColors(numColors,CIEx,CIEy);
RGB_BG = [0.5 0.5 0.5]; % RGB coordinates of the background
displayColors(RGB_List,CIEx,CIEy,RGB_BG,'+');

% Convert these colors to the DKL space
M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);
M_XYZ2LMS = XYZToLMSMatrix;
M_RGB2LMS = M_XYZ2LMS * M_RGB2XYZ;
LMS_BG = M_RGB2LMS * RGB_BG';
M_LMS2DKL = LMSToDKLMatrix(LMS_BG);
LMS_List = M_RGB2LMS * RGB_List';
DKL_List = M_LMS2DKL * (LMS_List - LMS_BG);

maxLM = max(abs(DKL_List(2,:)));
maxS = max(abs(DKL_List(3,:)));
maxR = floor(100*min(maxLM,maxS))/100; % This is the maximum radius of a circle on the DKL space

%%%%%%%%%%%%%%%%%%%%%% Generate colors on DKL space %%%%%%%%%%%%%%%%%%%%%%%
axisLum = zeros(1,numColors);
axisLM = zeros(1,numColors);
axisS = zeros(1,numColors);

for i=1:numColors
    axisLum(i) = 0;
    axisLM(i) = maxR*cos(2*pi*(i-1)/numColors);
    axisS(i) = maxR*sin(2*pi*(i-1)/numColors);
end
DKLOut_List = [axisLum; axisLM; axisS];
LMSOut_List = (M_LMS2DKL) \ DKLOut_List + LMS_BG;
RGBOut_List = (M_RGB2LMS) \ LMSOut_List;

displayColors(RGBOut_List',CIEx,CIEy,RGB_BG,'o');