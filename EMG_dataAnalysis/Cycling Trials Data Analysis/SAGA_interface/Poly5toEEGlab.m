%
%	Example of reading a Poly5 file and saving it as .set compatibel with to EEGLAB.
%       EEGLAB is a toolbox which can be downloaded.
%       Please note: TMSi has nothing to do with the development or
%       distribution of EEGlab. This example shows how you can read in
%       Poly5 data and convert it to eeglab.

% Step 1: Open Poly5 file.

function Poly5toEEGlab(fn)

if nargin==0 % no fn was given as input, open dialog instead
    
    [file, pathname] = uigetfile({'*.Poly5';'*.S00';'*.TMS32'},'Pick your file');
     
    [path,filename,extension] = fileparts(file);

    % check if file was selected, if not, stop.
    if isequal(filename,0) || isequal(pathname,0)
       disp('File open dialog was cancelled')
       return
    
    end
    
else
    [pathname,filename,extension] = fileparts(fn); 

end

    %read in data file
 d = TMSiSAGA.Poly5.read([pathname,'/',filename,extension]);
    
    
% Step 2: Plot a single channel.
plot((0:(d.num_samples - 1)) / d.sample_rate, d.samples(2, :));

%  Step 3: Save dataset in the same directory as the *.Poly5 file.
%   NOTE: Ensure eeglab path is correct and is run atleast once before calling this script.)

if exist('eeglab','file')==0
    disp('EEGLAB not found. It is not installed properly or not present on the system. Download EEGlab and install according to instructions')
    return
elseif exist('eeglab','file')==2
    
    % Transform data to eeglab. 
    eegdataset = toEEGLab(d);

    % Save dataset in the same directory as the *.Poly5 file.
    pop_saveset(eegdataset,'filename',filename,'filepath',pathname)
    disp(['Data saved as EEGlab dataset (.set) in this folder: ',pathname])
else
    disp('Something went wrong, eeglab dataset could not be saved.')
    return
end
    




