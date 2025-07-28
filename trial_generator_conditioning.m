tic;
phase_name = "cond";   %name the file as conditioning     ###### 
light_stim = ["blue_low","blue_high","uv_low","uv_high","green_low","green_high"]'; % all the light combinations

light_pin = [4,3,2,5,6,7]'; % light pin info for corresponding light
odour_stim = ["peppermint","farnesol","geraniol","d","e","f","h"]'; % arbitrary odour info
odour_pin = (0:6)';
odour_dat = table(odour_stim,odour_pin);
light_dat = table(light_stim,light_pin);

mix_pin = (3:5)' ;  % mix pin info
mix_stim = ["blue_high+peppermint","uv_high+farnesol","green_high+geraniol"]';  % combinations of the mix pin
mix_dat = table(mix_stim,mix_pin);

% only a set of combinations are allowed as shown in the mix_stim_table.
% ###########
% L1 = "uv_high"; % change each alterative experiment to uv_high and blue_high
% O1 = "farnesol";     % change from peppermint and farnesol   
% ###########
L1 = "blue_high"; % change each alterative experiment to uv_high and blue_high
O1 = "peppermint";     % chan  ge from peppermint and farnesol
% ###########


% L2 = "uv_high";
% L3 = "green_high";


% O2 = "b";
% O3 = "c";

time_before_stim  = 3000 ; % Time in ms to start recording 
time_during_stim  = 7000 ; % stimulus presenting time
time_after_stim = time_before_stim ; % time where the recording continues after stim
time_offset = 200 ; % time_delay expected for each command to execute
time_iti = 5 *60 * 1000 ; % iti is 5 mins  
time_alert_on =  1* 60 * 1000 ; % alert time on 
time_reward = 4000; 




date_info = date; % date for the file
file_name = sprintf("%s_trials_%s.cfg",phase_name,date_info); % making the .cgf


file = fopen(file_name,"w");  % open the .cfg files
start = "start";  % states for proxy commands
stop = "stop"; 
OFF = "off";
ON = "on";
cfg_text = select_port_as_output(0) + select_port_as_output(1);  % starting the .cfg file string 

% light = "blue_low";
% light_pin = light_dat.light_pin(light_dat.light_stim == light);

cond_num = 3; %number of conditions for shuffling list

trial_per_condition = 10; %number of trials per conditions

port_for_light = 1; % setting port infos
port_for_odour = 0;
port_for_alert = 1; % conditioning requires alert function , alert port is the light port itself
pin_for_alert = 0;  % info for alert pin
 
shuffle_list = special_shuffle_cs(cond_num,trial_per_condition); % shuffle the list for trails 
% while true
%     
%     shuffle_list = special_shuffle(cond_num,trial_per_condition);
%     [ele_count,~] = groupcounts(shuffle_list');
%     trial_num_met = ele_count == trial_per_condition * ones(size(cond_num,2), size(cond_num,1));
% %     non_cs_plus = shuffle_list(1) ~= 3 ;
%     halting_condition = trial_num_met;
%     if all(halting_condition)
%         break
%     end
% end



shuffle_table = table((1:length(shuffle_list))',shuffle_list');
shuffle_table.Properties.VariableNames =  ["entry_num", "stim_id"];
shuffle_table.stim_name = strings(size(shuffle_list'));
shuffle_table.stim_type = strings(size(shuffle_list'));
shuffle_table.light_port_state = zeros(size(shuffle_list'));
shuffle_table.odour_port_state = zeros(size(shuffle_list'));
shuffle_table.light_pin_num = nan * zeros(size(shuffle_list'));
shuffle_table.odour_pin_num = nan * zeros(size(shuffle_list'));



stim_id_list = ["L1O1","L1","O1"];
stim_name_list = [L1 + "+" + O1, L1,O1,];
light_port_state = [0,1,0];
odour_port_state = [1,0,1];

for name = 1:numel(stim_id_list)
   shuffle_table.stim_name(shuffle_table.stim_id == name) = stim_id_list(name);
   shuffle_table.stim_type(shuffle_table.stim_id == name) = stim_name_list(name);
   shuffle_table.light_port_state(shuffle_table.stim_id == name) = light_port_state(name);
   shuffle_table.odour_port_state(shuffle_table.stim_id == name) = odour_port_state(name);

end

for entry = 1: height(shuffle_table)
    if shuffle_table.light_port_state(entry) == 1
       if length(char(shuffle_table.stim_name(entry))) == 2
            shuffle_table.light_pin_num(entry) = light_dat.light_pin( light_dat.light_stim ==  shuffle_table.stim_type(entry));
       else
            light_and_odour = split(shuffle_table.stim_type(entry), "+");
            light_part_of_mix = light_and_odour(1);
            shuffle_table.light_pin_num(entry) = light_dat.light_pin(light_dat.light_stim ==light_part_of_mix );
            
       end
    
        
    end


    if shuffle_table.odour_port_state(entry) == 1
       if length(char(shuffle_table.stim_name(entry))) == 2
            shuffle_table.odour_pin_num(entry) = odour_dat.odour_pin( odour_dat.odour_stim ==  shuffle_table.stim_type(entry));
       else
            light_and_odour = split(shuffle_table.stim_type(entry), "+");
            odour_part_of_mix = light_and_odour(2);
%             shuffle_table.odour_pin_num(entry) = shuffle_table.stim_id(entry) + 2;
            shuffle_table.odour_pin_num(entry) = mix_dat.mix_pin(mix_dat.mix_stim == shuffle_table.stim_type(entry));
            
       end
    
        
    end

end

alert_idxs = shuffle_table.entry_num(shuffle_table.stim_id == 1) - 1;
shuffle_table.alert = nan * zeros(size(shuffle_list'));
shuffle_table.alert(alert_idxs) = 1;
file_name_xl = strrep(file_name,".cfg",".xlsx"); 
writetable(shuffle_table,file_name_xl);
 

for i = 1:length(shuffle_list)
     trial_start_hash = sprintf("\n ####### stim: %s  trial number: %d    alert_state: %d",shuffle_table.stim_type(i),i, shuffle_table.alert(i));
%     if shuffle_table.light_port_state(i)== shuffle_table.odour_port_state(i)
%         start_record = record_state(start,3000);
%         port_det_odour = port_state(port_for_odour,shuffle_table.odour_pin_num(i),OFF,0);
%         port_det_light = port_state(port_for_light,shuffle_table.light_pin_num(i),ON,2900);
%         port_det_odour_2 = port_state(port_for_odour,shuffle_table.odour_pin_num(i),ON,0);
%         port_det_light_2 = port_state(port_for_light,shuffle_table.light_pin_num(i),OFF,3000);
%         stop_record = record_state(stop,2000);
% 
%         cfg_text  = cfg_text + trial_start_hash+ start_record + port_det_odour+port_det_light + port_det_odour_2 +port_det_light_2+ stop_record;
% 
%     else 
        start_record = record_state(start,time_before_stim - time_offset);
        if shuffle_table.odour_port_state(i) == 1    % setting the respective port for odour
%             start_state = ON;
%             end_state = OFF;
            set_port = port_for_odour;
            set_pin = shuffle_table.odour_pin_num(i);   
        else
%             start_state = ON;
%             end_state = OFF;
            set_port = port_for_light;
            set_pin = shuffle_table.light_pin_num(i);
        end
        if shuffle_table.stim_id(i) == 1 
            port_det = port_state(set_port,set_pin,ON,time_reward - time_offset) + port_state(port_for_alert,pin_for_alert,OFF,time_during_stim - time_reward - time_offset);
            
        else 
            port_det = port_state(set_port,set_pin,ON,time_during_stim - time_offset);
        end
               
        port_det_2 = port_state(set_port,set_pin,OFF,time_after_stim);
        

        if shuffle_table.alert(i) ==1
            stop_record = record_state(stop,time_iti - 2 * time_after_stim - time_alert_on) + port_state(port_for_alert,pin_for_alert,ON,time_alert_on);
        else
            
            stop_record = record_state(stop,time_iti - 2 * time_after_stim - time_offset);
        end

 
        
        cfg_text  = cfg_text + trial_start_hash+ start_record + port_det + port_det_2 + stop_record;
        
%     end
end

fl = fprintf(file,  cfg_text);

toc;
%% Proxy commands

function port_state = port_state(port_num,pin_num,state,time_ms) %setting state of a pin and delay followed by it
port_state = sprintf('\n -CreateTrialItem \n \t-SendCommand "-SetDigitalIOBit AcqSystem1_0 %d %d %s"',port_num,pin_num,state) + set_delay(time_ms);
end

function delay = set_delay(time_ms) %setting a delay
delay = sprintf("\n \t-SetDelay %d",time_ms);
end

function port_output = select_port_as_output(port_num) %setting a port as output
port_output = sprintf('\n-CreateTrialItem \n \t-SendCommand "-SetDigitalIOPortDirection AcqSystem1_0 %d Output"',port_num) + set_delay(0);

end


function recording = record_state(state,time_ms) %setting state of recording and delay followed by it
    if state == "start"
        recording = sprintf('\n-CreateTrialItem \n \t-SendCommand "-StartRecording"') + set_delay(time_ms);
    elseif state == "stop"
        recording = sprintf('\n-CreateTrialItem \n \t-SendCommand "-StopRecording"') + set_delay(time_ms);
    else
        warning("unknown recording state");
    end
end
