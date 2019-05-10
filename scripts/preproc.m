clc
clear
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/';
fil_sbj='pat*';
fil_raw='*.mat';
srate=1024;
lf=1;
hf=40;
sbjs=dir(fullfile(inDir,fil_sbj));
for i=1:length(sbjs)
    raws=dir(fullfile(strcat(inDir,sbjs(i).name),fil_raw));
    for j=1:length(raws)
        FileName=strcat(fullfile(strcat(inDir,sbjs(i).name)),'/',raws(j).name)
        my_data=load(FileName);
        StrName=fieldnames(my_data);
        EEG=my_data.(StrName{1});%.sig(1:61,:);
        EEG.data=EEG.sig;
        EEG.nbchan=64;
        EEG.srate=EEG.fs;
        EEG.times=EEG.time.time_sig; %or EEG.time.time_sig_sec
        EEG.setname=FileName;
        EEG.icawinv=[];
        EEG.icaweights=[];
        EEG.icasphere=[];
        EEG.icachansind=[];
        EEG.icaact=[];
        EEG.pnts=size(EEG.data,2);
        EEG.trials=1;
        EEG.xmax=size(EEG.data,2)/EEG.srate;
        EEG.xmin=0;
        EEG.etc=[];
        EEG.chanlocs=EEG.ch;
        EEG=pop_select(EEG,'nochannel',{'ECG+  '},{'ECG-  '} ,{'el064  '} );
        %filt_EEG=eegfilt(EEG,srate,lf,hf,0,[],0,'fir1',0);
        EEG = pop_runica(EEG, 'extended',1,'interupt','on');
        %ADD ADJUST
        %ADD REREFERENCE
    end   
end