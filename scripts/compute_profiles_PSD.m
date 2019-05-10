clc
clear
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/to_analyse/';
fil_raw='*.mat';
fs=1024;

raws=dir(fullfile(inDir,fil_raw));
ind=logical(tril(ones(68,68),-1));
profiles=zeros(length(raws)*10,4*68);
k=0;
for j=1:length(raws)
    j
    ToLoad=fullfile(strcat(inDir,raws(j).name));
    load(ToLoad);
    for i=1:size(new_data,1)
        m=squeeze(new_data(i,:,:));        
        [Pxx,F] = pwelch(m',[],[],[],fs);
        totalP=sum(Pxx(1:81,:));
        deltaP=sum(Pxx(1:8,:))./totalP;
        thetaP=sum(Pxx(9:16,:))./totalP;
        alphaP=sum(Pxx(17:27,:))./totalP;
        betaP=sum(Pxx(28:61,:))./totalP;
        k=k+1;
        profile=[deltaP thetaP alphaP betaP];
        profiles(k,:)=profile;
    end
end