% Normalize RGB colors between 0 and 1
function nRGB = normalizeRGB(RGB)
nRGB = RGB;
for i=1:3
    if RGB(i)>1
        nRGB(i)=1;
    elseif RGB(i)<0
        nRGB(i)=0;
    end
end
end