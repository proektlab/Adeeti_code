function varargout = MouseData(varargin)
% MOUSEDATA MATLAB code for MouseData.fig
%      MOUSEDATA, by itself, creates a new MOUSEDATA or raises the existing
%      singleton*.
%
%      H = MOUSEDATA returns the handle to a new MOUSEDATA or the handle to
%      the existing singleton*.
%
%      MOUSEDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOUSEDATA.M with the given input arguments.
%
%      MOUSEDATA('Property','Value',...) creates a new MOUSEDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MouseData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MouseData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MouseData

% Last Modified by GUIDE v2.5 01-Jul-2016 11:45:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MouseData_OpeningFcn, ...
                   'gui_OutputFcn',  @MouseData_OutputFcn, ...
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


% --- Executes just before MouseData is made visible.
function MouseData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MouseData (see VARARGIN)

% Choose default command line output for MouseData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MouseData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MouseData_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function weight_Callback(hObject, eventdata, handles)
% hObject    handle to weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of weight as text
%        str2double(get(hObject,'String')) returns contents of weight as a double


% --- Executes during object creation, after setting all properties.
function weight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to weight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
weight=get(hObject, 'String');
guidata(hObject, handles);




function SubjectName_Callback(hObject, eventdata, handles)
% hObject    handle to SubjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of SubjectName as text
%        str2double(get(hObject,'String')) returns contents of SubjectName as a double
name=get(hObject, 'String');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SubjectName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SubjectName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
weight=str2num(get(handles.weight, 'String'));
name=get(handles.SubjectName, 'String');
if isempty(weight)
    set(handles.Errors, 'ForegroundColor', 'r');
    set(handles.Errors, 'String', 'Weight Must be a Number');
elseif weight<=0;
    set(handles.Errors, 'ForegroundColor', 'r');
    set(handles.Errors, 'String', 'Weight Must be Non-Negative');
elseif isempty(name)
    set(handles.Errors, 'ForegroundColor', 'r');
    set(handles.Errors, 'String', 'Must input subject Name');
else
    set(handles.Errors, 'ForegroundColor', 'g');
    set(handles.Errors, 'String', ['Weight is ' num2str(weight) ' g. ' 'Name is ' name '.']);
    save('Mouse.mat', 'weight', 'name');
    pause(1);
    delete(handles.figure1);
    
end