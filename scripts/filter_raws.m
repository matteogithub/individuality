%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% band-pass filter the raw data %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
addpath '/Users/matteo/Downloads/eeglab_last/'
fs=1024;
lf=13;
hf=30;
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/to_analyse/';
outDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/to_analyse/beta/';
fil_raw='*.mat';
raws=dir(fullfile(inDir,fil_raw));

for j=1:length(raws)    
    j
    ToLoad=fullfile(strcat(inDir,raws(j).name));
    load(ToLoad);
    filt_data=zeros(size(new_data,1),size(new_data,2),size(new_data,3));
    for i=1:size(new_data,1)
        m=squeeze(new_data(i,:,:));  
        filt_data(i,:,:)=eegfilt(m,fs,lf,hf,0,[],0,'fir1',0);
    end
    ToSave=strcat(outDir,raws(j).name);    
    save(ToSave,'filt_data');
end