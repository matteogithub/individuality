clc
clear
fs=1024;
ep_l=fs*10;
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/';
fil_sbj='pat*';
fil_raw='*.mat';
sbjs=dir(fullfile(inDir,fil_sbj));
for i=1:length(sbjs)
    raws=dir(fullfile(strcat(inDir,sbjs(i).name),fil_raw));
    for j=1:length(raws)
        ToLoad=strcat(fullfile(strcat(inDir,sbjs(i).name)),'/',raws(j).name);
        load(ToLoad,'Value');
        n_eps=floor(size(Value,2)/ep_l);
        out=zeros(n_eps,1);
        for k=1:n_eps
            epf=k*ep_l;
            epi=epf-ep_l+1;
            data=Value(:,epi:epf);
            ou=0;
            for w=1:size(data,1)
                TF=isoutlier(data(w,:),'mean');
                ou=ou+sum(TF);
            end
            out(k,1)=ou;
        end
        [ord,ind]=sort(out);
        %save best 10 epochs
        
        
    end    
end