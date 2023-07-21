% This function generates colors defined in the DKL space.
% DKL space is defined by two parameters - theta and phi, and therefore
% these colors are on a sphere. However, we are interested in colors on the
% isoluminant plane only (theta=0), and we just span colors along phi dimension.

% Inputs: 
% numColors: number of colors spanning dklPhi (0 to 2pi)
% CIEx and CIEy - CIE (x,y) coordinates of the primaries (r,g,b) and the white point.

% Outputs:
% rgb0 - colors in RGB space using the algorithm used in Lablib
% rgb1 - colors in RGB space using a different method

% Note:
% We have used some functions from external sources such as PsychToolbox to convert from
% one color space to another. They can be found in ExternalFunctions
% folder.

function [rgb0,rgb1] = generateDKLColors(numColors,CIEx,CIEy)

if ~exist('numColors','var');           numColors=8;                    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);

%%%%%%%%%%%%%%%%%%%%%%% Macleod Boynton (MB) Space %%%%%%%%%%%%%%%%%%%%%%%%

% We use the convention used in Lablib
[bmr0,bmb0] = xy2MB(CIEx.r,CIEy.r);
[bmr1,bmb1] = xy2MB(CIEx.g,CIEy.g);
[bmr2,bmb2] = xy2MB(CIEx.b,CIEy.b);
[bmr3,bmb3] = xy2MB(CIEx.w,CIEy.w);

%%%%%%%%%%%%%%%%%% Compute Carginal Green and Yellow %%%%%%%%%%%%%%%%%%%%%%
bmr = [bmr0 bmr1 bmr2 bmr3];
bmb = [bmb0 bmb1 bmb2 bmb3];
calibratedColor = computeKDLColors(bmr,bmb);

% Cardinal Green
bmrCarGreen = calibratedColor.cardinalGreen.green*bmr1+calibratedColor.cardinalGreen.blue*bmr2;
scalingFactor_cb = bmr3 - bmrCarGreen;

% Cardinal Yellow
bmbCarYellow = calibratedColor.cardinalYellow.red*bmb0+calibratedColor.cardinalGreen.green*bmb1;
scalingFactor_tc = bmb3 - bmbCarYellow;

%%%%%%%%%%% Find appropriate colors using two approaches %%%%%%%%%%%%%%%%%%

kdlConstants = calibratedColorTokdlConstants(calibratedColor); % Lablib

rgb0 = zeros(numColors,3); % Colors using Lablib
rgb1 = zeros(numColors,3); % Colors by directly converting XYZ to RGB

for i=1:numColors
    
    kdlPhi = (i-1)*(360/numColors);
    
    % Lablib
    [rgb,lum,cb,tc] = kdlToRGB(kdlConstants,kdlPhi,0);
    rgb = normalizeColors(rgb,kdlPhi,0); % Normalize if needed to keep within range
    rgb0(i,:) = [rgb.red rgb.green rgb.blue]; % Actual rgb coordinates using Lablib
    
    % Matlab
    % Macleod Boynton coordinates
    bmr = bmr3 + cb*scalingFactor_cb;
    bmb = bmb3 + tc*scalingFactor_tc;
    
    [x,y] = MB2xy(bmr,bmb); % Convert MB to xy
    xyYtmp = [x y 0.5+lum/2]'; % create a color with same xy (and hence MB coordinates) but different luminance
    XYZtmp = xyYToXYZ(xyYtmp);
    rgbVals = M_RGB2XYZ\XYZtmp;
    rgb.red = rgbVals(1); rgb.green = rgbVals(2); rgb.blue = rgbVals(3);
    rgb = normalizeColors(rgb,kdlPhi,0); % Normalize if needed to keep within range
    rgb1(i,:) = [rgb.red rgb.green rgb.blue];
end
end

% Macleod Boynton
function CMF2CF_MB = getMBMatrix
CMF2CF_MB = [0.15514 0.54312  -0.03286;
            -0.15514 0.45684  0.03286;
             0       0        0.01608];
end
function [r,b] = xy2MB(x,y)

CMF2CF_MB = getMBMatrix;
lms = CMF2CF_MB*[x y 1-x-y]';
r = lms(1)/(lms(1)+lms(2));
b = lms(3)/(lms(1)+lms(2));
end
function [x,y] = MB2xy(r,b)

CMF2CF_MB = getMBMatrix;
XYZ = (CMF2CF_MB)\[r 1-r b]';
sumXYZ = sum(XYZ);
x = XYZ(1)/sumXYZ;
y = XYZ(2)/sumXYZ;

end
% Lablib functions
function calibratedColor = computeKDLColors(bmr,bmb)

% cardinal green
cardg = (bmb(4) - bmb(3)) / (bmb(2) - bmb(3));

calibratedColor.cardinalGreen.red = 0.0;
calibratedColor.cardinalGreen.green = cardg;
calibratedColor.cardinalGreen.blue = 1 - cardg;

% cardinal yellow
cardy = (bmr(4) - bmr(2)) / (bmr(1) - bmr(2));

calibratedColor.cardinalYellow.red = cardy;
calibratedColor.cardinalYellow.green = 1 - cardy;
calibratedColor.cardinalYellow.blue = 0.0;

% equal energy

gbrb = (bmb(2) - bmb(3)) / (bmr(2) - bmr(3));

rede = bmb(4) - bmb(3) - (bmr(4) - bmr(3)) * gbrb;
redeDeno = bmb(1) - bmb(3) - (bmr(1) - bmr(3)) * gbrb;
rede = rede/redeDeno;

greene = (bmb(3) - bmb(4)) / (bmb(3) - bmb(2)) + rede * (bmb(1) - bmb(3)) / (bmb(3) - bmb(2));
bluee = 1 - rede - greene;

calibratedColor.equalEnergy.red = rede;
calibratedColor.equalEnergy.green = greene;
calibratedColor.equalEnergy.blue = bluee;

end
function kdlConstants = calibratedColorTokdlConstants(calibratedColor)

kdlConstants.rtc = (calibratedColor.equalEnergy.red - calibratedColor.cardinalYellow.red) /...
    calibratedColor.equalEnergy.red;
kdlConstants.gcb = (calibratedColor.equalEnergy.green - calibratedColor.cardinalGreen.green) /...
    calibratedColor.equalEnergy.green;
kdlConstants.gtc = (calibratedColor.equalEnergy.green - calibratedColor.cardinalYellow.green) /...
    calibratedColor.equalEnergy.green;
kdlConstants.bcb = (calibratedColor.equalEnergy.blue - calibratedColor.cardinalGreen.blue) /...
    calibratedColor.equalEnergy.blue;

end
function [rgb,lum,cb,tc] = kdlToRGB(kdlConstants,kdlPhi,dklTheta)

normFactor = 1; %sqrt(2.0);
lum = sin(deg2rad(dklTheta))/normFactor;
cb = cos(deg2rad(dklTheta)); tc=cb;
cb = cb*cos(deg2rad(kdlPhi))/normFactor;
tc = tc*sin(deg2rad(kdlPhi))/normFactor;

rgb.red = (lum + cb + kdlConstants.rtc * tc);
rgb.green = (lum + cb * kdlConstants.gcb + tc * kdlConstants.gtc);
rgb.blue = (lum + cb * kdlConstants.bcb + tc);

%normalize the values between 0 and 1;

rgb.red = (rgb.red+1)/2;
rgb.green = (rgb.green+1)/2;
rgb.blue  = (rgb.blue+1)/2;

% original normalization followed inside the lablib for rendering using opengl

% rgb.red = 0.5-(rgb.red/2);
% rgb.green = 0.5-(rgb.green/2);
% rgb.blue = 0.5-(rgb.blue/2);
end
function rgb = normalizeColors(rgb,kdlPhi,dklTheta)

if (rgb.red>1) || (rgb.red<0)
    x = rgb.red;
    x = min(max(x,0),1);
    disp(['for phi=' num2str(kdlPhi) ', theta=' num2str(dklTheta) ', red: ' num2str(rgb.red) ' out of range, set to ' num2str(x)]);
    rgb.red=x;
end
if (rgb.green>1) || (rgb.green<0)
    x = rgb.green;
    x = min(max(x,0),1);
    disp(['for phi=' num2str(kdlPhi) ', theta=' num2str(dklTheta) ', green: ' num2str(rgb.green) ' out of range, set to ' num2str(x)]);
    rgb.green=x;
end
if (rgb.blue>1) || (rgb.blue<0)
    x = rgb.blue;
    x = min(max(x,0),1);
    disp(['for phi=' num2str(kdlPhi) ', theta=' num2str(dklTheta) ', blue: ' num2str(rgb.blue) ' out of range, set to ' num2str(x)]);
    rgb.blue=x;
end

end
