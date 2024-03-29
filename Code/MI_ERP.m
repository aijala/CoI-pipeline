%% ESTIMATES MI AND GETS ELECTRODES OF INTEREST
% Estimates MI via gaussian copula estimation (Ince et al., 2016), performs
% parametric permutation testing and saves electrodes with significant MI
% into a mat-file.

clear all

%Get the parameters for the participant and datatype you wants
[basefold, datatype, subject, all_con, condition, participants, ~ , re_epoch, dev_epochs, std_epochs, epoch_length, srate, low_cutoff, high_cutoff, filt_order, baseline, start_cut_off, end_cut_off, kperm] = Get_param(0);

%Go through all specified participants and conditions
for i = 1: length(participants)
    for con = 1:length(all_con)
        %% IMPORT DATA
        % Import data and check for same amount of trials & channels
        [dvt, std] = impiEEG(i, basefold, datatype, all_con(con), srate, low_cutoff, high_cutoff, filt_order,re_epoch, dev_epochs, std_epochs, epoch_length);

        if (dvt.nbchan < std.nbchan)
            channum = dvt.nbchan;
            std = pop_select(std, 'channel', 1:channum);
        else
            channum = std.nbchan;
            dvt = pop_select(dvt, 'channel', 1:channum);
        end

        if (dvt.trials < std.trials)
            trialnum = dvt.trials;
            std = pop_select(std, 'trial', 1:trialnum);
        else
            trialnum = std.trials;
            dvt = pop_select(dvt, 'trial', 1:trialnum);
        end

        if (std.nbchan < dvt.nbchan)
            channum = std.nbchan;
            dvt = pop_select(dvt, 'channel', 1:channum);
        else
            channum = dvt.nbchan;
            std = pop_select(std, 'channel', 1:channum);
        end

        if (std.trials < dvt.trials)
            trialnum = std.trials;
            dvt = pop_select(dvt, 'trial', 1:trialnum)
        else
            trialnum = std.trials;
            std = pop_select(std, 'trial', 1:trialnum)
        end

        %% BASELINE NORMALISATION
        data_dvt = permute(dvt.data,[1 3 2]); mean_data_dvt = squeeze(mean(data_dvt(:,:,baseline),3));
        dvt.data = data_dvt - repmat(mean_data_dvt,[1 1 size(dvt.data,2)]);
        dvt.data(:,:,start_cut_off) = [];
        dvt.data(:,:,end_cut_off:end) = [];
        bb1_dev_bl = permute(dvt.data,[1 3 2]);

        data_std = permute(std.data,[1 3 2]); mean_data_std = squeeze(mean(data_std(:,:,baseline),3));
        std.data = data_std - repmat(mean_data_std,[1 1 size(std.data,2)]);
        std.data(:,:,start_cut_off) = [];
        std.data(:,:,end_cut_off:end) = [];
        bb1_std_bl = permute(std.data,[1 3 2]);

        bb_dev = permute(bb1_dev_bl,[3 1 2]);
        bb_std = permute(bb1_std_bl,[3 1 2]);

    %% CALCULATE MUTUAL INFORMATION & PERFORM PERMUTATION TESTING USING GCMI
    
    elec_of_I = {};
    H = figure(con);
    for ch = 1 : dvt.nbchan
        chnum = strcat('ch_',string(ch));
        dat.class1.BB = squeeze(bb_dev(:, ch, :));
        dat.class2.BB = squeeze(bb_std(:, ch, :));

        %Calculate MI between the specified channels
        [MI, sigMask] = cnm_MI_stimtime([dat.class1.BB; dat.class2.BB],[zeros(1, size(bb_dev,1)), ones(1, size(bb_dev,1))]', kperm);
        
        %save
        chan_name = strcat('E',num2str(ch));
        MI_stat.(participants{i}).(all_con{con}).MI.(chan_name) = MI;
        MI_stat.(participants{i}).(all_con{con}).electrode = chan_name;
        MI_stat.(participants{i}).(all_con{con}).sigMask.(chan_name)= sigMask;

        %% PLOT
        %get correct timing
        timing = dvt.times;
        timing(start_cut_off) = [];
        timing(end_cut_off:end) = [];
        timing = timing';
        
        %plot MI
        nexttile(ch)
        plot(timing, MI_stat.(participants{i}).(all_con{con}).MI.(chan_name));
        title(chan_name)
        hold on;
        xlabel('Time [ms]');
        yLimits = [-0.001 0.1];
%         xlim([0.7 1.150])
        pos_sigbar = yLimits(2) - (0.07 * range(yLimits));

        % Draw stats
        stat=logical(MI_stat.(participants{i}).(all_con{con}).sigMask.(chan_name));
        ylim(yLimits);
        ylabel('Mutual information (bits)');

        EoI_list = false;
        for tIdx = 1:length(timing)-1
            tIdx2 = timing(tIdx);
            tIdx2_1 = timing(tIdx+1);
            if stat(tIdx) > 0
                plot([tIdx2, tIdx2_1], [pos_sigbar, pos_sigbar], 'LineWidth', 3, 'Color', 'm');
                EoI_list = true;
            end
        end
        
        %List electrodes of interest
        if EoI_list == true
            chan = (MI_stat.(participants{i}).(all_con{con}).electrode(i));
            chan = replace(chan,'-','_');
            Electorodes.(chan_name) = chan_name;
        end
        hold off
    end
    
    %% SAVE ALL
    basename = strcat (participants(i), 'MIs.mat');
    EoI_names = strcat (participants(i), 'EoI.mat');
    cd (basefold)
    saveas(H,strcat(char(participants(i)),'_MI_figures_local'),'fig');
    EoI.(char(participants(i))).(char(all_con(con))) = Electorodes;
    EoI.(char(participants(i))).(char(all_con(con))) = fieldnames(EoI.(char(participants(i))).(char(all_con(con))));
    MI_name = char(strcat(participants(i),'_MI_data.mat'));
    save (MI_name,'MI_stat','-mat')
    clear Electorodes
    clear MI_stat
   
end
end
filename = strcat('EoI_data_',datatype,'.mat');
save (filename,'EoI','-mat')




