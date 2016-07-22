function varargout = OrthogonalModeViewer(varargin)
% ORTHOGONALMODEVIEWER MATLAB code for OrthogonalModeViewer.fig
%      ORTHOGONALMODEVIEWER, by itself, creates a new ORTHOGONALMODEVIEWER or raises the existing
%      singleton*.
%
%      H = ORTHOGONALMODEVIEWER returns the handle to a new ORTHOGONALMODEVIEWER or the handle to
%      the existing singleton*.
%
%      ORTHOGONALMODEVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ORTHOGONALMODEVIEWER.M with the given input arguments.
%
%      ORTHOGONALMODEVIEWER('Property','Value',...) creates a new ORTHOGONALMODEVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before OrthogonalModeViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to OrthogonalModeViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help OrthogonalModeViewer

% Last Modified by GUIDE v2.5 20-Jul-2016 16:18:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @OrthogonalModeViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @OrthogonalModeViewer_OutputFcn, ...
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


% --- Executes just before OrthogonalModeViewer is made visible.
function OrthogonalModeViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to OrthogonalModeViewer (see VARARGIN)

% must have CLI arguments
% OrthogonalModeViewer([datadir], [nlatent]);
if( numel(varargin)~=2 )
    error('Not enough argument.\nCall: OrthogonalModeViewer( DATADIR, NLATENT );%s', ' ');
end

% Choose default command line output for OrthogonalModeViewer
handles.output = hObject;

% read the data
handles.datadir = varargin{1};
handles.nlatent = varargin{2};

% compute initially
[handles.modes, handles.pcs] = GenerateOrthogonalModes( handles.datadir, handles.nlatent );

% get clinical index names
CI = importdata(fullfile(handles.datadir, 'clinical_index.csv'));
handles.sel.String = CI.textdata(1,2:end);

handles.mean_shape = importdata(fullfile(handles.datadir,'mean_shape.csv'));
handles.faces = importdata(fullfile(handles.datadir,'surface_face.csv'));

handles.edendopts = 1:numel(handles.mean_shape)/4;
handles.edepipts = (1+handles.edendopts(end)):numel(handles.mean_shape)/2;
handles.esendopts = (1+handles.edepipts(end)):(3*numel(handles.mean_shape)/4);
handles.esepipts = (1+handles.esendopts(end)):numel(handles.mean_shape);

% first draw
handles.edT = [0 40 0];  % translate
handles.esT = [0 -40 0]; % translate
handles.get_points = @(V,T) repmat(T,numel(V)/3,1) + reshape(V,3,[])';

handles.edendo = patch('Faces', handles.faces, 'Vertices', handles.get_points(handles.mean_shape(handles.edendopts), handles.edT), 'EdgeColor',[0 1 0], 'FaceColor',[0 1 0], 'FaceAlpha', 0.9);
hold(handles.ax, 'on');
handles.edepi = patch('Faces', handles.faces, 'Vertices', handles.get_points(handles.mean_shape(handles.edepipts), handles.edT), 'EdgeColor','none', 'FaceColor',[ 0.9765    0.3608    0.3608], 'FaceAlpha', 0.4);
handles.esendo = patch('Faces', handles.faces, 'Vertices', handles.get_points(handles.mean_shape(handles.esendopts), handles.esT), 'EdgeColor',[0 1 0], 'FaceColor',[0 1 0], 'FaceAlpha', 0.9);
handles.esepi = patch('Faces', handles.faces, 'Vertices', handles.get_points(handles.mean_shape(handles.esepipts), handles.esT), 'EdgeColor','none', 'FaceColor',[ 0.9765    0.3608    0.3608], 'FaceAlpha', 0.4);
axis(handles.ax, 'equal');
light;
lighting('gouraud');

cameratoolbar;
handles.ax.CameraViewAngle = 5.4773;
handles.ax.CameraUpVector = [-0.9925   -0.0094    0.1219];
handles.ax.CameraPosition = [-151.476661654203,108.100638535696,-1377.97896181032];
handles.ax.CameraTarget = [18.5150    1.7695   -1.9810];

DrawMode(handles);

%view(handles.ax, [-96 -86]);

handles.labelPct.String = sprintf('Percentile = %.2f', handles.sliderMode.Value );

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes OrthogonalModeViewer wait for user response (see UIRESUME)
% uiwait(handles.fig);


% --- Outputs from this function are returned to the command line.
function varargout = OrthogonalModeViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderMode_Callback(hObject, eventdata, handles)
% hObject    handle to sliderMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

handles.labelPct.String = sprintf('Percentile = %.2f', handles.sliderMode.Value );

DrawMode(handles);


% --- Executes during object creation, after setting all properties.
function sliderMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when fig is resized.
function fig_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- DRAW MODE
function DrawMode(handles)

% generate shape
S = GenerateShapeFromMode( handles.modes(:, handles.sel.Value), ...
    handles.pcs(:, handles.sel.Value), ...
    handles.sliderMode.Value, ...
    'mean_shape', handles.mean_shape );

% replace vertices
handles.edendo.Vertices = handles.get_points(S(1,handles.edendopts), handles.edT);
handles.edepi.Vertices = handles.get_points(S(1,handles.edepipts), handles.edT);
handles.esendo.Vertices = handles.get_points(S(2,handles.edendopts), handles.esT);
handles.esepi.Vertices = handles.get_points(S(2,handles.edepipts), handles.esT);



% --- Executes on selection change in sel.
function sel_Callback(hObject, eventdata, handles)
% hObject    handle to sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sel

DrawMode(handles);


% --- Executes during object creation, after setting all properties.
function sel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
