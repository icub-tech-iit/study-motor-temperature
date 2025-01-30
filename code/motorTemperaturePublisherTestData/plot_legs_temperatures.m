close all;
clear;
clc;

%% Import data as table

dataL = readtable('full_legs/left_leg/data.log');
dataL = renamevars(dataL, 1:width(dataL), ["ID", "Tabs", "Trel", "hip_pitch_t", "hip_pitch_oh", "hip_roll_t", "hip_roll_oh", "hip_yaw_t", "hip_yaw_oh", "knee_t", "knee_oh", "ankle_pitch_t", "ankle_pitch_oh", "ankle_roll_t", "ankle_roll_oh"]);

dataR = readtable('full_legs/right_leg/data.log');
dataR = renamevars(dataR, 1:width(dataR), ["ID", "Tabs", "Trel", "hip_pitch_t", "hip_pitch_oh", "hip_roll_t", "hip_roll_oh", "hip_yaw_t", "hip_yaw_oh", "knee_t", "knee_oh", "ankle_pitch_t", "ankle_pitch_oh", "ankle_roll_t", "ankle_roll_oh"]);
%% Adjust second column of data thus to have times relative to start of experiment
dataL.Tabs = dataL.Tabs - dataL.Tabs(1);
dataR.Tabs = dataR.Tabs - dataR.Tabs(1);

%% Print temperature data
tiledlayout(1,2);

ax1 = nexttile;
title(ax1, 'Left Leg Temperatures');
plot(dataL, "Tabs", ["hip_pitch_t", "hip_roll_t", "hip_yaw_t", "knee_t", "ankle_pitch_t", "ankle_roll_t"]);
grid(ax1, "on");

legend(ax1, ["hip-pitch", "hip-roll", "hip-yaw", "knee", "ankle-pitch", "ankle-roll"]);

ax2 = nexttile;
title(ax2, 'Right Leg Temperatures');
plot(dataR, "Tabs", ["hip_pitch_t", "hip_roll_t", "hip_yaw_t", "knee_t", "ankle_pitch_t", "ankle_roll_t"]); 
grid(ax2,"on");

legend(ax2, ["hip-pitch", "hip-roll", "hip-yaw", "knee", "ankle-pitch", "ankle-roll"]);

%%
% tiledlayout(2,1);
% ax1 = nexttile;
% plot(dataL, "Tabs", "knee_t");
% grid(ax1, "on");
% xlabel(ax1, "Time [s]");
% ylabel(ax1, "Temperature [℃]");
% title(ax1, 'Left Leg Knee Temperatures');
% 
% ax2 = nexttile;
% plot(dataR, "Tabs", "knee_t");
% grid(ax2, "on");
% xlabel(ax2, "Time [s]");
% ylabel(ax2, "Temperature [℃]");
% title(ax2, 'Right Leg Knee Temperatures');

% ax3 = nexttile;
% plot(dataR, "Tabs", "ankle_pitch_t"); 
% grid(ax3,"on");
% title(ax3, 'Right Leg Ankle Pitch Temperatures');
% 
% ax4 = nexttile;
% plot(dataR, "Tabs", "ankle_roll_t"); 
% grid(ax4,"on");
% title(ax4, 'Right Leg Ankle Roll Temperatures');

%% Check the computation of lost data with synthetic data

%Synthetic data
counter = 0;
dataArraySynth = [];
counterSynth = [];
valuesynth = 30;
totalWatchdog = 1000;
partialWatchdog = 10;
while(totalWatchdog > 0)
    partialWatchdog = partialWatchdog -1;
    if((partialWatchdog < 0) && (valuesynth > 0))
        partialWatchdog = 10;
        valuesynth = -30;
    elseif((partialWatchdog < 0) && (valuesynth < 0))
        partialWatchdog = 10;
        valuesynth = 30;
    end
    dataArraySynth(end+1) = valuesynth;
    totalWatchdog = totalWatchdog - 1;
end
for i = 1:length(dataArraySynth)
    if(dataArraySynth(i) < 0)
        counter = counter+1;
    else
        counterSynth(end+1) = counter;
        counter = 0;
    end
end

%% Analysis of lost readings on the left subpart

counters_hip_pitch_l = 1;
counters_hip_roll_l = 1;
counters_hip_yaw_l = 1;
counters_knee_l = 1;
counters_ankle_pitch_l = 1;
counters_ankle_roll_l = 1;

temperature_threshold_spikes = 10;
counter = 0;
temperatureSpikeRef = 0;
sampleToTdbreadings = 50;

%% HIP_PITCH

bad_readings_hip_pitch_l = zeros(1,7);

for i = 1:height(dataL)
    if(dataL.hip_pitch_t(i) < 0)
        bad_readings_hip_pitch_l(1,1) = bad_readings_hip_pitch_l(1,1)+1;
        if(dataL.hip_pitch_t(i) < -25 && dataL.hip_pitch_t(i) > -40)
            bad_readings_hip_pitch_l(1,2) = bad_readings_hip_pitch_l(1,2)+1;
        elseif(dataL.hip_pitch_t(i) < -45 && dataL.hip_pitch_t(i) > -60)
            bad_readings_hip_pitch_l(1,3) = bad_readings_hip_pitch_l(1,3)+1;
        elseif(dataL.hip_pitch_t(i) < -85 && dataL.hip_pitch_t(i) > -100)
            bad_readings_hip_pitch_l(1,4) = bad_readings_hip_pitch_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_pitch_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.hip_pitch_t(i) > 0) && (dataL.hip_pitch_t(i-1) > 0))
            if(dataL.hip_pitch_t(i) > (dataL.hip_pitch_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.hip_pitch_t(i-1);
                bad_readings_hip_pitch_l(1,5) = bad_readings_hip_pitch_l(1,5)+1;
            end
        elseif(dataL.hip_pitch_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.hip_pitch_t(i) > 0) && (dataL.hip_pitch_t(i-1) > 0))
            bad_readings_hip_pitch_l(1,5) = bad_readings_hip_pitch_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_pitch_l(1,2) = (bad_readings_hip_pitch_l(1,2)/bad_readings_hip_pitch_l(1,1))*100;
bad_readings_hip_pitch_l(1,3) = (bad_readings_hip_pitch_l(1,3)/bad_readings_hip_pitch_l(1,1))*100;
bad_readings_hip_pitch_l(1,4) = (bad_readings_hip_pitch_l(1,4)/bad_readings_hip_pitch_l(1,1))*100;
bad_readings_hip_pitch_l(1,1) = (bad_readings_hip_pitch_l(1,1)/height(dataL))*100;
bad_readings_hip_pitch_l(1,5) = (bad_readings_hip_pitch_l(1,5)/height(dataL))*100;
bad_readings_hip_pitch_l(1,6) = max(counters_hip_pitch_l)/sampleToTdbreadings;
bad_readings_hip_pitch_l(1,7) = min(counters_hip_pitch_l)/sampleToTdbreadings;

%% HIP_ROLL
counter = 0;
bad_readings_hip_roll_l = zeros(1,7);
for i = 1:height(dataL)
    if(dataL.hip_roll_t(i) < 0)
        bad_readings_hip_roll_l(1,1) = bad_readings_hip_roll_l(1,1)+1;
        if(dataL.hip_roll_t(i) < -25 && dataL.hip_roll_t(i) > -40)
            bad_readings_hip_roll_l(1,2) = bad_readings_hip_roll_l(1,2)+1;
        elseif(dataL.hip_roll_t(i) < -45 && dataL.hip_roll_t(i) > -60)
            bad_readings_hip_roll_l(1,3) = bad_readings_hip_roll_l(1,3)+1;
        elseif(dataL.hip_roll_t(i) < -85 && dataL.hip_roll_t(i) > -100)
            bad_readings_hip_roll_l(1,4) = bad_readings_hip_roll_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_roll_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.hip_roll_t(i) > 0) && (dataL.hip_roll_t(i-1) > 0))
            if(dataL.hip_roll_t(i) > (dataL.hip_roll_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.hip_roll_t(i-1);
                bad_readings_hip_roll_l(1,5) = bad_readings_hip_roll_l(1,5)+1;
            end
        elseif(dataL.hip_roll_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.hip_roll_t(i) > 0) && (dataL.hip_roll_t(i-1) > 0))
            bad_readings_hip_roll_l(1,5) = bad_readings_hip_roll_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_roll_l(1,2) = (bad_readings_hip_roll_l(1,2)/bad_readings_hip_roll_l(1,1))*100;
bad_readings_hip_roll_l(1,3) = (bad_readings_hip_roll_l(1,3)/bad_readings_hip_roll_l(1,1))*100;
bad_readings_hip_roll_l(1,4) = (bad_readings_hip_roll_l(1,4)/bad_readings_hip_roll_l(1,1))*100;
bad_readings_hip_roll_l(1,1) = (bad_readings_hip_roll_l(1,1)/height(dataL))*100;
bad_readings_hip_roll_l(1,5) = (bad_readings_hip_roll_l(1,5)/height(dataL))*100;
bad_readings_hip_roll_l(1,6) = max(counters_hip_roll_l)/sampleToTdbreadings;
bad_readings_hip_roll_l(1,7) = min(counters_hip_roll_l)/sampleToTdbreadings;

%% HIP_YAW
counter = 0;
bad_readings_hip_yaw_l = zeros(1,7);
for i = 1:height(dataL)
    if(dataL.hip_yaw_t(i) < 0)
        bad_readings_hip_yaw_l(1,1) = bad_readings_hip_yaw_l(1,1)+1;
        if(dataL.hip_yaw_t(i) < -25 && dataL.hip_yaw_t(i) > -40)
            bad_readings_hip_yaw_l(1,2) = bad_readings_hip_yaw_l(1,2)+1;
        elseif(dataL.hip_yaw_t(i) < -45 && dataL.hip_yaw_t(i) > -60)
            bad_readings_hip_yaw_l(1,3) = bad_readings_hip_yaw_l(1,3)+1;
        elseif(dataL.hip_yaw_t(i) < -85 && dataL.hip_yaw_t(i) > -100)
            bad_readings_hip_yaw_l(1,4) = bad_readings_hip_yaw_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_yaw_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.hip_yaw_t(i) > 0) && (dataL.hip_yaw_t(i-1) > 0))
            if(dataL.hip_yaw_t(i) > (dataL.hip_yaw_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.hip_yaw_t(i-1);
                bad_readings_hip_yaw_l(1,5) = bad_readings_hip_yaw_l(1,5)+1;
            end
        elseif(dataL.hip_yaw_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.hip_yaw_t(i) > 0) && (dataL.hip_yaw_t(i-1) > 0))
            bad_readings_hip_yaw_l(1,5) = bad_readings_hip_yaw_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_yaw_l(1,2) = (bad_readings_hip_yaw_l(1,2)/bad_readings_hip_yaw_l(1,1))*100;
bad_readings_hip_yaw_l(1,3) = (bad_readings_hip_yaw_l(1,3)/bad_readings_hip_yaw_l(1,1))*100;
bad_readings_hip_yaw_l(1,4) = (bad_readings_hip_yaw_l(1,4)/bad_readings_hip_yaw_l(1,1))*100;
bad_readings_hip_yaw_l(1,1) = (bad_readings_hip_yaw_l(1,1)/height(dataL))*100;
bad_readings_hip_yaw_l(1,5) = (bad_readings_hip_yaw_l(1,5)/height(dataL))*100;
bad_readings_hip_yaw_l(1,6) = max(counters_hip_yaw_l)/sampleToTdbreadings;
bad_readings_hip_yaw_l(1,7) = min(counters_hip_yaw_l)/sampleToTdbreadings;

%% KNEE

counter = 0;
bad_readings_knee_l = zeros(1,7);
for i = 1:height(dataL)
    if(dataL.knee_t(i) < 0)
        bad_readings_knee_l(1,1) = bad_readings_knee_l(1,1)+1;
        if(dataL.knee_t(i) < -25 && dataL.knee_t(i) > -40)
            bad_readings_knee_l(1,2) = bad_readings_knee_l(1,2)+1;
        elseif(dataL.knee_t(i) < -45 && dataL.knee_t(i) > -60)
            bad_readings_knee_l(1,3) = bad_readings_knee_l(1,3)+1;
        elseif(dataL.knee_t(i) < -85 && dataL.knee_t(i) > -100)
            bad_readings_knee_l(1,4) = bad_readings_knee_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_knee_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.knee_t(i) > 0) && (dataL.knee_t(i-1) > 0))
            if(dataL.knee_t(i) > (dataL.knee_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.knee_t(i-1);
                bad_readings_knee_l(1,5) = bad_readings_knee_l(1,5)+1;
            end
        elseif(dataL.knee_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.knee_t(i) > 0) && (dataL.knee_t(i-1) > 0))
            bad_readings_knee_l(1,5) = bad_readings_knee_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_knee_l(1,2) = (bad_readings_knee_l(1,2)/bad_readings_knee_l(1,1))*100;
bad_readings_knee_l(1,3) = (bad_readings_knee_l(1,3)/bad_readings_knee_l(1,1))*100;
bad_readings_knee_l(1,4) = (bad_readings_knee_l(1,4)/bad_readings_knee_l(1,1))*100;
bad_readings_knee_l(1,1) = (bad_readings_knee_l(1,1)/height(dataL))*100;
bad_readings_knee_l(1,5) = (bad_readings_knee_l(1,5)/height(dataL))*100;
bad_readings_knee_l(1,6) = max(counters_knee_l)/sampleToTdbreadings;
bad_readings_knee_l(1,7) = min(counters_knee_l)/sampleToTdbreadings;

%% ANKLE_PITCH
counter = 0;
bad_readings_ankle_pitch_l = zeros(1,7);
for i = 1:height(dataL)
    if(dataL.ankle_pitch_t(i) < 0)
        bad_readings_ankle_pitch_l(1,1) = bad_readings_ankle_pitch_l(1,1)+1;
        if(dataL.ankle_pitch_t(i) < -25 && dataL.ankle_pitch_t(i) > -40)
            bad_readings_ankle_pitch_l(1,2) = bad_readings_ankle_pitch_l(1,2)+1;
        elseif(dataL.ankle_pitch_t(i) < -45 && dataL.ankle_pitch_t(i) > -60)
            bad_readings_ankle_pitch_l(1,3) = bad_readings_ankle_pitch_l(1,3)+1;
        elseif(dataL.ankle_pitch_t(i) < -85 && dataL.ankle_pitch_t(i) > -100)
            bad_readings_ankle_pitch_l(1,4) = bad_readings_ankle_pitch_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_pitch_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.ankle_pitch_t(i) > 0) && (dataL.ankle_pitch_t(i-1) > 0))
            if(dataL.ankle_pitch_t(i) > (dataL.ankle_pitch_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.ankle_pitch_t(i-1);
                bad_readings_ankle_pitch_l(1,5) = bad_readings_ankle_pitch_l(1,5)+1;
            end
        elseif(dataL.ankle_pitch_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.ankle_pitch_t(i) > 0) && (dataL.ankle_pitch_t(i-1) > 0))
            bad_readings_ankle_pitch_l(1,5) = bad_readings_ankle_pitch_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_pitch_l(1,2) = (bad_readings_ankle_pitch_l(1,2)/bad_readings_ankle_pitch_l(1,1))*100;
bad_readings_ankle_pitch_l(1,3) = (bad_readings_ankle_pitch_l(1,3)/bad_readings_ankle_pitch_l(1,1))*100;
bad_readings_ankle_pitch_l(1,4) = (bad_readings_ankle_pitch_l(1,4)/bad_readings_ankle_pitch_l(1,1))*100;
bad_readings_ankle_pitch_l(1,1) = (bad_readings_ankle_pitch_l(1,1)/height(dataL))*100;
bad_readings_ankle_pitch_l(1,5) = (bad_readings_ankle_pitch_l(1,5)/height(dataL))*100;
bad_readings_ankle_pitch_l(1,6) = max(counters_ankle_pitch_l)/sampleToTdbreadings;
bad_readings_ankle_pitch_l(1,7) = min(counters_ankle_pitch_l)/sampleToTdbreadings;

%% ANKLE_ROLL
counter = 0;
bad_readings_ankle_roll_l = zeros(1,7);
for i = 1:height(dataL)
    if(dataL.ankle_roll_t(i) < 0)
        bad_readings_ankle_roll_l(1,1) = bad_readings_ankle_roll_l(1,1)+1;
        if(dataL.ankle_roll_t(i) < -25 && dataL.ankle_roll_t(i) > -40)
            bad_readings_ankle_roll_l(1,2) = bad_readings_ankle_roll_l(1,2)+1;
        elseif(dataL.ankle_roll_t(i) < -45 && dataL.ankle_roll_t(i) > -60)
            bad_readings_ankle_roll_l(1,3) = bad_readings_ankle_roll_l(1,3)+1;
        elseif(dataL.ankle_roll_t(i) < -85 && dataL.ankle_roll_t(i) > -100)
            bad_readings_ankle_roll_l(1,4) = bad_readings_ankle_roll_l(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_roll_l(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataL))
        if(temperatureSpikeRef == 0 && (dataL.ankle_roll_t(i) > 0) && (dataL.ankle_roll_t(i-1) > 0))
            if(dataL.ankle_roll_t(i) > (dataL.ankle_roll_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataL.ankle_roll_t(i-1);
                bad_readings_ankle_roll_l(1,5) = bad_readings_ankle_roll_l(1,5)+1;
            end
        elseif(dataL.ankle_roll_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataL.ankle_roll_t(i) > 0) && (dataL.ankle_roll_t(i-1) > 0))
            bad_readings_ankle_roll_l(1,5) = bad_readings_ankle_roll_l(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_roll_l(1,2) = (bad_readings_ankle_roll_l(1,2)/bad_readings_ankle_roll_l(1,1))*100;
bad_readings_ankle_roll_l(1,3) = (bad_readings_ankle_roll_l(1,3)/bad_readings_ankle_roll_l(1,1))*100;
bad_readings_ankle_roll_l(1,4) = (bad_readings_ankle_roll_l(1,4)/bad_readings_ankle_roll_l(1,1))*100;
bad_readings_ankle_roll_l(1,1) = (bad_readings_ankle_roll_l(1,1)/height(dataL))*100;
bad_readings_ankle_roll_l(1,5) = (bad_readings_ankle_roll_l(1,5)/height(dataL))*100;
bad_readings_ankle_roll_l(1,6) = max(counters_ankle_roll_l)/sampleToTdbreadings;
bad_readings_ankle_roll_l(1,7) = min(counters_ankle_roll_l)/sampleToTdbreadings;

%% Max, Mean and Std left subpart value
jointNames = ["hip-pitch", "hip-roll", "hip-yaw", "knee", "ankle-pitch", "ankle-roll"];

left_table = array2table([bad_readings_hip_pitch_l', bad_readings_hip_roll_l', bad_readings_hip_yaw_l', bad_readings_knee_l', bad_readings_ankle_pitch_l', bad_readings_ankle_roll_l']);

left_table = renamevars(left_table, 1:width(left_table), jointNames);
%% Analysis of lost readings on the right subpart

counters_hip_pitch_r = 1;
counters_hip_roll_r = 1;
counters_hip_yaw_r = 1;
counters_knee_r = 1;
counters_ankle_pitch_r = 1;
counters_ankle_roll_r = 1;

%% HIP_PITCH
counter = 0;
bad_readings_hip_pitch_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.hip_pitch_t(i) < 0)
        bad_readings_hip_pitch_r(1,1) = bad_readings_hip_pitch_r(1,1)+1;
        if(dataR.hip_pitch_t(i) < -25 && dataR.hip_pitch_t(i) > -40)
            bad_readings_hip_pitch_r(1,2) = bad_readings_hip_pitch_r(1,2)+1;
        elseif(dataR.hip_pitch_t(i) < -45 && dataR.hip_pitch_t(i) > -60)
            bad_readings_hip_pitch_r(1,3) = bad_readings_hip_pitch_r(1,3)+1;
        elseif(dataR.hip_pitch_t(i) < -85 && dataR.hip_pitch_t(i) > -100)
            bad_readings_hip_pitch_r(1,4) = bad_readings_hip_pitch_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_pitch_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.hip_pitch_t(i) > 0) && (dataR.hip_pitch_t(i-1) > 0))
            if(dataR.hip_pitch_t(i) > (dataR.hip_pitch_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.hip_pitch_t(i-1);
                bad_readings_hip_pitch_r(1,5) = bad_readings_hip_pitch_r(1,5)+1;
            end
        elseif(dataR.hip_pitch_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.hip_pitch_t(i) > 0) && (dataR.hip_pitch_t(i-1) > 0))
            bad_readings_hip_pitch_r(1,5) = bad_readings_hip_pitch_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_pitch_r(1,2) = (bad_readings_hip_pitch_r(1,2)/bad_readings_hip_pitch_r(1,1))*100;
bad_readings_hip_pitch_r(1,3) = (bad_readings_hip_pitch_r(1,3)/bad_readings_hip_pitch_r(1,1))*100;
bad_readings_hip_pitch_r(1,4) = (bad_readings_hip_pitch_r(1,4)/bad_readings_hip_pitch_r(1,1))*100;
bad_readings_hip_pitch_r(1,1) = (bad_readings_hip_pitch_r(1,1)/height(dataR))*100;
bad_readings_hip_pitch_r(1,5) = (bad_readings_hip_pitch_r(1,5)/height(dataR))*100;
bad_readings_hip_pitch_r(1,6) = max(counters_hip_pitch_r)/sampleToTdbreadings;
bad_readings_hip_pitch_r(1,7) = min(counters_hip_pitch_r)/sampleToTdbreadings;

%% HIP_ROLL
counter = 0;
bad_readings_hip_roll_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.hip_roll_t(i) < 0)
        bad_readings_hip_roll_r(1,1) = bad_readings_hip_roll_r(1,1)+1;
        if(dataR.hip_roll_t(i) < -25 && dataR.hip_roll_t(i) > -40)
            bad_readings_hip_roll_r(1,2) = bad_readings_hip_roll_r(1,2)+1;
        elseif(dataR.hip_roll_t(i) < -45 && dataR.hip_roll_t(i) > -60)
            bad_readings_hip_roll_r(1,3) = bad_readings_hip_roll_r(1,3)+1;
        elseif(dataR.hip_roll_t(i) < -85 && dataR.hip_roll_t(i) > -100)
            bad_readings_hip_roll_r(1,4) = bad_readings_hip_roll_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_roll_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.hip_roll_t(i) > 0) && (dataR.hip_roll_t(i-1) > 0))
            if(dataR.hip_roll_t(i) > (dataR.hip_roll_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.hip_roll_t(i-1);
                bad_readings_hip_roll_r(1,5) = bad_readings_hip_roll_r(1,5)+1;
            end
        elseif(dataR.hip_roll_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.hip_roll_t(i) > 0) && (dataR.hip_roll_t(i-1) > 0))
            bad_readings_hip_roll_r(1,5) = bad_readings_hip_roll_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_roll_r(1,2) = (bad_readings_hip_roll_r(1,2)/bad_readings_hip_roll_r(1,1))*100;
bad_readings_hip_roll_r(1,3) = (bad_readings_hip_roll_r(1,3)/bad_readings_hip_roll_r(1,1))*100;
bad_readings_hip_roll_r(1,4) = (bad_readings_hip_roll_r(1,4)/bad_readings_hip_roll_r(1,1))*100;
bad_readings_hip_roll_r(1,1) = (bad_readings_hip_roll_r(1,1)/height(dataR))*100;
bad_readings_hip_roll_r(1,5) = (bad_readings_hip_roll_r(1,5)/height(dataR))*100;
bad_readings_hip_roll_r(1,6) = max(counters_hip_roll_r)/sampleToTdbreadings;
bad_readings_hip_roll_r(1,7) = min(counters_hip_roll_r)/sampleToTdbreadings;

%% HIP_YAW
counter = 0;
bad_readings_hip_yaw_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.hip_yaw_t(i) < 0)
        bad_readings_hip_yaw_r(1,1) = bad_readings_hip_yaw_r(1,1)+1;
        if(dataR.hip_yaw_t(i) < -25 && dataR.hip_yaw_t(i) > -40)
            bad_readings_hip_yaw_r(1,2) = bad_readings_hip_yaw_r(1,2)+1;
        elseif(dataR.hip_yaw_t(i) < -45 && dataR.hip_yaw_t(i) > -60)
            bad_readings_hip_yaw_r(1,3) = bad_readings_hip_yaw_r(1,3)+1;
        elseif(dataR.hip_yaw_t(i) < -85 && dataR.hip_yaw_t(i) > -100)
            bad_readings_hip_yaw_r(1,4) = bad_readings_hip_yaw_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_hip_yaw_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.hip_yaw_t(i) > 0) && (dataR.hip_yaw_t(i-1) > 0))
            if(dataR.hip_yaw_t(i) > (dataR.hip_yaw_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.hip_yaw_t(i-1);
                bad_readings_hip_yaw_r(1,5) = bad_readings_hip_yaw_r(1,5)+1;
            end
        elseif(dataR.hip_yaw_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.hip_yaw_t(i) > 0) && (dataR.hip_yaw_t(i-1) > 0))
            bad_readings_hip_yaw_r(1,5) = bad_readings_hip_yaw_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_hip_yaw_r(1,2) = (bad_readings_hip_yaw_r(1,2)/bad_readings_hip_yaw_r(1,1))*100;
bad_readings_hip_yaw_r(1,3) = (bad_readings_hip_yaw_r(1,3)/bad_readings_hip_yaw_r(1,1))*100;
bad_readings_hip_yaw_r(1,4) = (bad_readings_hip_yaw_r(1,4)/bad_readings_hip_yaw_r(1,1))*100;
bad_readings_hip_yaw_r(1,1) = (bad_readings_hip_yaw_r(1,1)/height(dataR))*100;
bad_readings_hip_yaw_r(1,5) = (bad_readings_hip_yaw_r(1,5)/height(dataR))*100;
bad_readings_hip_yaw_r(1,6) = max(counters_hip_yaw_r)/sampleToTdbreadings;
bad_readings_hip_yaw_r(1,7) = min(counters_hip_yaw_r)/sampleToTdbreadings;

%% KNEE
counter = 0;
bad_readings_knee_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.knee_t(i) < 0)
        bad_readings_knee_r(1,1) = bad_readings_knee_r(1,1)+1;
        if(dataR.knee_t(i) < -25 && dataR.knee_t(i) > -40)
            bad_readings_knee_r(1,2) = bad_readings_knee_r(1,2)+1;
        elseif(dataR.knee_t(i) < -45 && dataR.knee_t(i) > -60)
            bad_readings_knee_r(1,3) = bad_readings_knee_r(1,3)+1;
        elseif(dataR.knee_t(i) < -85 && dataR.knee_t(i) > -100)
            bad_readings_knee_r(1,4) = bad_readings_knee_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_knee_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.knee_t(i) > 0) && (dataR.knee_t(i-1) > 0))
            if(dataR.knee_t(i) > (dataR.knee_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.knee_t(i-1);
                bad_readings_knee_r(1,5) = bad_readings_knee_r(1,5)+1;
            end
        elseif(dataR.knee_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.knee_t(i) > 0) && (dataR.knee_t(i-1) > 0))
            bad_readings_knee_r(1,5) = bad_readings_knee_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_knee_r(1,2) = (bad_readings_knee_r(1,2)/bad_readings_knee_r(1,1))*100;
bad_readings_knee_r(1,3) = (bad_readings_knee_r(1,3)/bad_readings_knee_r(1,1))*100;
bad_readings_knee_r(1,4) = (bad_readings_knee_r(1,4)/bad_readings_knee_r(1,1))*100;
bad_readings_knee_r(1,1) = (bad_readings_knee_r(1,1)/height(dataR))*100;
bad_readings_knee_r(1,5) = (bad_readings_knee_r(1,5)/height(dataR))*100;
bad_readings_knee_r(1,6) = max(counters_knee_r)/sampleToTdbreadings;
bad_readings_knee_r(1,7) = min(counters_knee_r)/sampleToTdbreadings;

%% ANKLE_PITCH
counter = 0;
bad_readings_ankle_pitch_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.ankle_pitch_t(i) < 0)
        bad_readings_ankle_pitch_r(1,1) = bad_readings_ankle_pitch_r(1,1)+1;
        if(dataR.ankle_pitch_t(i) < -25 && dataR.ankle_pitch_t(i) > -40)
            bad_readings_ankle_pitch_r(1,2) = bad_readings_ankle_pitch_r(1,2)+1;
        elseif(dataR.ankle_pitch_t(i) < -45 && dataR.ankle_pitch_t(i) > -60)
            bad_readings_ankle_pitch_r(1,3) = bad_readings_ankle_pitch_r(1,3)+1;
        elseif(dataR.ankle_pitch_t(i) < -85 && dataR.ankle_pitch_t(i) > -100)
            bad_readings_ankle_pitch_r(1,4) = bad_readings_ankle_pitch_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_pitch_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.ankle_pitch_t(i) > 0) && (dataR.ankle_pitch_t(i-1) > 0))
            if(dataR.ankle_pitch_t(i) > (dataR.ankle_pitch_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.ankle_pitch_t(i-1);
                bad_readings_ankle_pitch_r(1,5) = bad_readings_ankle_pitch_r(1,5)+1;
            end
        elseif(dataR.ankle_pitch_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.ankle_pitch_t(i) > 0) && (dataR.ankle_pitch_t(i-1) > 0))
            bad_readings_ankle_pitch_r(1,5) = bad_readings_ankle_pitch_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_pitch_r(1,2) = (bad_readings_ankle_pitch_r(1,2)/bad_readings_ankle_pitch_r(1,1))*100;
bad_readings_ankle_pitch_r(1,3) = (bad_readings_ankle_pitch_r(1,3)/bad_readings_ankle_pitch_r(1,1))*100;
bad_readings_ankle_pitch_r(1,4) = (bad_readings_ankle_pitch_r(1,4)/bad_readings_ankle_pitch_r(1,1))*100;
bad_readings_ankle_pitch_r(1,1) = (bad_readings_ankle_pitch_r(1,1)/height(dataR))*100;
bad_readings_ankle_pitch_r(1,5) = (bad_readings_ankle_pitch_r(1,5)/height(dataR))*100;
bad_readings_ankle_pitch_r(1,6) = max(counters_ankle_pitch_r)/sampleToTdbreadings;
bad_readings_ankle_pitch_r(1,7) = min(counters_ankle_pitch_r)/sampleToTdbreadings;

%% ANKLE_ROLL
counter = 0;
bad_readings_ankle_roll_r = zeros(1,7);
for i = 1:height(dataR)
    if(dataR.ankle_roll_t(i) < 0)
        bad_readings_ankle_roll_r(1,1) = bad_readings_ankle_roll_r(1,1)+1;
        if(dataR.ankle_roll_t(i) < -25 && dataR.ankle_roll_t(i) > -40)
            bad_readings_ankle_roll_r(1,2) = bad_readings_ankle_roll_r(1,2)+1;
        elseif(dataR.ankle_roll_t(i) < -45 && dataR.ankle_roll_t(i) > -60)
            bad_readings_ankle_roll_r(1,3) = bad_readings_ankle_roll_r(1,3)+1;
        elseif(dataR.ankle_roll_t(i) < -85 && dataR.ankle_roll_t(i) > -100)
            bad_readings_ankle_roll_r(1,4) = bad_readings_ankle_roll_r(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_roll_r(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(dataR))
        if(temperatureSpikeRef == 0 && (dataR.ankle_roll_t(i) > 0) && (dataR.ankle_roll_t(i-1) > 0))
            if(dataR.ankle_roll_t(i) > (dataR.ankle_roll_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = dataR.ankle_roll_t(i-1);
                bad_readings_ankle_roll_r(1,5) = bad_readings_ankle_roll_r(1,5)+1;
            end
        elseif(dataR.ankle_roll_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (dataR.ankle_roll_t(i) > 0) && (dataR.ankle_roll_t(i-1) > 0))
            bad_readings_ankle_roll_r(1,5) = bad_readings_ankle_roll_r(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_roll_r(1,2) = (bad_readings_ankle_roll_r(1,2)/bad_readings_ankle_roll_r(1,1))*100;
bad_readings_ankle_roll_r(1,3) = (bad_readings_ankle_roll_r(1,3)/bad_readings_ankle_roll_r(1,1))*100;
bad_readings_ankle_roll_r(1,4) = (bad_readings_ankle_roll_r(1,4)/bad_readings_ankle_roll_r(1,1))*100;
bad_readings_ankle_roll_r(1,1) = (bad_readings_ankle_roll_r(1,1)/height(dataR))*100;
bad_readings_ankle_roll_r(1,5) = (bad_readings_ankle_roll_r(1,5)/height(dataR))*100;
bad_readings_ankle_roll_r(1,6) = max(counters_ankle_roll_r)/sampleToTdbreadings;
bad_readings_ankle_roll_r(1,7) = min(counters_ankle_roll_r)/sampleToTdbreadings;


%% Max, Mean and Std right subpart value

right_table = array2table([bad_readings_hip_pitch_r', bad_readings_hip_roll_r', bad_readings_hip_pitch_r', bad_readings_knee_r', bad_readings_ankle_pitch_r', bad_readings_ankle_roll_r']);

right_table = renamevars(right_table, 1:width(right_table), jointNames);


%% Print to console the max, mean and stabdard dec values of lost data for all the joints of each subpart
% Left part

fprintf("Data to be analyzed:\n " + ...
    "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
    "|\t\t hip_pitch | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t hip_roll | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t hip_yaw | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t knee | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t ankle_pitch | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n" + ...
    "|\t\t ankle_roll  | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n", ...
    left_table.("hip-pitch")(6), left_table.("hip-pitch")(1), left_table.("hip-pitch")(2), left_table.("hip-pitch")(3), left_table.("hip-pitch")(4), left_table.("hip-pitch")(5), ...
    left_table.("hip-roll")(6), left_table.("hip-roll")(1), left_table.("hip-roll")(2), left_table.("hip-roll")(3), left_table.("hip-roll")(4), left_table.("hip-roll")(5), ...
    left_table.("hip-yaw")(6), left_table.("hip-yaw")(1), left_table.("hip-yaw")(2), left_table.("hip-yaw")(3), left_table.("hip-yaw")(4), left_table.("hip-yaw")(5), ...
    left_table.("knee")(6), left_table.("knee")(1), left_table.("knee")(2), left_table.("knee")(3), left_table.("knee")(4), left_table.("knee")(5), ...
    left_table.("ankle-pitch")(6), left_table.("ankle-pitch")(1), left_table.("ankle-pitch")(2), left_table.("ankle-pitch")(3), left_table.("ankle-pitch")(4), left_table.("ankle-pitch")(5), ...
    left_table.("ankle-roll")(6), left_table.("ankle-roll")(1), left_table.("ankle-roll")(2), left_table.("ankle-roll")(3), left_table.("ankle-roll")(4), left_table.("ankle-roll")(5));


%% Print to console the max, mean and stabdard dec values of lost data for all the joints of each subpart
% Right part

fprintf("Data to be analyzed:\n " + ...
    "|\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
    "|\t\t hip_pitch | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t hip_roll | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t hip_yaw | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t knee | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t ankle_pitch | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n" + ...
    "|\t\t ankle_roll  | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n", ...
    right_table.("hip-pitch")(6), right_table.("hip-pitch")(1), right_table.("hip-pitch")(2), right_table.("hip-pitch")(3), right_table.("hip-pitch")(4), right_table.("hip-pitch")(5), ...
    right_table.("hip-roll")(6), right_table.("hip-roll")(1), right_table.("hip-roll")(2), right_table.("hip-roll")(3), right_table.("hip-roll")(4), right_table.("hip-roll")(5), ...
    right_table.("hip-yaw")(6), right_table.("hip-yaw")(1), right_table.("hip-yaw")(2), right_table.("hip-yaw")(3), right_table.("hip-yaw")(4), right_table.("hip-yaw")(5), ...
    right_table.("knee")(6), right_table.("knee")(1), right_table.("knee")(2), right_table.("knee")(3), right_table.("knee")(4), right_table.("knee")(5), ...
    right_table.("ankle-pitch")(6), right_table.("ankle-pitch")(1), right_table.("ankle-pitch")(2), right_table.("ankle-pitch")(3), right_table.("ankle-pitch")(4), right_table.("ankle-pitch")(5), ...
    right_table.("ankle-roll")(6), right_table.("ankle-roll")(1), right_table.("ankle-roll")(2), right_table.("ankle-roll")(3), right_table.("ankle-roll")(4), right_table.("ankle-roll")(5));

%% Plot the data lost during the readings

figure
plot(counters_hip_pitch_l);
hold on;
plot(counters_hip_roll_l);
plot(counters_hip_yaw_l);
plot(counters_knee_l)
plot(counters_ankle_pitch_l);
plot(counters_ankle_roll_l);

title('Left Leg Counters');
legend(["hip-pitch", "hip-roll", "hip-yaw", "knee", "ankle-pitch", "ankle-roll"]);
grid("on");

hold off;

figure
plot(counters_hip_pitch_r);
hold on;
plot(counters_hip_roll_r);
plot(counters_hip_yaw_r);
plot(counters_knee_r)
plot(counters_ankle_pitch_r);
plot(counters_ankle_roll_r);

title('Right Leg Counters');
legend(["hip-pitch", "hip-roll", "hip-yaw", "knee", "ankle-pitch", "ankle-roll"]);
grid("on");

hold off;

%% Plot some data we wanna analyze 

figure
plot(dataL.Tabs, dataL.hip_pitch_t);
hold on;
plot(dataL.Tabs, dataL.hip_roll_t);
plot(dataL.Tabs, dataL.hip_yaw_t);

title('Left Hip Leg Temperatures');
legend(["hip-pitch", "hip-roll", "hip-yaw"]);
grid("on");

hold off;

figure
plot(dataR.Tabs, dataR.hip_pitch_t);
hold on;
plot(dataR.Tabs, dataR.hip_roll_t);
plot(dataR.Tabs, dataR.hip_yaw_t);

title('Right Hip Leg Temperatures');
legend(["hip-pitch", "hip-roll", "hip-yaw"]);
grid("on");

hold off;

%%
figure
plot(dataR.Tabs, dataR.ankle_roll_t);

title('Right Ankle Roll Leg Temperatures');
legend("ankle-roll");
grid("on");
