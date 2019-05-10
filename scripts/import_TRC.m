clc
clear
inDir='/Users/matteo/Desktop/2018_2019/Ricerca/PaniS/Pani_EEG/patients/';
fil_sbj='pat*';
fil_raw='*.TRC';
sbjs=dir(fullfile(inDir,fil_sbj));
for i=1:length(sbjs)
    raws=dir(fullfile(strcat(inDir,sbjs(i).name),fil_raw));
    for j=1:length(raws)
        FileName=strcat(fullfile(strcat(inDir,sbjs(i).name)),'/',raws(j).name)
        dat=readTRC(FileName);
        [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
        PARAM.filename=FileName;
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

% 
%         for k=1:length(dat.annotations)
%             if(strcmp(dat.annotations{k,2},'Eyes Closed'))
%                 in=dat.annotations{k,1};
%                 if(strcmp(dat.annotations{k+1,2},'Fixation'))
%                     en=dat.annotations{k+1,1};
%                 end
%                 break;
%             end
%         end
        
%         for k=1:length(dat.annotations)
%             if(strcmp(dat.annotations{k,2},'Eyes Opened'))
%                 in=dat.annotations{k,1};
%                 if(strcmp(dat.annotations{k+1,2},'Fixation'))
%                     en=dat.annotations{k+1,1};
%                 end
%                 break;
%             end
%         end
        
        for k=1:length(dat.annotations)
            if(strcmp(dat.annotations{k,2},'Math2'))
                in=dat.annotations{k,1};
                if(strcmp(dat.annotations{k+1,2},'Fixation'))
                    en=dat.annotations{k+1,1};
                else en=dat.annotations{k+2,1};
                end
                break;
            end
        end
        
        EEG.data=EEG.data(1:61,in:en);
        EEG.nbchan=61;        
        EEG.times=EEG.times(1:en-in+1);
        EEG.xmax=EEG.times(end);
        EEG.pnts=size(EEG.data,2);
        EEG=pop_chanedit(EEG, 'load',{'/Users/matteo/Google Drive/chan_locs/chan61.loc' 'filetype' 'autodetect'});
        EEG = pop_eegfiltnew(EEG, 1, 40, [], 0, [], 0);
%         EEG = pop_runica(EEG, 'extended',1,'interupt','on');
%         EEG=interface_ADJ(EEG,'report');
%         load('List_EDF file.mat');
%         art = nonzeros( union (union(blink,horiz) , union(vert,disc)) )';
%         EEG = pop_subcomp( EEG, art, 0);
        EEG = pop_reref( EEG, []);
        FileSaved=strcat(strtok(FileName,'.'),'_MA02.edf');
        pop_writeeeg(EEG, FileSaved, 'TYPE','EDF');
        
        %save(FileSaved,'data_ec');
%         
%         for k=1:length(dat.annotations)
%             if(strcmp(dat.annotations{k,2},'Eyes Opened'))
%                 in=dat.annotations{k,1};
%                 if(strcmp(dat.annotations{k+1,2},'Fixation'))
%                     en=dat.annotations{k+1,1};
%                 end
%                 break;
%             end            
%         end
%         data_eo=dat;
%         data_eo.sig=data_eo.sig(:,in:en);
%         data_eo.time.time_sig=data_eo.time.time_sig(in:en);
%         data_eo.time.time_sig_sec=data_eo.time.time_sig_sec(in:en);
%         FileSaved=strcat(strtok(FileName,'.'),'_EO_mat');
%         save(FileSaved,'data_eo');

%         for k=1:length(dat.annotations)
%             if(strcmp(dat.annotations{k,2},'Math1'))
%                 in=dat.annotations{k,1};
%                 if(strcmp(dat.annotations{k+1,2},'Fixation'))
%                     en=dat.annotations{k+1,1};
%                 else en=dat.annotations{k+2,1};
%                 end
%                 break;
%             end            
%         end
%         data_ma01=dat;
%         data_ma01.sig=data_ma01.sig(:,in:en);
%         data_ma01.time.time_sig=data_ma01.time.time_sig(in:en);
%         data_ma01.time.time_sig_sec=data_ma01.time.time_sig_sec(in:en);
%         FileSaved=strcat(strtok(FileName,'.'),'_MA01_mat');
%         save(FileSaved,'data_ma01');

%         for k=1:length(dat.annotations)
%             if(strcmp(dat.annotations{k,2},'Math2'))
%                 in=dat.annotations{k,1};
%                 if(strcmp(dat.annotations{k+1,2},'Fixation'))
%                     en=dat.annotations{k+1,1};
%                 else en=dat.annotations{k+2,1};
%                 end
%                 break;
%             end            
%         end
%         data_ma02=dat;
%         data_ma02.sig=data_ma02.sig(:,in:en);
%         data_ma02.time.time_sig=data_ma02.time.time_sig(in:en);
%         data_ma02.time.time_sig_sec=data_ma02.time.time_sig_sec(in:en);
%         FileSaved=strcat(strtok(FileName,'.'),'_MA02_mat');
%         save(FileSaved,'data_ma02');
    end   
end

