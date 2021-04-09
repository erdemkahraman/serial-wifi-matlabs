function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 23-Jan-2020 15:06:04


% Configuration and connection


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


%end
% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp ('Receiver started');
if(get(handles.esp1,'Value'))
    t=tcpip('192.168.1.128', 23,'NetworkRole','Client');
    set(t, 'InputBufferSize', 1024);
end

if(get(handles.esp2,'Value'))
    t=tcpip('192.168.1.137', 23,'NetworkRole','Client');
    set(t, 'InputBufferSize', 1024);
end
if(get(handles.esp3,'Value'))
    t=tcpip('192.168.1.138', 23,'NetworkRole','Client');
    set(t, 'InputBufferSize', 1024);
end

if(get(handles.esp4,'Value'))
    t=tcpip('192.168.1.128', 23,'NetworkRole','Client');
    set(t, 'InputBufferSize', 1024);
end
%while 1
% Wait for connection

disp('Waiting for connection');
fclose(t);
fopen(t);
disp('Connection OK');
set(handles.status, 'String', 'Connected');

% Read data from the socket
 DataReceived1 = 0;
if(get(handles.config,'Value'))  
     
    if(get(handles.RF1, 'Value') == 1)
        rf_cs = 1;
    elseif(get(handles.RF2, 'value') == 1)
        rf_cs = 2;
    else
        rf_cs = 0;
    end
    att = str2num(get(handles.Att_value, 'string'));
    att = att .* 10;
    att_a = att ./ 256;
    att_a_int = uint8(att_a);
    att_b = mod(att,256);

    if(att_b == att)
       att_over=0;
    else
       att_over=1;
    end
    
    att_over=uint8(att_over);

    sendData = [186,1,0,rf_cs,att_b,att_over,24,25] %0:none 1: 6820 2:6720 sendData = [186,1,0,ADRF_6X20,att_b,1,24,25]

   disp("packet sending")
   fwrite(t, sendData);
   disp("packet sended")
   
   pause(0.01);
   timeout = 0;
   disp("packet waiting..")
   
   while(get(t, 'BytesAvailable') == 0)  % block the program until bytesavailable, we get answer from stm32 here
     pause(0.01);
     timeout = timeout + 1;
     if(timeout >= 1000)
        break
     end
   end
   
   disp("packet receiving")
   DataReceived = fread(t,8,'uint8')
   disp("packet received")

   id  = num2str([DataReceived(3),DataReceived(4),DataReceived(5),DataReceived(6)]) %The received data from stm32 includes ID number of the card (1,2,3, or 4)
   set(handles.ID, 'String', id);
 
  fclose(t);
  disp('Connection close');

 else %UBX Selection (cases)
    %Disable NMEA
    GxGGA_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'00';'00';'FA';'0F'])]; 
    GxGLL_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'01';'00';'FB';'11'])]; 
    GxGSA_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'02';'00';'FC';'13'])]; 
    GxGSV_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'03';'00';'FD';'15'])]; 
    GxRMC_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'04';'00';'FE';'17'])]; 
    GxVTG_OFF = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'05';'00';'FF';'19'])];
    
    nema_OFF_7  = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'06';'00';'00';'1B'])]; 
    nema_OFF_8  = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'07';'00';'01';'1D'])]; 
    nema_OFF_9  = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'08';'00';'02';'1F'])]; 
    nema_OFF_10 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'09';'00';'03';'21'])]; 
    nema_OFF_11 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'0A';'00';'04';'23'])]; 
    nema_OFF_12 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'0D';'00';'07';'29'])];
    nema_OFF_13 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F0';'0F';'00';'09';'2D'])];

    nema_OFF_14 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'00';'00';'FB';'12'])]; 
    nema_OFF_15 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'01';'00';'FC';'14'])]; 
    nema_OFF_16 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'03';'00';'FE';'18'])]; 
    nema_OFF_17 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'04';'00';'FF';'1A'])]; 
    nema_OFF_18 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'05';'00';'00';'1C'])];
    nema_OFF_19 = [hex2dec(['B5';'62';'06';'01';'03';'00';'F1';'06';'00';'01';'1E'])];

    poll_posllh           = [hex2dec(['B5';'62';'01';'02';'00';'00';'03';'0A'])]; %ok
    poll_almanac          = [hex2dec(['B5';'62';'0B';'30';'00';'00';'3B';'BC'])]; %ok
    poll_RXM_RAWX         = [hex2dec(['B5';'62';'02';'15';'00';'00';'17';'47'])]; %ok
    poll_NAV_POSECEF      = [hex2dec(['B5';'62';'01';'01';'00';'00';'02';'07'])]; %ok
    poll_clk              = [hex2dec(['B5';'62';'01';'22';'00';'00';'23';'6A'])]; %ok
    
    sendData = [181,98,6,1,8,0,1,2,0,1,0,0,0,0,16,44];

    pause(2);

    fwrite(t, poll_posllh);
     fwrite(t, poll_posllh);
     fwrite(t, poll_posllh);
     fwrite(t, poll_posllh);
    fwrite(t, poll_posllh);
    
      DataReceived = fread(t,100,'uint8')
      DataReceived = fread(t,100,'uint8')
      DataReceived = fread(t,100,'uint8')
      DataReceived = fread(t,100,'uint8')
      DataReceived = fread(t,100,'uint8')
      fclose(t);
    
   end
 set(handles.status, 'String', 'Disconnect');

 

% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function Att_value_Callback(hObject, eventdata, handles)
% hObject    handle to Att_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Att_value as text
%        str2double(get(hObject,'String')) returns contents of Att_value as a double


% --- Executes during object creation, after setting all properties.
function Att_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Att_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RF1_min_Callback(hObject, eventdata, handles)
% hObject    handle to RF1_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RF1_min as text
%        str2double(get(hObject,'String')) returns contents of RF1_min as a double


% --- Executes during object creation, after setting all properties.
function RF1_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RF1_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RF2_max_Callback(hObject, eventdata, handles)
% hObject    handle to RF2_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RF2_max as text
%        str2double(get(hObject,'String')) returns contents of RF2_max as a double


% --- Executes during object creation, after setting all properties.
function RF2_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RF2_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RF2_min_Callback(hObject, eventdata, handles)
% hObject    handle to RF2_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RF2_min as text
%        str2double(get(hObject,'String')) returns contents of RF2_min as a double


% --- Executes during object creation, after setting all properties.
function RF2_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RF2_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if(get(handles.esp1,'Value'))
    disp ('esp1 led on');
    tt=tcpip('0.0.0.0', 5005,'NetworkRole','server');
    %while 1
    % Wait for connection
    disp('Waiting for connection');
    fopen(tt);
    disp('Connection OK');

    % Read data from the socket

    DataReceived = 0;
 
    sendData = [190,180,1,2,2,1,1,0,0,0,0,18,19];

    fwrite(tt,sendData);
    pause(2);
     fclose(tt);
    disp('Connection close');
 end
% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 if(get(handles.esp1,'Value'))
    disp ('Receiver started');
    tt=tcpip('0.0.0.0', 5005,'NetworkRole','server');
    %while 1
    % Wait for connection
    disp('Waiting for connection');
    fopen(tt);
    disp('Connection OK');

    % Read data from the socket

    DataReceived = 0;
 
    sendData = [190,180,1,2,2,2,2,0,0,0,0,18,19];

    fwrite(tt,sendData);
     pause(2);

    fclose(tt);
    disp('Connection close');
 end
% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RF3_max_Callback(hObject, eventdata, handles)
% hObject    handle to RF3_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RF3_max as text
%        str2double(get(hObject,'String')) returns contents of RF3_max as a double


% --- Executes during object creation, after setting all properties.
function RF3_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RF3_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RF3_min_Callback(hObject, eventdata, handles)
% hObject    handle to RF3_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RF3_min as text
%        str2double(get(hObject,'String')) returns contents of RF3_min as a double


% --- Executes during object creation, after setting all properties.
function RF3_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RF3_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fclose(t);


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RF1.
function RF1_Callback(hObject, eventdata, handles)
% hObject    handle to RF1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 %set(handles.RF1, 'Value', 1);
 %set(handles.RF2, 'Value', 0);
 rf_cs = 1;
% Hint: get(hObject,'Value') returns toggle state of RF1


% --- Executes on button press in RF2.
function RF2_Callback(hObject, eventdata, handles)
% hObject    handle to RF2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 %set(handles.RF1, 'Value', 0);
% set(handles.RF2, 'Value', 1);
 rf_cs = 2;
% Hint: get(hObject,'Value') returns toggle state of RF2


% --- Executes on button press in config.
function config_Callback(hObject, eventdata, handles)
% hObject    handle to config (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(handles.config, 'Value', 1);
 set(handles.UBX, 'Value', 0);
% Hint: get(hObject,'Value') returns toggle state of config


% --- Executes on button press in UBX.
function UBX_Callback(hObject, eventdata, handles)
% hObject    handle to UBX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(handles.config, 'Value', 0);
 set(handles.UBX, 'Value', 1);
% Hint: get(hObject,'Value') returns toggle state of UBX
