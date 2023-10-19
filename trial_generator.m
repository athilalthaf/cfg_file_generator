turn_on = 0;
turn_off = 1;
port_num = 1:7;
file = fopen("triltext.cfg","w");
switch_state = turn_on;
start = "start";
stop = "stop";
OFF = "off";
ON = "on";
cfg_text = select_port_as_output(0) + select_port_as_output(1);

% pre_command = sprintf("-CreateTrialItem \n \t-SendCommand '''-SetDigitalIOPortDirection AcqSystem1_0 %d Output'''",switch_state)


for i = 0:6
    trial_start_hash = "\n ####### trial starts here";

    start_record = record_state(start,3000);
    port_det = port_state(0,i,OFF,2900);
    stop_record = record_state(stop,2000);
    port_det_2 = port_state(0,i,ON,3000);

    cfg_text  = cfg_text + trial_start_hash+ start_record + port_det + port_det_2 + stop_record;
end





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



