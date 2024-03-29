%% PLOTS COI/MI WITH PERMUTATION TESTING FOR SPECIFIED PARTICIPANT AND CONDITION
%...in the way we want to have it in the papers :)

%% GETS ALL THE PARAMETERS FOR PARTICIPANT AND DATA

%PARTICIPANT PARAMETERS (CHANGE IN THE Get_param-function)
[basefold, datatype, participantnum, ~, condition, participants, ~, re_epoch, dev_epochs, std_epochs, epoch_length, srate, low_cutoff, high_cutoff, filt_order, ~, start_cut_off, end_cut_off, kperm] = Get_param(0);

%PLOTTING PARAMETERS!
cutoff = [16, 26];
xlimits = [700 1150];
ylimits_CoI = [700 1150];
ylimit_MI = [0 0.06];
xticks_CoI = 800:150:1100;
yticks_CoI = 800:150:1100;
yticks_MI = [0 0.025 0.05 0.075 0.1];
x_labels = 0:150:300;
y_labels_CoI = 0:150:300;
y_labels_MI = [0 0.025 0.05 0.075 0.1];
climits = [-0.01 0.01];
climits_mask = [0 1];

%% LOAD DATA

%import data to get timing vector
[iEEG1, ~] = impiEEG(participantnum, basefold, datatype, condition, srate, low_cutoff, high_cutoff, filt_order, re_epoch, dev_epochs, std_epochs, epoch_length);

%get proper timing (i.e., the period were interested)
iEEG1.times (start_cut_off) = [];
iEEG1.times (end_cut_off:end) = [];
timing = iEEG1.times;

%Get data in correct format
[tempFFiall, tempFFi, temp_all_mask, tempFFm, tempFFmr, tempFFms,tempFFmi1, tempFFmi2,tempFFir,tempFFis, temp_nb, front_nb, tempfront_nb, tempint_nb, frontint_nb, ...
          frontFFiall, frontFFi, front_all_mask, frontFFm, frontFFmr, frontFFms, frontFFmi1, frontFFmi2, frontFFir, frontFFis,...
          tempfrontFFiall, tempfrontFFi, tempfrontFFm, tempfrontFFmr, tempfrontFFms, tempfrontFFmi1, tempfrontFFmi2, tempfrontFFir, tempfrontFFis,...
          tempintFFiall, tempintFFi, tempintFFm, tempintFFmr, tempintFFms, tempintFFmi1, tempintFFmi2, tempintFFir, tempintFFis,...
          frontintFFiall, frontintFFi, frontintFFm, frontintFFmr, frontintFFms, frontintFFmi1, frontintFFmi2, frontintFFir, frontintFFis] = get_plotting_CoI(basefold,datatype, participantnum, char(participants(participantnum)), condition, cutoff, iEEG1.times);

%% % PLOT Averages of all electrodes ( temporal/frontal/fronto-temporal/temporo-temporal/fronto-frontal)
% % 
% %Plot temporal figures
% [temp_figure] = plot_temporal(basefold,participants(participantnum), condition, tempFFi, tempFFm, tempFFmr, tempFFms, tempFFmi1, tempFFmi2, tempFFir, tempFFis, temp_nb, timing,...
%     xlimits,ylimits_CoI,ylimit_MI,xticks_CoI,yticks_CoI,yticks_MI,x_labels,y_labels_CoI, y_labels_MI,climits,climits_mask);
% 
% %Plot frontal figures
% [front_figure] = plot_frontal(basefold,participants(participantnum), condition, frontFFi, frontFFm, frontFFmr, frontFFms, frontFFmi1, frontFFmi2, frontFFir, frontFFis, front_nb, timing,...
%     xlimits,ylimits_CoI,ylimit_MI,xticks_CoI,yticks_CoI,yticks_MI,x_labels,y_labels_CoI, y_labels_MI,climits,climits_mask);
% 
% Plot temporo-frontal figures
% [tempo_front_figure] = plot_tempo_frontal(basefold,participants(participantnum), condition, tempfrontFFi, tempfrontFFm, tempfrontFFmr, tempfrontFFms, tempfrontFFmi1, tempfrontFFmi2, tempfrontFFir, tempfrontFFis, tempfront_nb, timing,...
%     xlimits,ylimits_CoI,ylimit_MI,xticks_CoI,yticks_CoI,yticks_MI,x_labels,y_labels_CoI, y_labels_MI,climits,climits_mask);
% 
% % Plot temporo-temporal figures
% [temporo_temporal_figure] = plot_tempo_temporal(basefold,participants(participantnum), condition, tempintFFi, tempintFFm, tempintFFmr, tempintFFms, tempintFFmi1, tempintFFmi2, tempintFFir, tempintFFis, tempint_nb, timing,...
%     xlimits,ylimits_CoI,ylimit_MI,xticks_CoI,yticks_CoI,yticks_MI,x_labels,y_labels_CoI, y_labels_MI,climits,climits_mask);
% 
% % Plot temporo-temporal figures
% [frontal_frontal_figure] = plot_fronto_frontal(basefold,participants(participantnum), condition, frontintFFi, frontintFFm, frontintFFmr, frontintFFms, frontintFFmi1, frontintFFmi2, frontintFFir, frontintFFis, frontint_nb, timing,...
%     xlimits,ylimits_CoI,ylimit_MI,xticks_CoI,yticks_CoI,yticks_MI,x_labels, y_labels_CoI, y_labels_MI,climits, climits_mask);


%% Plot the electrodes with the highest MI
% find the electrodes with the highest MI for all participants and load data into struct
for participanti = 1:length(participants)
[Highest] = Get_highest_MI(basefold,datatype,condition, participanti, char(participants(participanti)), cutoff, timing);
HighAF.(char(participants(participanti))) = Highest;

[tempFFiall, tempFFi, temp_all_mask, tempFFm, tempFFmr, tempFFms,tempFFmi1, tempFFmi2,tempFFir,tempFFis, temp_nb, front_nb, tempfront_nb, tempint_nb, frontint_nb, ...
          frontFFiall, frontFFi, front_all_mask, frontFFm, frontFFmr, frontFFms, frontFFmi1, frontFFmi2, frontFFir, frontFFis,...
          tempfrontFFiall, tempfrontFFi, tempfrontFFm, tempfrontFFmr, tempfrontFFms, tempfrontFFmi1, tempfrontFFmi2, tempfrontFFir, tempfrontFFis,...
          tempintFFiall, tempintFFi, tempintFFm, tempintFFmr, tempintFFms, tempintFFmi1, tempintFFmi2, tempintFFir, tempintFFis,...
          frontintFFiall, frontintFFi, frontintFFm, frontintFFmr, frontintFFms, frontintFFmi1, frontintFFmi2, frontintFFir, frontintFFis] = get_plotting_CoI(basefold,datatype, participantnum, char(participants(participantnum)), condition, cutoff, iEEG1.times);

Temporo_front.(char(participants(participanti))).data = tempfrontFFi;
Temporo_front.(char(participants(participanti))).sigMask = tempfrontFFm;
Temporo_front.(char(participants(participanti))).sigMaskR = tempfrontFFmr;
Temporo_front.(char(participants(participanti))).sigMaskS = tempfrontFFms;
Temporo_front.(char(participants(participanti))).MI1 = tempfrontFFmi1;
Temporo_front.(char(participants(participanti))).MI2 = tempfrontFFmi2;
Temporo_front.(char(participants(participanti))).nbchan = tempfront_nb;
end

%Plot highest temporal electrodes for all participants (+ individual plots)
% [temp_high_fig, front_high_fig]  = plot_highest(basefold, participants(participantnum), participants, condition, HighAF, timing, xlimits, ylimits_CoI, ylimit_MI, xticks_CoI, yticks_CoI, yticks_MI, x_labels, y_labels_CoI, y_labels_MI, climits, climits_mask);
[temp_front_fig]  = plot_average_temporo_frontal(basefold, participants(participantnum), participants, condition, Temporo_front, timing, xlimits, ylimits_CoI, ylimit_MI, xticks_CoI, yticks_CoI, yticks_MI, x_labels, y_labels_CoI, y_labels_MI, climits, climits_mask);

%THE END














