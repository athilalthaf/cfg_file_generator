function shuffle_list = special_shuffle_cs(cond_num,trial_per_cond)
        shuffle_list = special_shuffle_no_cs(cond_num,trial_per_cond);
                if shuffle_list(1) == 1
                    while true
                        shuffle_list = special_shuffle_no_cs(cond_num,trial_per_cond);
                        if shuffle_list(1) ~= 1
                            break;
                    
                        end
                
                    end
                end
end
