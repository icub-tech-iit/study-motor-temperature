close all;
clear;
clc;

%% Import data as table

data = readtable('leg_joints_sebset/data.log');
data = renamevars(data, 1:width(data), ["ID", "Tabs", "Trel", "hip_pitch_t", "hip_pitch_oh", "hip_roll_t", "hip_roll_oh", "hip_yaw_t", "hip_yaw_oh", "knee_t", "knee_oh", "ankle_pitch_t", "ankle_pitch_oh", "ankle_roll_t", "ankle_roll_oh"]);

%% Adjust second column of data thus to have times relative to start of experiment
data.Tabs = data.Tabs - data.Tabs(1);

%% Print temperature data

figure
plot(data, "Tabs", ["ankle_pitch_t", "ankle_roll_t"]);
grid("on");
title('Left Leg Temperatures');
legend(["ankle-pitch", "ankle-roll"]);

%% Analysis of lost readings on the left subpart
counters_ankle_pitch = 1;
counters_ankle_roll = 1;

temperature_threshold_spikes = 10;
counter = 0;
temperatureSpikeRef = 0;
sampleToTdbreadings = 50;

%% ANKLE_PITCH
counter = 0;
bad_readings_ankle_pitch = zeros(1,7);
for i = 1:height(data)
    if(data.ankle_pitch_t(i) < 0)
        bad_readings_ankle_pitch(1,1) = bad_readings_ankle_pitch(1,1)+1;
        if(data.ankle_pitch_t(i) < -25 && data.ankle_pitch_t(i) > -40)
            bad_readings_ankle_pitch(1,2) = bad_readings_ankle_pitch(1,2)+1;
        elseif(data.ankle_pitch_t(i) < -45 && data.ankle_pitch_t(i) > -60)
            bad_readings_ankle_pitch(1,3) = bad_readings_ankle_pitch(1,3)+1;
        elseif(data.ankle_pitch_t(i) < -85 && data.ankle_pitch_t(i) > -100)
            bad_readings_ankle_pitch(1,4) = bad_readings_ankle_pitch(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_pitch(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(data))
        if(temperatureSpikeRef == 0 && (data.ankle_pitch_t(i) > 0) && (data.ankle_pitch_t(i-1) > 0))
            if(data.ankle_pitch_t(i) > (data.ankle_pitch_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = data.ankle_pitch_t(i-1);
                bad_readings_ankle_pitch(1,5) = bad_readings_ankle_pitch(1,5)+1;
            end
        elseif(data.ankle_pitch_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (data.ankle_pitch_t(i) > 0) && (data.ankle_pitch_t(i-1) > 0))
            bad_readings_ankle_pitch(1,5) = bad_readings_ankle_pitch(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_pitch(1,2) = (bad_readings_ankle_pitch(1,2)/bad_readings_ankle_pitch(1,1))*100;
bad_readings_ankle_pitch(1,3) = (bad_readings_ankle_pitch(1,3)/bad_readings_ankle_pitch(1,1))*100;
bad_readings_ankle_pitch(1,4) = (bad_readings_ankle_pitch(1,4)/bad_readings_ankle_pitch(1,1))*100;
bad_readings_ankle_pitch(1,1) = (bad_readings_ankle_pitch(1,1)/height(data))*100;
bad_readings_ankle_pitch(1,5) = (bad_readings_ankle_pitch(1,5)/height(data))*100;
bad_readings_ankle_pitch(1,6) = max(counters_ankle_pitch)/sampleToTdbreadings;
bad_readings_ankle_pitch(1,7) = min(counters_ankle_pitch)/sampleToTdbreadings;

%% ANKLE_ROLL
counter = 0;
bad_readings_ankle_roll = zeros(1,7);
for i = 1:height(data)
    if(data.ankle_roll_t(i) < 0)
        bad_readings_ankle_roll(1,1) = bad_readings_ankle_roll(1,1)+1;
        if(data.ankle_roll_t(i) < -25 && data.ankle_roll_t(i) > -40)
            bad_readings_ankle_roll(1,2) = bad_readings_ankle_roll(1,2)+1;
        elseif(data.ankle_roll_t(i) < -45 && data.ankle_roll_t(i) > -60)
            bad_readings_ankle_roll(1,3) = bad_readings_ankle_roll(1,3)+1;
        elseif(data.ankle_roll_t(i) < -85 && data.ankle_roll_t(i) > -100)
            bad_readings_ankle_roll(1,4) = bad_readings_ankle_roll(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_ankle_roll(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(data))
        if(temperatureSpikeRef == 0 && (data.ankle_roll_t(i) > 0) && (data.ankle_roll_t(i-1) > 0))
            if(data.ankle_roll_t(i) > (data.ankle_roll_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = data.ankle_roll_t(i-1);
                bad_readings_ankle_roll(1,5) = bad_readings_ankle_roll(1,5)+1;
            end
        elseif(data.ankle_roll_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (data.ankle_roll_t(i) > 0) && (data.ankle_roll_t(i-1) > 0))
            bad_readings_ankle_roll(1,5) = bad_readings_ankle_roll(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_ankle_roll(1,2) = (bad_readings_ankle_roll(1,2)/bad_readings_ankle_roll(1,1))*100;
bad_readings_ankle_roll(1,3) = (bad_readings_ankle_roll(1,3)/bad_readings_ankle_roll(1,1))*100;
bad_readings_ankle_roll(1,4) = (bad_readings_ankle_roll(1,4)/bad_readings_ankle_roll(1,1))*100;
bad_readings_ankle_roll(1,1) = (bad_readings_ankle_roll(1,1)/height(data))*100;
bad_readings_ankle_roll(1,5) = (bad_readings_ankle_roll(1,5)/height(data))*100;
bad_readings_ankle_roll(1,6) = max(counters_ankle_roll)/sampleToTdbreadings;
bad_readings_ankle_roll(1,7) = min(counters_ankle_roll)/sampleToTdbreadings;

%% Max, Mean and Std left subpart value
jointNames = ["ankle-pitch", "ankle-roll"];

table = array2table([bad_readings_ankle_pitch', bad_readings_ankle_roll']);

table = renamevars(table, 1:width(table), jointNames);

%% Print to console the max, mean and stabdard dec values of lost data for all the joints of each subpart
% Left part

fprintf("Data to be analyzed:\n " + ...
    "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
    "|\t\t ankle_pitch | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n" + ...
    "|\t\t ankle_roll  | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n", ...
    table.("ankle-pitch")(6), table.("ankle-pitch")(1), table.("ankle-pitch")(2), table.("ankle-pitch")(3), table.("ankle-pitch")(4), table.("ankle-pitch")(5), ...
    table.("ankle-roll")(6), table.("ankle-roll")(1), table.("ankle-roll")(2), table.("ankle-roll")(3), table.("ankle-roll")(4), table.("ankle-roll")(5));

%% Plot the data lost during the readings

figure
plot(counters_ankle_pitch);
hold on;
plot(counters_ankle_roll);

title('Left Leg Counters');
legend(["ankle-pitch", "ankle-roll"]);
grid("on");

hold off;