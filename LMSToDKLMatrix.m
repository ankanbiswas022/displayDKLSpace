% Matrix to convert Colors from LMS (expressed in units so that
% L+M=Luminance) to DKL space

function M = LMSToDKLMatrix(LMS_B)

b1 = LMS_B(1); b2 = LMS_B(2); b3 = LMS_B(3);

B = [1 1     0;
    1 -b1/b2 0;
    -1 -1    (b1+b2)/b3];

D = (1/(b1+b2)) * diag([sqrt(3) sqrt(1+(b2/b1).^2) 1]);

M = D * B;
end