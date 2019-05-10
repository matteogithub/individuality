clc
clear
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/to_analyse/beta/';
fil_raw='*.mat';

raws=dir(fullfile(inDir,fil_raw));
ind=logical(tril(ones(68,68),-1));
profiles=zeros(length(raws)*10,68*67/2);
k=0;
for j=1:length(raws)
    j
    ToLoad=fullfile(strcat(inDir,raws(j).name));
    load(ToLoad);
    for i=1:size(filt_data,1)
        m=squeeze(filt_data(i,:,:));
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  test other metrics: PSD-PLI  %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        
        profile=PLV(m');
        %profile=Phase_lag_index(m');
        profile=profile(ind);
        k=k+1;
        profiles(k,:)=profile;
    end
end