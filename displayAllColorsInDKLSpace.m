% displayAllColorsInDKLSpace

[CIEx,CIEy] = getMonitorCalibrationDetails;
RGB_BG = [0.5 0.5 0.5]; % RGB coordinates of the background

% Span all colors in RGB space
RGB_List = []; d=0.2;
for r=0:d:1
    for g=0:d:1
        for b=0:d:1
            RGB_List = cat(1,RGB_List,[r g b]);
        end
    end
end

displayColors(RGB_List,CIEx,CIEy,RGB_BG,'+');