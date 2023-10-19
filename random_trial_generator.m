tic;
light_stim = ["blue_low","blue_high","uv_low","uv_high","green_low","green_high"]';
light_pin = [4,3,2,5,6,7]';
odour_stim = ["a","b","c","d","e","f","h"]';
odour_pin = (0:6)';
odour_dat = table(odour_stim,odour_pin);
light_dat = table(light_stim,light_pin);

file = fopen("random_gen_10.cfg","w");
start = "start";
stop = "stop";
OFF = "off";
ON = "on";
cfg_text = select_port_as_output(0) + select_port_as_output(1);

light = "blue_low";
light_pin = light_dat.light_pin(light_dat.light_stim == light);

odour_num = 3;
light_num = 1;
reward_stim_num = 1;
cond_num = odour_num + light_num + reward_stim_num ; 
light_idx = 2:light_num + 1;
odour_idx = 2+light_num: cond_num; 
trial_per_condition = 3;

port_for_light = 1;
port_for_odour = 0;
% while true
%     shuffle_list = special_shuffle(cond_num,trial_per_condition);
%     [ele_count,~] = groupcounts(shuffle_list');
%     trial_num_met = ele_count == trial_per_condition * ones(size(cond_num,2), size(cond_num,1));
%     non_cs_plus = shuffle_list(1) ~= 1 ;
%     halting_condition = [trial_num_met;non_cs_plus];
%     if all(halting_condition)
%         break
%     end
% end
shuffle_list = special_shuffle2(cond_num,trial_per_condition);

pin_list = {};
port_list = {};

for i= 1:length(shuffle_list)
    if shuffle_list(i) == 1
        pin_list{i} = [0,light_pin];
        port_list{i} = [port_for_odour,port_for_light];
    elseif shuffle_list(i) == 2;
        pin_list{i} = light_pin;
        port_list{i} = port_for_light;
    elseif shuffle_list(i) == 3;
        pin_list{i} = 0;
        port_list{i} = port_for_odour;
    elseif shuffle_list(i) == 4;
        pin_list{i} = 1;
        port_list{i} = port_for_odour;
    elseif shuffle_list(i) == 5;
        pin_list{i} = 2;
        port_list{i} = port_for_odour;
    end
end

for i = 1:length(shuffle_list)
     trial_start_hash = "\n ####### trial starts here";
    if length(port_list{i}) >1
        start_record = record_state(start,3000);
        port_det_odour = port_state(port_list{i}(1),pin_list{i}(1),OFF,0);
        port_det_light = port_state(port_list{i}(2),pin_list{i}(2),ON,2900);
        port_det_odour_2 = port_state(port_list{i}(1),pin_list{i}(1),ON,0);
        port_det_light_2 = port_state(port_list{i}(2),pin_list{i}(2),OFF,3000);
        stop_record = record_state(stop,2000);

        cfg_text  = cfg_text + trial_start_hash+ start_record + port_det_odour+port_det_light + port_det_odour_2 +port_det_light_2+ stop_record;

    else 
        start_record = record_state(start,3000);
        if port_list{i} == 0
            start_state = OFF;
            end_state = ON;
        else
            start_state = ON;
            end_state = OFF;
        end
        port_det = port_state(port_list{i},pin_list{i},start_state,2900);
        stop_record = record_state(stop,2000);
        port_det_2 = port_state(port_list{i},pin_list{i},end_state,3000);

        cfg_text  = cfg_text + trial_start_hash+ start_record + port_det + port_det_2 + stop_record;
        
    end
end

fl = fprintf(file,  cfg_text);
toc;
function port_state = port_state(port_num,pin_num,state,time_ms)
port_state = sprintf('\n -CreateTrialItem \n \t-SendCommand "-SetDigitalIOBit AcqSystem1_0 %d %d %s"',port_num,pin_num,state) + set_delay(time_ms);
end

function delay = set_delay(time_ms)
delay = sprintf("\n \t-SetDelay %d",time_ms);
end

function port_output = select_port_as_output(port_num)
port_output = sprintf('\n-CreateTrialItem \n \t-SendCommand "-SetDigitalIOPortDirection AcqSystem1_0 %d Output"',port_num) + set_delay(0);

end


function recording = record_state(state,time_ms)
    if state == "start"
        recording = sprintf('\n-CreateTrialItem \n \t-SendCommand "-StartRecording"') + set_delay(time_ms);
    elseif state == "stop"
        recording = sprintf('\n-CreateTrialItem \n \t-SendCommand "-StopRecording"') + set_delay(time_ms);
    else
        warning("unknown recording state");
    end
end


