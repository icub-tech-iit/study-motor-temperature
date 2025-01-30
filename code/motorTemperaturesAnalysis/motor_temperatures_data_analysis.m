close all;
clear;
clc;

%%
experiment_data = open("data/motorTemperaturesiRos/robot_logger_device_2024_10_17_11_28_20/robot_logger_device_2024_10_17_11_28_20.mat"); 
temperatures = squeeze(experiment_data.robot_logger_device.walking.motors_state.temperature.measured.data);
timestamps = experiment_data.robot_logger_device.walking.motors_state.temperature.measured.timestamps(:) - experiment_data.robot_logger_device.walking.motors_state.temperature.measured.timestamps(1);
variable_names = experiment_data.robot_logger_device.walking.motors_state.temperature.measured.elements_names;
temperatures_table = array2table(temperatures', "VariableNames",variable_names);

figure_iter = 1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.l_hip_pitch, timestamps, temperatures_table.l_hip_roll, timestamps, temperatures_table.l_hip_yaw);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["l-hip-pitch", "l-hip-roll", "l-hip-yaw"], "Location",	"southeast");
title('Left hip joints temperatures while walking');

figure_iter = figure_iter+1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.l_knee, timestamps, temperatures_table.l_ankle_pitch, timestamps, temperatures_table.l_ankle_roll);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["l-knee", "l-ankle-pitch", "l-ankle-roll"], "Location",	"southeast");
title('Left leg joints temperatures while walking');

figure_iter = figure_iter+1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.torso_pitch, timestamps, temperatures_table.l_shoulder_pitch, timestamps, temperatures_table.l_shoulder_yaw, timestamps, temperatures_table.l_elbow);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["torso-pitch", "l-shoulder-pitch", "l-shoulder-yaw", "l-elbow"], "Location", "southeast");
title('Left upper-body joints temperatures while walking');

figure_iter = figure_iter+1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.r_hip_pitch, timestamps, temperatures_table.r_hip_roll, timestamps, temperatures_table.r_hip_yaw);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["r-hip-pitch", "r-hip-roll", "r-hip-yaw"], "Location",	"southeast");
title('Right hip joints temperatures while walking');

figure_iter = figure_iter+1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.r_knee, timestamps, temperatures_table.r_ankle_pitch, timestamps, temperatures_table.l_ankle_roll);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["r-knee", "r-ankle-pitch", "r-ankle-roll"], "Location",	"southeast");
title('Right level joints temperatures while walking');

figure_iter = figure_iter+1;
%%
figure(figure_iter)
plot(timestamps, temperatures_table.torso_pitch, timestamps, temperatures_table.r_shoulder_pitch, timestamps, temperatures_table.r_shoulder_yaw, timestamps, temperatures_table.r_elbow);
xlabel('Time [s]');
ylabel('Temperatures [Celsius]');
legend(["torso-pitch", "r-shoulder-pitch", "r-shoulder-yaw", "r-elbow"], "Location", "southeast");
title('Left upper-body joints temperatures while walking');

figure_iter = figure_iter+1;


%% Analysis of lost readings on the left subpart

temperature_threshold_spikes = 10;
temperatureSpikeRef = 0;
sampleToTdbreadings = 50;

function bad_readings_joint = evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings) 
    counters_error_joint = 1;
    total_counter = 0;
    bad_readings_joint = zeros(1,7);
    for i = 1:height(joint_temperatures)
        if(joint_temperatures(i) < 0)
            bad_readings_joint(1,1) = bad_readings_joint(1,1)+1;
            if(joint_temperatures(i) < -25 && joint_temperatures(i) > -40)
                bad_readings_joint(1,2) = bad_readings_joint(1,2)+1;
            elseif(joint_temperatures(i) < -45 && joint_temperatures(i) > -60)
                bad_readings_joint(1,3) = bad_readings_joint(1,3)+1;
            elseif(joint_temperatures(i) < -85 && joint_temperatures(i) > -100)
                bad_readings_joint(1,4) = bad_readings_joint(1,4)+1;
            end
            total_counter = total_counter+1;
        elseif(total_counter > 0)
            counters_error_joint(end+1) = total_counter;
            total_counter = 0;
        end
    
        if(i > 2 && i < height(joint_temperatures))
            if(temperatureSpikeRef == 0 && (joint_temperatures(i) > 0) && (joint_temperatures(i-1) > 0))
                if(joint_temperatures(i) > (joint_temperatures(i-1)+temperature_threshold_spikes))
                    temperatureSpikeRef = joint_temperatures(i-1);
                    bad_readings_joint(1,5) = bad_readings_joint(1,5)+1;
                end
            elseif(joint_temperatures(i) > (temperatureSpikeRef+temperature_threshold_spikes) && (joint_temperatures(i) > 0) && (joint_temperatures(i-1) > 0))
                bad_readings_joint(1,5) = bad_readings_joint(1,5)+1;
            else
                temperatureSpikeRef = 0;
            end
        end
    end
    
    bad_readings_joint(1,2) = (bad_readings_joint(1,2)/bad_readings_joint(1,1))*100;
    bad_readings_joint(1,3) = (bad_readings_joint(1,3)/bad_readings_joint(1,1))*100;
    bad_readings_joint(1,4) = (bad_readings_joint(1,4)/bad_readings_joint(1,1))*100;
    bad_readings_joint(1,1) = (bad_readings_joint(1,1)/height(joint_temperatures))*100;
    bad_readings_joint(1,5) = (bad_readings_joint(1,5)/height(joint_temperatures))*100;
    bad_readings_joint(1,6) = max(counters_error_joint)/sampleToTdbreadings;
    bad_readings_joint(1,7) = min(counters_error_joint)/sampleToTdbreadings;
    
    

end


%% TORSO PITCH
joint_temperatures = temperatures_table.torso_pitch;
bad_readings_torso_pitch =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t torso_pitch_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_torso_pitch(1,6), bad_readings_torso_pitch(1,1), bad_readings_torso_pitch(1,2), bad_readings_torso_pitch(1,3), bad_readings_torso_pitch(1,4), bad_readings_torso_pitch(1,5));


%% LEFT HIP_ROLL
joint_temperatures = temperatures_table.l_hip_roll;
bad_readings_left_hip_roll =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t hip_roll_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_hip_roll(1,6), bad_readings_left_hip_roll(1,1), bad_readings_left_hip_roll(1,2), bad_readings_left_hip_roll(1,3), bad_readings_left_hip_roll(1,4), bad_readings_left_hip_roll(1,5));



%% LEFT HIP_YAW
joint_temperatures = temperatures_table.l_hip_yaw;
bad_readings_left_hip_yaw =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t hip_yaw_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_hip_yaw(1,6), bad_readings_left_hip_yaw(1,1), bad_readings_left_hip_yaw(1,2), bad_readings_left_hip_yaw(1,3), bad_readings_left_hip_yaw(1,4), bad_readings_left_hip_yaw(1,5));

%% LEFT KNEE
joint_temperatures = temperatures_table.l_knee;
bad_readings_left_knee =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t knee_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_knee(1,6), bad_readings_left_knee(1,1), bad_readings_left_knee(1,2), bad_readings_left_knee(1,3), bad_readings_left_knee(1,4), bad_readings_left_knee(1,5));



%% LEFT ANKLE_PITCH
joint_temperatures = temperatures_table.l_ankle_pitch;
bad_readings_left_ankle_pitch =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t ankle_pitch_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_ankle_pitch(1,6), bad_readings_left_ankle_pitch(1,1), bad_readings_left_ankle_pitch(1,2), bad_readings_left_ankle_pitch(1,3), bad_readings_left_ankle_pitch(1,4), bad_readings_left_ankle_pitch(1,5));



%% LEFT ANKLE_ROLL
joint_temperatures = temperatures_table.l_ankle_roll;
bad_readings_left_ankle_roll =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t ankle_roll_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_ankle_roll(1,6), bad_readings_left_ankle_roll(1,1), bad_readings_left_ankle_roll(1,2), bad_readings_left_ankle_roll(1,3), bad_readings_left_ankle_roll(1,4), bad_readings_left_ankle_roll(1,5));



%% LEFT SHOULDER_PITCH
joint_temperatures = temperatures_table.l_shoulder_pitch;
bad_readings_left_shoulder_pitch =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t shoulder_pitch_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_shoulder_pitch(1,6), bad_readings_left_shoulder_pitch(1,1), bad_readings_left_shoulder_pitch(1,2), bad_readings_left_shoulder_pitch(1,3), bad_readings_left_shoulder_pitch(1,4), bad_readings_left_shoulder_pitch(1,5));



%% LEFT SHOULDER_YAW
joint_temperatures = temperatures_table.l_shoulder_yaw;
bad_readings_left_shoulder_yaw =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t shoulder_yaw_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_shoulder_yaw(1,6), bad_readings_left_shoulder_yaw(1,1), bad_readings_left_shoulder_yaw(1,2), bad_readings_left_shoulder_yaw(1,3), bad_readings_left_shoulder_yaw(1,4), bad_readings_left_shoulder_yaw(1,5));



%% LEFT ELBOW
joint_temperatures = temperatures_table.l_elbow;
bad_readings_left_elbow =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t elbow_l | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_left_elbow(1,6), bad_readings_left_elbow(1,1), bad_readings_left_elbow(1,2), bad_readings_left_elbow(1,3), bad_readings_left_elbow(1,4), bad_readings_left_elbow(1,5));


%% RIGHT HIP_ROLL
joint_temperatures = temperatures_table.r_hip_roll;
bad_readings_right_hip_roll =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t hip_roll_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_hip_roll(1,6), bad_readings_right_hip_roll(1,1), bad_readings_right_hip_roll(1,2), bad_readings_right_hip_roll(1,3), bad_readings_right_hip_roll(1,4), bad_readings_right_hip_roll(1,5));


%% RIGHT HIP_YAW
joint_temperatures = temperatures_table.r_hip_yaw;
bad_readings_right_hip_yaw =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t hip_yaw_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_hip_yaw(1,6), bad_readings_right_hip_yaw(1,1), bad_readings_right_hip_yaw(1,2), bad_readings_right_hip_yaw(1,3), bad_readings_right_hip_yaw(1,4), bad_readings_right_hip_yaw(1,5));

%% RIGHT KNEE
joint_temperatures = temperatures_table.r_knee;
bad_readings_right_knee =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t knee_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_knee(1,6), bad_readings_right_knee(1,1), bad_readings_right_knee(1,2), bad_readings_right_knee(1,3), bad_readings_right_knee(1,4), bad_readings_right_knee(1,5));



%% RIGHT ANKLE_PITCH
joint_temperatures = temperatures_table.r_ankle_pitch;
bad_readings_right_ankle_pitch =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t ankle_pitch_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_ankle_pitch(1,6), bad_readings_right_ankle_pitch(1,1), bad_readings_right_ankle_pitch(1,2), bad_readings_right_ankle_pitch(1,3), bad_readings_right_ankle_pitch(1,4), bad_readings_right_ankle_pitch(1,5));



%% RIGHT ANKLE_ROLL
joint_temperatures = temperatures_table.r_ankle_roll;
bad_readings_right_ankle_roll =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t ankle_roll_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_ankle_roll(1,6), bad_readings_right_ankle_roll(1,1), bad_readings_right_ankle_roll(1,2), bad_readings_right_ankle_roll(1,3), bad_readings_right_ankle_roll(1,4), bad_readings_right_ankle_roll(1,5));



%% RIGHT SHOULDER_PITCH
joint_temperatures = temperatures_table.r_shoulder_pitch;
bad_readings_right_shoulder_pitch =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t shoulder_pitch_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_shoulder_pitch(1,6), bad_readings_right_shoulder_pitch(1,1), bad_readings_right_shoulder_pitch(1,2), bad_readings_right_shoulder_pitch(1,3), bad_readings_right_shoulder_pitch(1,4), bad_readings_right_shoulder_pitch(1,5));



%% RIGHT SHOULDER_YAW
joint_temperatures = temperatures_table.r_shoulder_yaw;
bad_readings_right_shoulder_yaw =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t shoulder_yaw_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_shoulder_yaw(1,6), bad_readings_right_shoulder_yaw(1,1), bad_readings_right_shoulder_yaw(1,2), bad_readings_right_shoulder_yaw(1,3), bad_readings_right_shoulder_yaw(1,4), bad_readings_right_shoulder_yaw(1,5));



%% RIGHT ELBOW
joint_temperatures = temperatures_table.r_elbow;
bad_readings_right_elbow =  evaluateErrorsInTemps(joint_temperatures, temperature_threshold_spikes, temperatureSpikeRef, sampleToTdbreadings);
fprintf("Data to be analyzed:\n " + ...
        "|\t\t Robot subpart | Max consecutive readings lost | Total neg readings(perc on total) | TDB loses config (perc on neg) | TDB restore def config (perc on neg) | TDB not reading (perc on neg) | Total spikes (perc on total) | \n" + ...
        "|\t\t elbow_r | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | %30.4f | \n ", ...
        bad_readings_right_elbow(1,6), bad_readings_right_elbow(1,1), bad_readings_right_elbow(1,2), bad_readings_right_elbow(1,3), bad_readings_right_elbow(1,4), bad_readings_right_elbow(1,5));
