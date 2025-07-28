tic;
% cd  "C:\Users\athil\OneDrive - uni-bielefeld.de\Desktop\Codes\cfg_file_generator\cfg_file_generator"
phase_name = "pre";    %name whether pre or post     ###### 
% phase_name = "post";    %name whether pre or post     ###### 

light_stim = ["blue_low","blue_high","uv_low","uv_high","green_low","green_high"]'; % all the light combinations

light_pin = [4,3,2,5,6,7]';                 % light pin info for corresponding light
odour_stim = ["peppermint","farnesol","geraniol","d","e","f","h"]'; % arbitrary odour info
odour_pin = (0:6)';   % odour pin info  for corresponding odours

odour_dat = table(odour_stim,odour_pin); % making the table for easy access
light_dat = table(light_stim,light_pin); 

mix_pin = 3:5 ; % info for the mixed pins 


L1 = "blue_high" ;   % light and odour numbers
L2 = "uv_high";   
L3 = "green_high";


O1 = "peppermint";
O2 = "farnesol";
O3 = "geraniol";


time_before_stim  = 3000 ; % Time in ms to start recording 
time_during_stim  = 3000 ; % stimulus presenting time
time_after_stim = time_before_stim ; % time where the recording continues after stim
time_offset = 200 ; % time_delay expected for each command to execute
time_iti = 1 *60 * 1000 ; % iti is 1 mins  
% time_alert_on =  1* 60 * 1000 ; % alert time on 




date_info = date;     % date for the file
file_name = sprintf("%s_trials_%s.cfg",phase_name,date_info); % making the .cgf


file = fopen(file_name,"w");       % open the .cfg files

start = "start";     % states for proxy commands
stop = "stop";
OFF = "off";
ON = "on";

cfg_text = select_port_as_output(0) + select_port_as_output(1); % starting the .cfg file string 

% light = "blue_low";   
% light_pin = light_dat.light_pin(light_dat.light_stim == light);

cond_num = 8; %number of conditions for shuffling list

trial_per_condition = 10; %number of trials per conditions 

port_for_light = 1; % port that denotes the light stimulus
port_for_odour = 0; % port that denotes the odour stimulus

shuffle_list = special_shuffle_no_cs(cond_num,trial_per_condition); % get a list of shuffle where a single stimulus never repeats more than twice
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

%% generating a table that contains all the info

shuffle_table = table((1:length(shuffle_list))', shuffle_list');   % making a table based on the shuffle list 
shuffle_table.Properties.VariableNames =  ["entry_num", "stim_id"]; % renaming 
shuffle_table.stim_name = strings(size(shuffle_list'));    %initialising the different columns
shuffle_table.stim_type = strings(size(shuffle_list'));
shuffle_table.light_port_state = zeros(size(shuffle_list'));
shuffle_table.odour_port_state = zeros(size(shuffle_list'));
shuffle_table.light_pin_num = nan * zeros(size(shuffle_list'));
shuffle_table.odour_pin_num = nan * zeros(size(shuffle_list'));



stim_id_list = ["L1O1","L2O2","L1","L2","L3","O1","O2","O3"];    % setting the stimulus types and their respective pins and  port info
stim_name_list = [L1 + "+" + O1, L2 + "+" + O2, L1,L2,L3,O1,O2,O3];
light_port_state = [zeros(1,2),ones(1,3) , zeros(1,3)];
odour_port_state = [ones(1,2),zeros(1,3),ones(1,3)];      % odour ports are used for mix stim as well

for name = 1:numel(stim_id_list) % filling the elements whose entry can be deduced from the stim_id itself
   shuffle_table.stim_name(shuffle_table.stim_id == name) = stim_id_list(name);
   shuffle_table.stim_type(shuffle_table.stim_id == name) = stim_name_list(name);
   shuffle_table.light_port_state(shuffle_table.stim_id == name) = light_port_state(name);
   shuffle_table.odour_port_state(shuffle_table.stim_id == name) = odour_port_state(name);

end

for entry = 1: height(shuffle_table)   % filling the elements elements that requires a row by row info
    if shuffle_table.light_port_state(entry) == 1  % if light port is on
       if length(char(shuffle_table.stim_name(entry))) == 2  % and if if its not a mix stim char num of mix stim is 4 and others are 2
            shuffle_table.light_pin_num(entry) = light_dat.light_pin( light_dat.light_stim ==  shuffle_table.stim_type(entry)); % fill the pin entry
       else                                        % if a mix stim
            light_and_odour = split(shuffle_table.stim_type(entry), "+"); % split to isolate the info 
            light_part_of_mix = light_and_odour(1); 
            shuffle_table.light_pin_num(entry) = light_dat.light_pin(light_dat.light_stim ==light_part_of_mix ); 
            
       end
    
        
    end


    if shuffle_table.odour_port_state(entry) == 1 % same goes for odour
       if length(char(shuffle_table.stim_name(entry))) == 2
            shuffle_table.odour_pin_num(entry) = odour_dat.odour_pin( odour_dat.odour_stim ==  shuffle_table.stim_type(entry));
       else
            light_and_odour = split(shuffle_table.stim_type(entry), "+");
            odour_part_of_mix = light_and_odour(2);
            shuffle_table.odour_pin_num(entry) = shuffle_table.stim_id(entry) + 2;
            
       end
    
        
    end

end


file_name_xl = strrep(file_name,".cfg",".xlsx"); % renaming and writing for the xl file
writetable(shuffle_table,file_name_xl); 
 
%% now using the table info for the .cfg file
for i = 1:length(shuffle_list)  % for each entry in the table 
     trial_start_hash = sprintf("\n ####### stim: %s  trial number: %d ",shuffle_table.stim_type(i),i); % just to which trial is starting and the type of stimulus
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
        start_record = record_state(start,time_before_stim - time_offset); % start recording 
        if shuffle_table.odour_port_state(i) == 1 % if odour port is one 
%             start_state = ON;
%             end_state = OFF;
            set_port = port_for_odour;   % set the corresponding port and pin num
            set_pin = shuffle_table.odour_pin_num(i); 
        else                            % same but for light
%             start_state = ON;
%             end_state = OFF;
            set_port = port_for_light;   
            set_pin = shuffle_table.light_pin_num(i);
        end
        port_det = port_state(set_port,set_pin,ON,time_during_stim - time_offset);    % turning the corresponding pin on and off with corresponding delay
        port_det_2 = port_state(set_port,set_pin,OFF,time_after_stim); 

        stop_record = record_state(stop,time_iti - 2 * time_after_stim - time_offset); % stop recording and making the ITI to a 1 minute
         
        cfg_text  = cfg_text + trial_start_hash+ start_record + port_det + port_det_2 + stop_record; % joining all the string 
        
%     end
end

fl = fprintf(file,  cfg_text); % write the string to the file

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
