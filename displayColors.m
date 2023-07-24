% This function displays colors in different spaces

% Inputs:
% RGBList: Nx3 matrix of colors defined in RGB coordinates
% CIEx and CIEy - CIE (x,y) coordinates of the primaries (r,g,b) and the
% white point.
% RGB_BL are the RGB coordinates of background

function displayColors(RGBList,CIEx,CIEy,RGB_BG,markerType)

if ~exist('RGB_BG','var');      RGB_BG = [0.5 0.5 0.5];                 end
if ~exist('markerType','var');  markerType = 'o';                       end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% xy Coordinates
subplot(231);
axis square;
cieCoordinates=load('cieCoordinates.mat');
plot(cieCoordinates.cieCoordinates(:,2), cieCoordinates.cieCoordinates(:,3),'k'); axis([0 1 0 1]);
hold on;
plot(CIEx.r,CIEy.r,'marker',markerType,'color','r','markerfacecolor','r');
plot(CIEx.g,CIEy.g,'marker',markerType,'color','g','markerfacecolor','g');
plot(CIEx.b,CIEy.b,'marker',markerType,'color','b','markerfacecolor','b');
plot(CIEx.w,CIEy.w,'marker',markerType,'color',RGB_BG,'markerfacecolor',RGB_BG);

line([CIEx.b CIEx.g],[CIEy.b CIEy.g],'color','k');
line([CIEx.b CIEx.r],[CIEy.b CIEy.r],'color','k');
line([CIEx.g CIEx.r],[CIEy.g CIEy.r],'color','k');
xlabel('x'); ylabel('y');
xlim([0 1]); ylim([0 1]);
title('CIE xy');

% xY Coordinates
subplot(232);

% Once the white point is fixed, the fraction of luminance contributed by
% the 3 phosphors also gets fixed. In other words, the variable Y which
% corresponds to the luminance can be determined from CIEx and CIEy, as
% follows.

% Get the matrix which converts RGB colors to XYZ. This matrix only needs
% the (x,y) coordinates of r,g,b and the white point
M_RGB2XYZ = RGBToXYZMatrix(CIEx.r, CIEy.r, CIEx.g, CIEy.g, CIEx.b, CIEy.b, CIEx.w, CIEy.w);

XYZr = M_RGB2XYZ*[1 0 0]'; xyYr = XYZToxyY(XYZr); % xyY of Red [1 0 0]
XYZg = M_RGB2XYZ*[0 1 0]'; xyYg = XYZToxyY(XYZg); % xyY of Green [0 1 0]
XYZb = M_RGB2XYZ*[0 0 1]'; xyYb = XYZToxyY(XYZb); % xyY of Blue [0 0 1]
XYZw = M_RGB2XYZ*RGB_BG'; xyYw = XYZToxyY(XYZw); % xyY of gray [0.5 0.5 0.5]

plot(xyYr(1),xyYr(3),'marker',markerType,'color','r','markerfacecolor','r'); hold on;
plot(xyYg(1),xyYg(3),'marker',markerType,'color','g','markerfacecolor','g');
plot(xyYb(1),xyYb(3),'marker',markerType,'color','b','markerfacecolor','b');
plot(xyYw(1),xyYw(3),'marker',markerType,'color',RGB_BG,'markerfacecolor',RGB_BG);

xlabel('x'); ylabel('Y');
xlim([0 1]); ylim([0 1]);
title('CIE xY');

%%%%%%%%%%%%%%%%%%%%%%% Macleod Boynton (MB) Space %%%%%%%%%%%%%%%%%%%%%%%%
subplot(233);
axis square;
% We use the convention used in Lablib
[bmr0,bmb0] = xy2MB(CIEx.r,CIEy.r);
[bmr1,bmb1] = xy2MB(CIEx.g,CIEy.g);
[bmr2,bmb2] = xy2MB(CIEx.b,CIEy.b);
[bmr3,bmb3] = xy2MB(CIEx.w,CIEy.w);

mbLocus = load('MBlocus.mat');
plot(mbLocus.rMB,mbLocus.bMB,'k');
hold on;
plot(bmr0,bmb0,'marker',markerType,'color','r','markerfacecolor','r');
plot(bmr1,bmb1,'marker',markerType,'color','g','markerfacecolor','g');
plot(bmr2,bmb2,'marker',markerType,'color','b','markerfacecolor','b');
plot(bmr3,bmb3,'marker',markerType,'color',RGB_BG,'markerfacecolor',RGB_BG);

line([bmr0 bmr1],[bmb0 bmb1],'color','k');
line([bmr0 bmr2],[bmb0 bmb2],'color','k');
line([bmr1 bmr2],[bmb1 bmb2],'color','k');
ylim([0 0.2]);
title('Macleod Boynton');
xlabel('r'); ylabel('b');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DKL Space %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M_XYZ2LMS = XYZToLMSMatrix;
M_RGB2LMS = M_XYZ2LMS * M_RGB2XYZ;
LMS_BG = M_RGB2LMS * RGB_BG';
M_LMS2DKL = LMSToDKLMatrix(LMS_BG);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Display Colors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
numColors = size(RGBList,1);

for i=1:numColors
    
    RGB = RGBList(i,:);
    XYZ = M_RGB2XYZ*RGB';
    xyY = XYZToxyY(XYZ); 
    x = xyY(1); y = xyY(2); Y = xyY(3);

    disp(i);
    if max(RGB)>1 || min(RGB)<0
        RGBtmp = RGB;
        RGB = normalizeRGB(RGBtmp);
        disp(['Color' num2str(i) ': ' num2str(round(RGBtmp,2)) ' changed to ' num2str(round(RGB,2))]);
    end

    % Show coordinates in xy, xY and MB spaces
    subplot(231);
    plot(x,y,'marker', markerType,'color',RGB,'markerfacecolor',RGB);

    subplot(232);
    plot(x,Y,'marker', markerType,'color',RGB,'markerfacecolor',RGB);

    subplot(233);
    [r,b] = xy2MB(x,y);
    plot(r,b,'marker', markerType,'color',RGB,'markerfacecolor',RGB);

    % Show stimuli in DKL space
    LMS = M_RGB2LMS * RGB';
    DKL = M_LMS2DKL * (LMS - LMS_BG);
    %    DKL2 = lms2dkl(LMS_BG,LMS); % Using Stephen Westland's code; Note that
    %    in this code, cone increment is taken as LMS_BG - LMS; so DKL = -DKL2;

    subplot(234);
    plot(DKL(2),DKL(1),'marker', markerType,'color',RGB,'markerfacecolor',RGB); hold on;
    subplot(235);
    plot(DKL(3),DKL(1),'marker', markerType,'color',RGB,'markerfacecolor',RGB); hold on;
    subplot(236);
    plot(DKL(2),DKL(3),'marker', markerType,'color',RGB,'markerfacecolor',RGB); hold on;
end

subplot(234);
title('DKL Space'); xlabel('L-M'); ylabel('(L+M)'); ylim([-sqrt(3) sqrt(3)]);
subplot(235);
title('DKL Space'); xlabel('S-(L+M)'); ylabel('L+M'); ylim([-sqrt(3) sqrt(3)]);
subplot(236);
title('DKL Space'); xlabel('L-M'); ylabel('S-(L+M)');
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
