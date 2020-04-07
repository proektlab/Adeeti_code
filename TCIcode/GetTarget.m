function varargout = GetTarget(varargin)
% GETTARGET MATLAB code for GetTarget.fig
%      GETTARGET, by itself, creates a new GETTARGET or raises the existing
%      singleton*.
%
%      H = GETTARGET returns the handle to a new GETTARGET or the handle to
%      the existing singleton*.
%
%      GETTARGET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GETTARGET.M with the given input arguments.
%
%      GETTARGET('Property','Value',...) creates a new GETTARGET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GetTarget_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GetTarget_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetTarget

% Last Modified by GUIDE v2.5 01-Jul-2016 06:43:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GetTarget_OpeningFcn, ...
                   'gui_OutputFcn',  @GetTarget_OutputFcn, ...
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

                    % initialize the target rate at zero


% --- Executes just before GetTarget is made visible.
function GetTarget_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GetTarget (see VARARGIN)

% Choose default command line output for GetTarget
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GetTarget wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Start the target concentration at zero initially
target=0;       
save('Target.mat', 'target');
set(handles.CurrentRate, 'String', '0');

% --- Outputs from this function are returned to the command line.
function varargout = GetTarget_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
target=str2num(get(handles.TargetInput, 'String'));

if isempty(target)
    set(handles.Errors, 'String', 'Target must be a number');
elseif target<0
    set(handles.Errors, 'String', 'Target must be non-negative');
else                                                                    % if input is a non-negative number, then displays it on the screen and saves the value into Target.mat. This is where the main function gets the current target. 
    set(handles.Errors, 'String', ' ');
    set(handles.CurrentRate, 'String', num2str(target));
    save('Target.mat', 'target');
end
guidata(hObject, handles);



function TargetInput_Callback(hObject, eventdata, handles)
% hObject    handle to TargetInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TargetInput as text
%        str2double(get(hObject,'String')) returns contents of TargetInput as a double
target=get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function TargetInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
target=NaN;
set(handles.CurrentRate, 'String', '0');
set(handles.Errors, 'String', 'Experiment Stopped');
save('Target.mat', 'target');
