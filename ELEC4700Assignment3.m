close all;
clear;
clc;

addpath('./code/');

global C;
global boxWidthScaleFactor;
global boxLengthScaleFactor;
global Efield_x;
global Efield_y;
global Vapplied;
global meshSize;

boxWidthScaleFactor = 2e-9; %nm%
boxLengthScaleFactor = 1e-9; %nm%

Vapplied = 0.1; %Volts%
meshSize = 1; %nm%

% -------- Question 1 -------- %

[avgVelocitiesX, time] = MonteCarloElectronSim(false, false, true, 'Uniform', 40*boxWidthScaleFactor, 0, 1/5, 2/5);

chargesPerUnitArea = 1e19; % electrons/m^2;
Jx = (C.q)*chargesPerUnitArea*avgVelocitiesX; % current per m

Ix = Jx*(100*boxLengthScaleFactor); % current in the x-direction over time

figure;
plot(time, Ix, 'r');
grid on;
title('Electron Drift Current vs. Time');
xlabel('Time (s)');
ylabel('Electron Drift Current (A)');

% -------- Question 2 -------- %

Vapplied = 1; %Volts%

[dummy1, dummy2, Efield_x, Efield_y] = FiniteDifferenceSolver(1, 0.01, true, 80, 0, 1/5, 2/5);
[dummy1, dummy2] = MonteCarloElectronSim(true, false, true, "Custom", 40*boxWidthScaleFactor, 0, 1/5, 2/5); 

% -------- Question 3 -------- %

Vapplied = 0.8; %Volts%

% Run once to get density map
[dummy1, dummy2, Efield_x, Efield_y] = FiniteDifferenceSolver(1, 0.01, true, 80, 0, 1/5, 2/5);
[dummy1, dummy2] = MonteCarloElectronSim(true, false, true, "Custom", 40*boxWidthScaleFactor, 0, 1/5, 2/5); 

bottleNeckWidths = [1/5 1.25/5 1.5/5 1.75/5 2/5 2.25/5]; % height of each box (fractional amount of region height)
bottleNeckSeparation = (100*boxLengthScaleFactor) - ((2.*bottleNeckWidths).*(100*boxLengthScaleFactor)); % bottle-neck separation in nm
avgVelocityX = zeros(1, length(bottleNeckWidths));

% Run iteratively for different bottleneck widths
for i = 1:length(bottleNeckWidths)

    [dummy1, dummy2, Efield_x, Efield_y] = FiniteDifferenceSolver(1, 0.01, true, 80, 0, 1/5, bottleNeckWidths(i));
    [avgVelocitiesX, dummy2] = MonteCarloElectronSim(true, false, true, "Custom", 40*boxWidthScaleFactor, 0, 1/5, bottleNeckWidths(i)); 
    
    avgVelocityX(i) = sum(avgVelocitiesX)/length(avgVelocitiesX);
    
    close all;
    
end

Jx = (C.q)*chargesPerUnitArea.*avgVelocityX;

% average current density vs bottle-neck width plot
figure;
plot(bottleNeckSeparation, Jx, 'rx');
grid on;
title('Average Current Density J_x vs. Different Bottle-neck Widths (Varrying Separations)');
xlabel('Bottle-neck Separation (m)');
ylabel('Average Current Density J_x (A/m)');


