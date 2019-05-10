FileName='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/pat_11/EEG_14.TRC';

dat=readTRC(FileName);

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
PARAM.filename='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/pat_11/EEG_14.TRC'; 
PARAM.loadevents.state='no'; 
PARAM.loadevents.type='none'; 
PARAM.loadevents.dig_ch1=''; 
PARAM.loadevents.dig_ch1_label=''; 
PARAM.loadevents.dig_ch2=''; 
PARAM.loadevents.dig_ch2_label=''; 
PARAM.chan_adjust_status=0; 
PARAM.chan_adjust=''; 
PARAM.chans=''; 
[EEG,command]=pop_readtrc(PARAM);
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'gui','off');


