close all;
clear;
clc;

%% Import data as table

data = readtable('single_joint/data.log');
data = renamevars(data, 1:width(data), ["ID", "Tabs", "Trel", "shoulder_yaw_t", "shoulder_yaw_oh", "elbow_t", "elbow_oh"]);

%% Adjust second column of data thus to have times relative to start of experiment
data.Tabs = data.Tabs - data.Tabs(1);

%% Print temperature data
figure
plot(data, "Tabs", ["shoulder_yaw_t", "elbow_t"]);
grid("on");

title('Setup Temperatures');
legend(["shoulder-yaw", "elbow"]);

%% Analysis of lost readings on the left subpart

counters_shoulder_yaw = 1;
counters_elbow = 1;

temperature_threshold_spikes = 10;
counter = 0;
temperatureSpikeRef = 0;
sampleToTdbreadings = 50;

%% SHOULDER_YAW

bad_readings_shoulder_yaw = zeros(1,7);

for i = 1:height(data)
    if(data.shoulder_yaw_t(i) < 0)
        bad_readings_shoulder_yaw(1,1) = bad_readings_shoulder_yaw(1,1)+1;
        if(data.shoulder_yaw_t(i) < -25 && data.shoulder_yaw_t(i) > -40)
            bad_readings_shoulder_yaw(1,2) = bad_readings_shoulder_yaw(1,2)+1;
        elseif(data.shoulder_yaw_t(i) < -45 && data.shoulder_yaw_t(i) > -60)
            bad_readings_shoulder_yaw(1,3) = bad_readings_shoulder_yaw(1,3)+1;
        elseif(data.shoulder_yaw_t(i) < -85 && data.shoulder_yaw_t(i) > -100)
            bad_readings_shoulder_yaw(1,4) = bad_readings_shoulder_yaw(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_shoulder_yaw(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(data))
        if(temperatureSpikeRef == 0 && (data.shoulder_yaw_t(i) > 0) && (data.shoulder_yaw_t(i-1) > 0))
            if(data.shoulder_yaw_t(i) > (data.shoulder_yaw_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = data.shoulder_yaw_t(i-1);
                bad_readings_shoulder_yaw(1,5) = bad_readings_shoulder_yaw(1,5)+1;
            end
        elseif(data.shoulder_yaw_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (data.shoulder_yaw_t(i) > 0) && (data.shoulder_yaw_t(i-1) > 0))
            bad_readings_shoulder_yaw(1,5) = bad_readings_shoulder_yaw(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_shoulder_yaw(1,2) = (bad_readings_shoulder_yaw(1,2)/height(data))*100;
bad_readings_shoulder_yaw(1,3) = (bad_readings_shoulder_yaw(1,3)/height(data))*100;
bad_readings_shoulder_yaw(1,4) = (bad_readings_shoulder_yaw(1,4)/height(data))*100;
bad_readings_shoulder_yaw(1,1) = (bad_readings_shoulder_yaw(1,1)/height(data))*100;
bad_readings_shoulder_yaw(1,5) = (bad_readings_shoulder_yaw(1,5)/height(data))*100;
bad_readings_shoulder_yaw(1,6) = max(counters_shoulder_yaw)/sampleToTdbreadings;
bad_readings_shoulder_yaw(1,7) = min(counters_shoulder_yaw)/sampleToTdbreadings;

%% ELBOW
counter = 0;
bad_readings_elbow = zeros(1,7);
for i = 1:height(data)
    if(data.elbow_t(i) < 0)
        bad_readings_elbow(1,1) = bad_readings_elbow(1,1)+1;
        if(data.elbow_t(i) < -25 && data.elbow_t(i) > -40)
            bad_readings_elbow(1,2) = bad_readings_elbow(1,2)+1;
        elseif(data.elbow_t(i) < -45 && data.elbow_t(i) > -60)
            bad_readings_elbow(1,3) = bad_readings_elbow(1,3)+1;
        elseif(data.elbow_t(i) < -85 && data.elbow_t(i) > -100)
            bad_readings_elbow(1,4) = bad_readings_elbow(1,4)+1;
        end
        counter = counter+1;
    elseif(counter > 0)
        counters_elbow(end+1) = counter;
        counter = 0;
    end

    if(i > 2 && i < height(data))
        if(temperatureSpikeRef == 0 && (data.elbow_t(i) > 0) && (data.elbow_t(i-1) > 0))
            if(data.elbow_t(i) > (data.elbow_t(i-1)+temperature_threshold_spikes))
                temperatureSpikeRef = data.elbow_t(i-1);
                bad_readings_elbow(1,5) = bad_readings_elbow(1,5)+1;
            end
        elseif(data.elbow_t(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (data.elbow_t(i) > 0) && (data.elbow_t(i-1) > 0))
            bad_readings_elbow(1,5) = bad_readings_elbow(1,5)+1;
        else
            temperatureSpikeRef = 0;
        end
    end
end

bad_readings_elbow(1,2) = (bad_readings_elbow(1,2)/height(data))*100;
bad_readings_elbow(1,3) = (bad_readings_elbow(1,3)/height(data))*100;
bad_readings_elbow(1,4) = (bad_readings_elbow(1,4)/height(data))*100;
bad_readings_elbow(1,1) = (bad_readings_elbow(1,1)/height(data))*100;
bad_readings_elbow(1,5) = (bad_readings_elbow(1,5)/height(data))*100;
bad_readings_elbow(1,6) = max(counters_elbow)/sampleToTdbreadings;
bad_readings_elbow(1,7) = min(counters_elbow)/sampleToTdbreadings;

%% Max, Mean and Std left subpart value
jointNames = ["shoulder_yaw", "elbow"];

table = array2table([bad_readings_shoulder_yaw', bad_readings_elbow']);

table = renamevars(table, 1:width(table), jointNames);

%% Print to console the max, mean and stabdard dec values of lost data for all the joints of each subpart
% Setup

fprintf("Data to be analyzed:\n " + ...
    "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
    "|\t\t shoulder_yaw | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n " + ...
    "|\t\t elbow | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
    table.("shoulder_yaw")(6), table.("shoulder_yaw")(1), table.("shoulder_yaw")(2), table.("shoulder_yaw")(3), table.("shoulder_yaw")(4), table.("shoulder_yaw")(5), ...
    table.("elbow")(6), table.("elbow")(1), table.("elbow")(2), table.("elbow")(3), table.("elbow")(4), table.("elbow")(5));

%% Plot the data lost during the readings

figure
plot(counters_shoulder_yaw);
hold on;
plot(counters_elbow);

title('Error Reading Counters');
legend(["shoulder-yaw", "elbow"]);
grid("on");

hold off;
