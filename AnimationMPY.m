% Transforms a 3D plot into a 2D plot to use the colors of the z axis.
% Example to show how to use the colors of the z axis to help with the
% visualization of an additional dimension.
%
% AnimationMPY.m.
% Andre C. Silva
% April 14, 2021

clear;

%% OPTIONS
%--------------------------------------------------------------------------

DoAnimation = true;

%% DATA
%--------------------------------------------------------------------------

datasource = 'DataMPYR';

% Annual data, 1900-2020; 2020 data refer to the first quarter of 2020.
%
% Sources: St. Louis Fed FRED dataset, Historical Statistics of the United
% States, Friedman and Schwartz. For more information, see Silva (2012),
% AEJ: Macro, https://doi.org/10.1257/mac.4.2.153.

% Loads data on M, NGDP, and r
datampy = load(datasource);

datesYdt   = datampy.datesMPY;           % Years (datetime)
datesYnum  = year(datesYdt);             % Years (double)
dataM1     = datampy.M1;                 % M1
dataNGDP   = datampy.GDP;                % Nominal GDP
dataR      = datampy.r;                  % Commercial Paper Rate, r

QFromYear = datetime(2020,1,1);

%% CALCULATE MONEY-INCOME RATIO

% Money-Income ratio
dataMPy  = dataM1./dataNGDP;

%% FIGURE 3D

MS3D = 17;  % MarkerSize, default: 6
FSY = 6;    % Font size for years
FA = 1;     % Face alpha

ny = 0; % Index to capture images

x = dataR;
y = dataMPy;
z = datesYnum;  % Better to use numbers for colobar

hf1 = figure('Position',[400 100 600 335]);
set(gcf, 'MenuBar', 'None');

hs = surf([x(:),x(:)],[y(:),y(:)],[z(:),z(:)],'Marker','o','FaceAlpha',FA);

cb = colorbar;
hs.LineStyle = 'none';
hs.MarkerSize = MS3D;
hs.MarkerFaceColor = 'flat';
cb.Label.String = 'years';
cb.Label.Interpreter = 'latex';

% Include labels for the years
for i = 1:length(z)
    if datesYnum(i) <= 1999
        datestr = char(datesYdt(i),'yy');
    elseif datesYdt(i) < QFromYear
        datestr = char(datesYdt(i),'yyyy');
    else
        datestr = char(datesYdt(i),'yyQQQ');
    end
    text(dataR(i),dataMPy(i),z(i),datestr,...
        'FontSize',FSY,'HorizontalAlignment','center',...
        'VerticalAlignment','middle')
end

ylim([0.05 0.5+eps])
zlim([1900,2020])

ylabel('money-income ratio, $m$','Interpreter','latex')
xlabel('commercial paper rate, $r$ (\% p.a.)','Interpreter','latex')

grid off;   % Grid on is set as default

% Get azimuth and elevation angles
[az,cel] = view;

% Capture plot
ny = ny + 1;
frame = getframe(hf1);
im{ny} = frame2im(frame);

%% ANIMATION

NumFrames = 50;

if DoAnimation
    
    % First change elevation angle
    vecanim = linspace(cel,90,NumFrames);
    for celchange = vecanim
        view(az,celchange)
        drawnow;
        
        ny = ny + 1;
        frame = getframe(hf1);
        im{ny} = frame2im(frame);
    end
    
    % Then change azimuth
    vecanim = linspace(az,0,NumFrames);
    for azchange = vecanim
        view(azchange,celchange)
        drawnow;
        
        ny = ny + 1;
        frame = getframe(hf1);
        im{ny} = frame2im(frame);        
    end    
end

% Final change view to make the plot 2-D
az = 0;
cel = 90;
view(az,cel)

ny = ny + 1;
frame = getframe(hf1);
im{ny} = frame2im(frame);

%% SAVE GIF

filename = 'animation3D2D.gif';

% Number of loops
LP = 0;

% Delay time
DT1 = 1;
DT2 = 0.05;
DT3 = 2;

for idx = 1:length(im)
    [A,map] = rgb2ind(im{idx},256);
    if idx == 1
        imwrite(A,map,filename,'gif','LoopCount',LP,'DelayTime',DT1);
    elseif idx > 1 && idx < length(im)
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',DT2);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',DT3);
    end
end

