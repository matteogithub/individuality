clc
clear
fs=1024;
ep_l=fs*5;
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/';
outDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/to_analyse/';
fil_sbj='pat*';
fil_raw='*.mat';
sbjs=dir(fullfile(inDir,fil_sbj));
for i=1:length(sbjs)
    i
    raws=dir(fullfile(strcat(inDir,sbjs(i).name),fil_raw));
    for j=1:length(raws)
        ToLoad=strcat(fullfile(strcat(inDir,sbjs(i).name)),'/',raws(j).name);
        load(ToLoad,'Value');
        n_eps=floor(size(Value,2)/ep_l);
        %ToLoad
%         if(n_eps<10) 
%             disp(ToLoad);
%             n_eps
%         end
        out=zeros(n_eps,1);
        data=zeros(n_eps,68,ep_l);
        new_data=zeros(10,68,ep_l);
        for k=1:n_eps
            epf=k*ep_l;
            epi=epf-ep_l+1;
            data(k,:,:)=Value(:,epi:epf);
            ou=0;
            for w=1:size(data,2)
                TF=isoutlier(squeeze(data(k,w,:)),'mean');
                ou=ou+sum(TF);
            end
            out(k,1)=ou;
        end
        [ord,ind]=sort(out);
        %select best 10 epochs
        for x=1:10
            new_data(x,:,:)=data(ind(x),:,:);            
        end
        S=extractAfter(strtok(raws(j).name,'.'),'EEG');
        ToSave=strcat(outDir,sbjs(i).name,S);
        %save to disk
        save(ToSave,'new_data');
    end    
end