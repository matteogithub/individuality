% Reads TRC data
% More variables can be extracted; see W:\Projects\Micromed\EEG_File_Structure_Type_4 for more info
% 
% Usage:
% dat = readTRC(FileName,sig_range,ch)
% or 
% dat = readTRC(FileName,sig_range)
% 
% -----IN------
% FileName      TRC file name (use with .trc extension)
% sig_range     EEG sample range to read [start end]
% chan          (optional) row vector with channel selection [1,3,5:8]
% 
% -----OUT-----
% dat           struct with read TRC information, with:
% 	fs          sampling frequency (int if same for all electrodes, otherwise
%               vector with fs for each channel)
%   rec_start   recording start time
%   file_length length of EEG file (samples)
%   reductions  EEG reduction samples, original sample (1st column), and new
%               sample (2nd column)
%   ch          channel names
%   sig         measured signals
%   time        struct with time vectors in real datetime and seconds from
%               start of record
%   annot       annotations with accompanying time in samples (for given
%               signal range!)
%   vid_info    struct with info on linked (to the EEG) video files. With:
%               VidFileName - filename of video
%               StartSampInEEG - EEG sample marking video start time
%               VidFileLength - Length of video file in milliseconds
%   trigger     array of triggers (trigger position in sample,trigger value)
%   patname     respect Name for the patient
% version: Evelien 20180108
% version: Matteo 20180312
% - added triggers
% - respect numberpat

function dat = readTRC(FileName,varargin)

if nargin == 1
    sig_range = [];
    chan = [];
elseif nargin == 2
    sig_range = varargin{1};
    chan = [];
elseif nargin == 3
    sig_range = varargin{1};
    chan = varargin{2};
end

f = fopen(FileName);

% check if range is provided correctly
if length(sig_range)==1
    error('Provide range in [start end] format');
end
% Check header type
fseek(f,175,-1);
if fread(f,1,'char')~=4
    warning('Warning: Possibly incompatible header type, this script was developed to read Micromed �System98� Header Type');
end

% ----------RECORD START TIME----------------------------------------------
fseek(f,128,-1);
day = fread(f,3,'char');
starttime = fread(f,3,'char'); 
rec_start = datetime(day(3)+1900,day(2),day(1),starttime(1),starttime(2),starttime(3));

% ----------ELECTRODE (CHANNEL) INFORMATION--------------------------------
% number of stored channels
fseek(f,142,-1);
num_chan = fread(f,1,'uint16');

fseek(f,176+8,-1);
order_offset = fread(f,1,'uint32');
% order_length = fread(f,1,'uint32');
fseek(f,order_offset,-1);
order = fread(f,num_chan,'uint16');
fseek(f,192+8,-1);
electrode_offset = fread(f,1,'uint32');

for i=1:length(order)
    fseek(f,electrode_offset+order(i)*128+2,-1);
    ch{i,1} = char(fread(f,6,'char'))';
    fseek(f,electrode_offset+order(i)*128+44,-1);
    fs_ch(i,1) = fread(f,1,'uint16');
    fseek(f,electrode_offset+order(i)*128+14,-1);
    logic_min(i,1) = fread(f,1,'int32');
    logic_max(i,1) = fread(f,1,'int32');
    logic_ground(i,1) = fread(f,1,'int32');
    phys_min(i,1) = fread(f,1,'int32');
    phys_max(i,1) = fread(f,1,'int32');
end

% ----------SAMPLING FREQUENCY---------------------------------------------
% may differ per channel. If not --> fs_ch is integer
fseek(f,146,-1);
fs_min = fread(f,1,'uint16');
fs_ch = fs_ch*fs_min;
if all(fs_ch == fs_ch(1))
    fs_ch = fs_ch(1);
end

% ----------RETRIEVE SIGNALS-----------------------------------------------
% offset address of data
fseek(f,138,-1);
data_offset = fread(f,1,'uint32');

fseek(f,148,-1);
bytes = fread(f,1,'uint16');
if bytes==1
    Nbytes = 'uint8';      % uint8
else
    Nbytes = 'uint16';      % uint16
end

fseek(f,144,-1);
multiplexer = fread(f,1,'uint16');  % sample to sample spacing

filesize = dir(FileName);
filesize = filesize.bytes;
file_length = (filesize-data_offset)/multiplexer;

if ~isempty(sig_range)
    num_samp = sig_range(2)-sig_range(1)+1;     % number of samples in range
else 
    num_samp = file_length;
    sig_range = [1 file_length];
end
    
if isempty(chan)
    fseek(f,data_offset+(sig_range(1)-1)*multiplexer,-1);   % start for first sample in range
    if length(fs_ch)==1
        j = 1;
        sig = zeros(num_chan,num_samp);
        while j<num_samp+1
            % sig = fscanf(f,Nbytes,inf);
            sig(1:num_chan,j) = fread(f,num_chan,Nbytes);
            j=j+1;
        end
    else        % deal with varying sampling frequencies
        warning('Warning: sampling frequency varies between electrodes');
    end

    for i=1:num_chan
        sig(i,:) = ((sig(i,:)-logic_ground(i))/(logic_max(i)-logic_min(i)))*(phys_max(i)-phys_min(i));
    end
else
    mask = false(length(ch),1);
    for i=1:length(chan)
        mask(chan(i))=true;
    end
    
    sig = zeros(length(chan),num_samp);
    fseek(f,data_offset+(sig_range(1)-1)*multiplexer,-1);   % start for first sample in range
    if length(fs_ch)==1
        j = 1;  
        while j<num_samp+1
            SampAllCh = fread(f,num_chan,Nbytes);           % read sample
            sig(:,j) = SampAllCh(mask);
            j=j+1;
        end
    else        % deal with varying sampling frequencies
        warning('Warning: sampling frequency varies between electrodes');
    end
    
    count = 1;
    for c=chan
        sig(count,:) = ((sig(count,:)-logic_ground(c))/(logic_max(c)-logic_min(c)))*(phys_max(c)-phys_min(c));
        count = count+1;
    end
end
    
t_sig_sec = sig_range(1)/fs_ch-1/fs_ch:1/fs_ch:sig_range(2)/fs_ch-1/fs_ch;
t_sig = rec_start+seconds(t_sig_sec);

% ----------REDUCTIONS-----------------------------------------------------
fseek(f,240+8,-1);
reduction_offset = fread(f,1,'uint32');
reduction_length = fread(f,1,'uint32');

reductions = [];
i=1;
fseek(f,reduction_offset,-1);
while 1
    realsamp = fread(f,1,'uint32');
    if realsamp==0
        break
    end
    newsamp = fread(f,1,'uint32');
    reductions(i,1) = realsamp;
    reductions(i,2) = newsamp;
    i=i+1;
end

% ----------ANNOTATIONS----------------------------------------------------
fseek(f,208+8,-1);
note_offset = fread(f,1,'uint32');

i=1;
annotations = cell(1,2);
fseek(f,note_offset,-1);
while 1
    notesamp = fread(f,1,'uint32');
    if notesamp==0
        break
    end
    note = cellstr(char(fread(f,40,'char'))');
    annotations(i,1) = {notesamp};
    annotations(i,2) = {note{1}};
    i=i+1;
end

if ~isempty(annotations{1,1})
    if ~isempty(sig_range)
        mask2 = cell2mat(annotations(:,1))>=sig_range(1) & cell2mat(annotations(:,1))<sig_range(2);
        annotations = annotations(mask2,:);
        %annotations(:,1) = mat2cell(cell2mat(annotations(:,1))-sig_range(1),ones(size(annotations,1),1));
    end
end

% ----------VID-EEG SYNCHRONISATION INFO-----------------------------------
% pointers to area video files
fseek(f,352+8,-1);
DvideoArea_offset = fread(f,1,'uint32');
% DvideoArea_length = fread(f,1,'uint32');

fseek(f,DvideoArea_offset,-1);
for i=1:1024%4*16            % max 16 vid files
    v(i) = fread(f,1,'long');
end

vid_info = struct;
vid_info(1).VidFileName=[];
vid_info(1).StartSampInEEG=[];
vid_info(1).VidFileLength=[];
i=1; p=1;
while (i<=16 && v(p+1)>0)
    vid_info(i).StartSampInEEG = round(v(p)/1000*256);
    p=p+1;
    vid_info(i).VidFileLength = v(p);
    p=p+1;
    vid_info(i).VidFileName = ['VID_',num2str(v(p)),'.AVI'];
    p=p+2;
    i=i+1;
end




%---------------- Read TRIGGERS----------

fseek(f,400+8,-1);
Trigger_Area=fread(f,1,'uint32');
Trigger_Area_Length=fread(f,1,'uint32');
trigDesSize=6;%trigger sample(long int)+(short int) 
fseek(f,Trigger_Area,-1);
for l=1:Trigger_Area_Length/trigDesSize % number of trigger descriptors 
    trigger(1,l)=fread(f,1,'uint32'); %trigger sample(long int)
    trigger(2,l)=fread(f,1,'uint16'); %trigger value (short int) 
end

first_trigger=trigger(1,1);
tl=length(trigger);
NoTrig=0;
for tr=1:tl
    if ((trigger(1,tr) <= num_samp) & (trigger(1,tr) >= first_trigger))
        NoTrig=NoTrig+1;
    end
end

if NoTrig > 0
   	trigger=trigger(:,1:NoTrig);
else
	trigger=[];
	first_trigger=[];
end


% ----------Read PATIENT RESPECT CODE-----------------------------------------

fseek(f,64,-1);
patName=char(fread(f,22,'char'));


% ----------PUT ALL DATA IN STRUCT-----------------------------------------
dat = struct;
dat.patName=patName;
dat.fs = fs_ch;
dat.rec_start = rec_start;
dat.file_length = file_length;
dat.reductions = reductions;
dat.ch = ch;
dat.sig = sig;
dat.time = struct;
dat.time.time_sig = t_sig;
dat.time.time_sig_sec = t_sig_sec;
dat.annotations = annotations;
dat.vid_info = vid_info;
dat.trigger=trigger;
fclose(f);

end
