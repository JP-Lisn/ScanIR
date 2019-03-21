function varargout = createNew(varargin)
% CREATENEW M-file for createNew.fig
%      CREATENEW by itself, creates a new CREATENEW or raises the
%      existing singleton*.
%
%      H = CREATENEW returns the handle to a new CREATENEW or the handle to
%      the existing singleton*.
%
%      CREATENEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATENEW.M with the given input arguments.
%
%      CREATENEW('Property','Value',...) creates a new CREATENEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createNew_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createNew_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createNew

% Last Modified by GUIDE v2.5 20-Mar-2019 17:29:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createNew_OpeningFcn, ...
                   'gui_OutputFcn',  @createNew_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before createNew is made visible.
function createNew_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createNew (see VARARGIN)

% Choose default command line output for createNew
handles.output.out = 'Created a new IR recording session';

handles.inMode = 1;  % starts as mono IR
handles.outMode = 1; % 1 channel output
handles.signalType = 'Sine Sweep'; % sine sweep
handles.sigLength = 1; % 1 second
handles.irLength = 44100; % 1 second IR
handles.sampleRate = 44100; 
handles.numInputChls = 1;
handles.numOutputChls = 1;
handles.numPlays = 1;


% --- Init for Audio Devices --- %
InitializePsychSound;

% -- Check operating system & set tokens
handles = system_tokens(handles);
% populate Audio Device popup menus
handles.allDevices = AudioDeviceNames;
handles.audioDeviceNames = handles.allDevices;
% handle Built-In case
idx_in = find(strcmp(handles.allDevices,handles.built_IP)...
    |strcmp(handles.allDevices,'Built-in Microph'));
if ~isempty(idx_in)
    handles.audioDeviceNames{idx_in} = 'Built-in';
    handles.offsetDevice = idx_in;
end
idx_out = find(strcmp(handles.allDevices,handles.built_OP));
if ~isempty(idx_out)
    handles.audioDeviceNames(idx_out) = [];
end
set(handles.popupmenu_audioDevice, 'String', handles.audioDeviceNames);

% % set Selected Audio Device to the first non-built-in device
% audio_device_tokens;
% 
% for i = 1:length(handles.audioDeviceNames)
%     deviceName = char(handles.audioDeviceNames(i));
%     if (~strcmp(deviceName, BUILT_IN_MICROPHONE))
%         if (~strcmp(deviceName, BUILT_IN_OUTPUT))
%             set(handles.popupmenu_audioDevice, 'Value', i);
%             break;
%         end
%     end
% end

for i = 1:length(handles.audioDeviceNames)
    deviceName = char(handles.audioDeviceNames(i));
    if (strcmp(deviceName, 'Built-in'))
        set(handles.popupmenu_audioDevice, 'Value', i);
        break;
    end
end


% select default audio device and store struct audioDeviceInfo
handles.audioDeviceNameSelected = ...
    handles.audioDeviceNames{get(handles.popupmenu_audioDevice, 'Value')};
if ~strcmp(handles.audioDeviceNameSelected,'Built-in')
    handles.audioDeviceInfo = AudioDeviceInfoByName(...
        handles.audioDeviceNameSelected);
else
    handles.audioDeviceInfo = AudioDeviceInfoByName(handles.built_OP);
    handles.audioDeviceInfo.DeviceIndex = -1;
    handles.audioDeviceInfo.DeviceName = 'Built-in';
    temp_dev = AudioDeviceInfoByName(handles.allDevices{handles.offsetDevice});
    handles.audioDeviceInfo.NrInputChannels = temp_dev.NrInputChannels;
    handles.audioDeviceInfo.LowInputLatency = temp_dev.LowInputLatency;
    handles.audioDeviceInfo.HighInputLatency = temp_dev.HighInputLatency;
end


% find maximum number of output and input channels
handles.maxOuts     = handles.audioDeviceInfo.NrOutputChannels;
handles.maxIns      = handles.audioDeviceInfo.NrInputChannels;

% Update handles structure
guidata(hObject, handles);

% Insert custom Title and Text if specified by the user
% Hint: when choosing keywords, be sure they are not easily confused 
% with existing figure properties.  See the output of set(figure) for
% a list of figure properties.
if(nargin > 3)
    for index = 1:2:(nargin-3)
        if nargin-3==index, break, end
        switch lower(varargin{index})
         case 'title'
          set(hObject, 'Name', varargin{index+1});
         case 'string'
          set(handles.text1, 'String', varargin{index+1});
        end
    end
end

% Determine the position of the dialog - centered on the callback figure
% if available, else, centered on the screen
ref_ss(1) = (400/72);
ref_ss(2) = (530/72);
ScreenUnits=get(0,'Units');
set(0,'Units','pixels');
p_ss=get(0,'ScreenSize');
set(0,'Units','inches');
i_ss=get(0,'ScreenSize');
res_ss = p_ss./i_ss;
set(0,'Units',ScreenUnits);
% Set GUI Dimensions
OldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'pixels');
FigPos = get(hObject,'Position');
Width = max([round(ref_ss(1)*res_ss(3)),round(p_ss(3)*0.25)]);
Height = max([round(ref_ss(2)*res_ss(4)),round(p_ss(4)*0.6)]);
if (Width > p_ss(3)) Width = p_ss(3); end
if (Height > p_ss(4)-100) Height = p_ss(4)-100; end
FigPos(3)= Width;
FigPos(4)= Height;
FigPos(1)= round((p_ss(3)-FigPos(3))/2);
FigPos(2)= round((p_ss(4)-FigPos(4))/2);
set(hObject, 'Position', FigPos);
set(hObject, 'Units', OldUnits);

% Show a question icon from dialogicons.mat - variables questIconData
% and questIconMap
load dialogicons.mat

IconData=questIconData;
questIconMap(256,:) = get(handles.figure1, 'Color');
IconCMap=questIconMap;


set(handles.figure1, 'Colormap', IconCMap);

% Make the GUI modal
set(handles.figure1,'WindowStyle','modal')

% Motor default parameters
try 
    load('src/setup/tempfile.mat');
    if ard
        handles.spr_edit.Enable = 'on';
        handles.rpm_edit.Enable = 'on';
        handles.port_edit.Enable = 'on';
        handles.motor.spr = 200;
        handles.motor.rpm = 10;
        handles.motor.port = 2;
    end
    delete('src/setup/tempfile.mat');
catch
    disp('Failed to load flags')
end
guidata(hObject,handles);

% UIWAIT makes createNew wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = createNew_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% The figure can be deleted now
delete(handles.figure1);

% --- Executes on button press in createButton.
function createButton_Callback(hObject, eventdata, handles)

handles.output.inMode = handles.inMode;
handles.output.signalType = handles.signalType;
handles.output.sigLength = handles.sigLength;
handles.output.irLength = updateIRLength(hObject,handles);
handles.output.sampleRate = handles.sampleRate;
handles.output.numInputChls = handles.numInputChls;
handles.output.numOutputChls = handles.numOutputChls;
handles.output.outMode = handles.outMode;
handles.output.maxOuts = handles.maxOuts;
handles.output.numPlays = handles.numPlays;
handles.output.motor = handles.motor;

% passing values for selected audio device
%   inputStructure and outputStructure are structs returned by
%   PsychPortAudio when called for the selected audio devices.
handles.output.audioDeviceInfo = handles.audioDeviceInfo;


handles.output.sessionName = get(handles.edit_sessionName, 'String');


% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
uiresume(handles.figure1);



% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output.inMode = handles.inMode;
handles.output.signalType = handles.signalType;
handles.output.sigLength = handles.sigLength;
handles.output.irLength = updateIRLength(hObject, handles);
handles.output.sampleRate = handles.sampleRate;
handles.output.numInputChls = handles.numInputChls;
handles.output.numOutputChls = handles.numOutputChls;
handles.output.outMode = handles.outMode;
handles.output.maxOuts = handles.maxOuts;
handles.output.numPlays = handles.numPlays;

% Update handles structure
guidata(hObject, handles);

% Use UIRESUME instead of delete because the OutputFcn needs
% to get the updated handles structure.
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end


% --- Executes on key press over figure1 with no controls selected.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check for "enter" or "escape"
if isequal(get(hObject,'CurrentKey'),'escape')
    % User said no by hitting escape
    handles.output = 'No';
    
    % Update handles structure
    guidata(hObject, handles);
    
    uiresume(handles.figure1);
end    
    
if isequal(get(hObject,'CurrentKey'),'return')
    uiresume(handles.figure1);
end    



function createSigLength_Callback(hObject, eventdata, handles)
% hObject    handle to createSigLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sigLengthEdit = str2double(get(handles.createSigLength, 'String'));
if (sigLengthEdit <= 0 || isnan(sigLengthEdit)) % at least one (non-string) input channel
    disp('Invalid entry; sigLength will default to 1 second');
    handles.sigLength = 1;
    set(handles.createSigLength, 'String', num2str(1));
elseif (sigLengthEdit > 10) % must be <= 10 seconds long
    disp('Maximum sigLength is 10 seconds');
    handles.sigLength = 10;
    set(handles.createSigLength, 'String', num2str(10));
else
    handles.sigLength = sigLengthEdit;
end

sigIndex = get(handles.createSignal, 'Value');
if (sigIndex ~= 1) % extra check when using MLS or Golay Codes
    
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSigLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to createSigLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function createNuminchls_Callback(hObject, eventdata, handles)
inChannelEdit = str2double(get(handles.createNuminchls, 'String'));
if (inChannelEdit < 1 || isnan(inChannelEdit)) % at least one (non-string) input channel
    disp('Invalid entry; numInputChls will default to 1');
    handles.numInputChls = 1;
    set(handles.createNuminchls, 'String', num2str(1));
elseif (inChannelEdit > handles.maxIns) % less than the maximum amount of channels
    handles.numInputChls = handles.maxIns;
    set(handles.createNuminchls, 'String', num2str(handles.maxIns));
elseif (inChannelEdit ~= round(inChannelEdit))
    handles.numInputChls = floor(inChannelEdit);
    set(handles.createNuminchls, 'String', num2str(handles.numInputChls) );
else
    handles.numInputChls = inChannelEdit;
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createNuminchls_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function createIRLength_Callback(hObject, eventdata, handles)


sigIndex = get(handles.createSignal, 'Value');
if (sigIndex ~= 1) % extra check when using MLS or Golay Codes
    irLength = updateIRLength(hObject, handles);
    pow2Len = nextpow2(handles.sigLength * handles.sampleRate + 1);
    handles.sigLength
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createIRLength_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createSrate.
function createSrate_Callback(hObject, eventdata, handles)

srates = [22050 44100 48000 96000];
srate_i = get(handles.createSrate, 'Value');
handles.sampleRate = srates(srate_i);

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSrate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createSignal.
function createSignal_Callback(hObject, eventdata, handles)

sigIndex = get(handles.createSignal, 'Value');
if (sigIndex == 1)
    handles.signalType = 'Sine Sweep';
elseif (sigIndex == 2)
    handles.signalType = 'MLS';
elseif (sigIndex == 3)
    handles.signalType = 'Golay Codes';
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createSignal_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in createMode.
function createMode_Callback(hObject, eventdata, handles)

handles.inMode = get(handles.createMode, 'Value');

if (handles.inMode == 1) % Mono IR
    set(handles.outputModeLabel, 'Enable', 'off');
    set(handles.outputModePopup, 'Enable', 'off');
    set(handles.numInputLabel, 'Enable', 'off');
    set(handles.createNuminchls, 'Enable', 'off');
    handles.numInputChls = 1;
    handles.numOutputChls = 1;
    set(handles.text8, 'Enable', 'on');
    set(handles.text8, 'String', 'seconds');  % measure IR length in seconds for room acoustics
    set(handles.NumOutput_txt, 'Enable', 'off');
    set(handles.NumOutputEdit, 'Enable', 'off');
    set(handles.timeUnitsPopup, 'Enable', 'on');
    handles.timeMode = get(handles.timeUnitsPopup, 'Value');
    if handles.timeMode == 1
        set(handles.text8, 'String', 'samples');
        set(handles.createIRLength, 'Value', 3);
        set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    elseif handles.timeMode == 2
        set(handles.text8, 'String', 'seconds');
        set(handles.createIRLength, 'Value', 1);
        set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
    end
elseif (handles.inMode == 2) % HRIR or BRIR
    set(handles.outputModeLabel, 'Enable', 'on');
    set(handles.outputModePopup, 'Enable', 'on');
    set(handles.numInputLabel, 'Enable', 'off');
    set(handles.createNuminchls, 'Enable', 'off'); 
    handles.numInputChls = 2; % change this to 1 if you want to test HRIR mode on a mono input computer
    set(handles.timeUnitsPopup, 'Enable', 'on');
    set(handles.timeUnitsPopup,'Value',2);
    handles.timeMode = get(handles.timeUnitsPopup, 'Value');
    set(handles.text8, 'Enable', 'on');
    if handles.timeMode == 1
        set(handles.text8, 'String', 'samples');
        set(handles.createIRLength, 'Value', 3);
        set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    elseif handles.timeMode == 2
        set(handles.text8, 'String', 'seconds');
        set(handles.createIRLength, 'Value', 1);
        set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
    end
elseif (handles.inMode == 3) % Multichannel IR
    set(handles.outputModeLabel, 'Enable', 'off');
    set(handles.outputModePopup, 'Enable', 'off');
    set(handles.numInputLabel, 'Enable', 'on');
    set(handles.createNuminchls, 'Enable', 'on');
    handles.numInputChls = str2double(get(handles.createNuminchls, 'String'));
    handles.numOutputChls = 1;
    set(handles.text8, 'Enable', 'on');
    set(handles.timeUnitsPopup, 'Enable', 'on');
    handles.timeMode = get(handles.timeUnitsPopup, 'Value');
    set(handles.text8, 'Enable', 'on');
    if handles.timeMode == 1
        set(handles.text8, 'String', 'samples');
        set(handles.createIRLength, 'Value', 3);
        set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    elseif handles.timeMode == 2
        set(handles.text8, 'String', 'seconds');
        set(handles.createIRLength, 'Value', 1);
        set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
    end
    set(handles.NumOutput_txt, 'Enable', 'off');
    set(handles.NumOutputEdit, 'Enable', 'off');
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function createMode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in outputModePopup.
function outputModePopup_Callback(hObject, eventdata, handles)
handles.outMode = get(handles.outputModePopup, 'Value');

if (handles.outMode == 1)
    handles.numOutputChls = 1;
    set(handles.NumOutput_txt, 'Enable', 'off');
    set(handles.NumOutputEdit, 'Enable', 'off');
elseif (handles.outMode == 2)
    set(handles.NumOutput_txt, 'Enable', 'on');
    set(handles.NumOutputEdit, 'Enable', 'on');
    outEditVal = str2double(get(handles.NumOutputEdit,'String'));
    if (outEditVal <= handles.maxOuts) % makes sure it's not greater than maximum # of outputs
        handles.numOutputChls = outEditVal;
    else
        handles.numOutputChls = handles.maxOuts;
        set(handles.NumOutputEdit, 'String', num2str(handles.maxOuts));
    end
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function outputModePopup_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function NumOutputEdit_Callback(hObject, eventdata, handles)
outEditVal = str2double(get(handles.NumOutputEdit,'String'));
if (outEditVal < 1 || isnan(outEditVal))
    disp('Invalid Entry; numOutputChls defaults to 1.');
    handles.numOutputChls = 1;
    set(handles.NumOutputEdit, 'String', num2str(1));
elseif (outEditVal > handles.maxOuts) % makes sure it's not greater than maximum # of outputs
    handles.numOutputChls = handles.maxOuts;
    set(handles.NumOutputEdit, 'String', num2str(handles.numOutputChls));
elseif (outEditVal ~= round(outEditVal)) % no decimal numbers of channels
    handles.numOutputChls = floor(outEditVal);
    set(handles.NumOutputEdit, 'String', num2str(handles.numOutputChls));
else
    handles.numOutputChls = outEditVal;
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function NumOutputEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function createNumPlays_Callback(hObject, eventdata, handles)
% hObject    handle to createNumPlays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playbackEdit = str2double(get(handles.createNumPlays, 'String'));
if (playbackEdit < 1 || isnan(playbackEdit))
    disp('Invalid Entry; numPlays defaults to 1.');
    handles.numPlays = 1;
    set(handles.createNumPlays, 'String', num2str(1));
elseif (playbackEdit > 5)
    disp('Maximum number of plays is 5');
    handles.numPlays = 5;
    set(handles.createNumPlays, 'String', num2str(5));
elseif (playbackEdit ~= round(playbackEdit))
    handles.numPlays = floor(playbackEdit);
    set(handles.createNumPlays, 'String', num2str(handles.numPlays));
else
    handles.numPlays = playbackEdit;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function createNumPlays_CreateFcn(hObject, eventdata, handles)
% hObject    handle to createNumPlays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in timeUnitsPopup.
function timeUnitsPopup_Callback(hObject, eventdata, handles)
% hObject    handle to timeUnitsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.timeMode = get(handles.timeUnitsPopup, 'Value');
if (handles.timeMode == 1)
    set(handles.createIRLength, 'Value', 3);
    set(handles.createIRLength, 'String', '128|256|512|1024|2048|4096|8192');
    set(handles.text8, 'String', 'samples'); % measure HRIR length in samples
elseif (handles.timeMode == 2)
    set(handles.createIRLength, 'Value', 1);
    set(handles.createIRLength, 'String', '1|2|3|4|5|6|7|8|9');
    set(handles.text8, 'String', 'seconds'); % measure HRIR length in samples
end

% --- Executes during object creation, after setting all properties.
function timeUnitsPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeUnitsPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function newIRLength = updateIRLength(hObject, handles)
length_i = get(handles.createIRLength, 'Value');
timeUnits = 1:9;
sampleUnits = [128,256,512,1024,2048,4096,8192];
handles.timeMode = get(handles.timeUnitsPopup,'Value');
if handles.timeMode == 2 % Seconds
    newIRLength = timeUnits(length_i) * handles.sampleRate;
elseif handles.timeMode == 1 % Samples
    newIRLength = sampleUnits(length_i);
end

guidata(hObject, handles);


% --- Executes on selection change in popupmenu_audioDevice.
function popupmenu_audioDevice_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_audioDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_audioDevice contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_audioDevice

contents = cellstr(get(hObject, 'String'));
handles.audioDeviceSelected = contents{get(hObject, ...
                                            'Value')};
if strcmp(handles.audioDeviceSelected,'Built-in')                                        
    handles.audioDeviceInfo = AudioDeviceInfoByName(handles.built_OP);
    handles.audioDeviceInfo.DeviceIndex = -1;
    handles.audioDeviceInfo.DeviceName = 'Built-in';
    temp_dev = AudioDeviceInfoByName(handles.allDevices{handles.offsetDevice}); 
    handles.audioDeviceInfo.NrInputChannels = temp_dev.NrInputChannels;
    handles.audioDeviceInfo.LowInputLatency = temp_dev.LowInputLatency;
    handles.audioDeviceInfo.HighInputLatency = temp_dev.HighInputLatency;
    handles.maxIns = temp_dev.NrInputChannels;
else
    handles.audioDeviceInfo = AudioDeviceInfoByName(...
                                        handles.audioDeviceSelected);
    handles.maxIns = handles.audioDeviceInfo.NrInputChannels;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_audioDevice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_audioDevice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_sessionName_Callback(hObject, eventdata, handles)
% hObject    handle to edit_sessionName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_sessionName as text
%        str2double(get(hObject,'String')) returns contents of edit_sessionName as a double


% --- Executes during object creation, after setting all properties.
function edit_sessionName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_sessionName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
default_name_string = "New Session " + datestr(datetime('now'));
set(hObject, 'String', default_name_string);
handles.sessionName     = get(hObject, 'String');



function spr_edit_Callback(hObject, eventdata, handles)
% hObject    handle to spr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spr_edit as text
%        str2double(get(hObject,'String')) returns contents of spr_edit as a double
value = str2double(get(handles.spr_edit,'String'));
if value < 1 || isnan(value)
    warning(['Invalid entry, please enter a number bigger than 1 for the ',...
        'steps per revolution value']);
    set(handles.spr_edit,'String',num2str(handles.motor.spr));
else
    handles.motor.spr = value;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function spr_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spr_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rpm_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rpm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rpm_edit as text
%        str2double(get(hObject,'String')) returns contents of rpm_edit as a double
value = str2double(get(handles.rpm_edit,'String'));
if value < 1 || isnan(value)
    warning(['Invalid entry, please enter a number bigger than 1 for the ',...
        'revolutions per minute value']);
    set(handles.rpm_edit,'String',num2str(handles.motor.rpm));
else
    handles.motor.rpm = value;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function rpm_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rpm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function port_edit_Callback(hObject, eventdata, handles)
% hObject    handle to port_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of port_edit as text
%        str2double(get(hObject,'String')) returns contents of port_edit as a double
value = str2double(get(handles.port_edit,'String'));
if value<1 || value >2 || isnan(value)
    warning(['Invalid entry, please enter a number between 1 and 2 for',...
        'the Adafruit v2 connection port']);
    set(handles.port_edit,'String',num2str(handles.motor.port));
else
    handles.motor.port = value;
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function port_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to port_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end