function varargout = adteditor(varargin)
% ADTEDITOR MATLAB code for adteditor.fig
%      ADTEDITOR, by itself, creates a new ADTEDITOR or raises the existing
%      singleton*.
%
%      H = ADTEDITOR returns the handle to a new ADTEDITOR or the handle to
%      the existing singleton*.
%
%      ADTEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADTEDITOR.M with the given input arguments.
%
%      ADTEDITOR('Property','Value',...) creates a new ADTEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before adteditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to adteditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help adteditor

% Last Modified by GUIDE v2.5 17-Oct-2014 18:46:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @adteditor_OpeningFcn, ...
                   'gui_OutputFcn',  @adteditor_OutputFcn, ...
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


% --- Executes just before adteditor is made visible.
function adteditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to adteditor (see VARARGIN)

    % Choose default command line output for adteditor
    handles.output = hObject;

    % Store the bag file in handles...
    handles.Data.Bag = [];

    % Let's roll out...
    fprintf('\nStarting ADT editor...\n');

    % Check arguments...
    if ~ischar(varargin{1})
        
        % WARNING: Passing the rosbag as an argument is not going to work
        % at the moment because it relies on deep copying of handle
        % objects which is not currently working.  Work in progress.
        handles.Data.Bag = varargin{1};
        
        % Parse info from the rosbag...
        Info = handles.Data.Bag.info();
        TopicStrings = strsplit(Info(findstr(Info, 'topics:'):end), '\n');
        
        topiccounter = 1;
        for iTopic = 1:length(TopicStrings)            
            
            TopicInfo = strsplit(TopicStrings{iTopic});
            
            if length(TopicInfo) >= 6
                handles.Data.TopicNames{topiccounter} = TopicInfo{2};
                handles.Data.TopicSizes{topiccounter} = str2num(TopicInfo{3});
                handles.Data.TopicTypes{topiccounter} = TopicInfo{6};
            end
            
            topiccounter = topiccounter + 1;
        end
        
        % Create separate bag view objects for each topic...
        for iTopic = 1:length(handles.Data.TopicNames)
            handles.Data.BagTopicViews{iTopic} = handles.Data.Bag.copy();
            handles.Data.BagTopicViews{iTopic} =...
                handles.Data.Bag.resetView(handles.Data.TopicNames{iTopic});
        end
        
    else
        
        % Load rosbag file...
        fprintf('\nLoading rosbag file.  Please wait...');
        handles.Data.Bag = Bag.load(varargin{1});
        
        % Parse info from the rosbag...
        Info = handles.Data.Bag.info();
        TopicStrings = strsplit(Info(findstr(Info, 'topics:'):end), '\n');
        
        topiccounter = 1;
        for iTopic = 1:length(TopicStrings)            
            
            TopicInfo = strsplit(TopicStrings{iTopic});
            
            if length(TopicInfo) >= 6
                handles.Data.TopicNames{topiccounter} = TopicInfo{2};
                handles.Data.TopicSizes{topiccounter} = str2num(TopicInfo{3});
                handles.Data.TopicTypes{topiccounter} = TopicInfo{6};
            end
            
            topiccounter = topiccounter + 1;
        end
        
        % Create separate bag view objects for each topic...
        for iTopic = 1:length(handles.Data.TopicNames)
            handles.Data.BagTopicViews{iTopic} =...
                Bag.load(varargin{1});
            handles.Data.BagTopicViews{iTopic} =...
                handles.Data.Bag.resetView(handles.Data.TopicNames{iTopic});
        end
        
    end
    
    if ~isempty(handles.Data.Bag)                        
        
        %
        % Read and plot the first topic..
        %
        [Msg Meta] = handles.Data.Bag.readAll({handles.Data.TopicNames{1}}, true);
        % Msg = handles.Data.BagTopicViews{1}.readAll();
        
        MsgMat = cell2mat(Msg);
        MetaMat = cell2mat(Meta);
         
        handles.Data.TopicData{1}.position = [MsgMat.position];
        handles.Data.TopicData{1}.orientation = [MsgMat.orientation];
        handles.Data.TopicData{1}.time = [MetaMat.time];                
                
        plot(handles.MainAxes, handles.Data.TopicData{1}.position(1,:), 'r');        
        hold on;
        
        %
        % Draw a blue vertical timestep tracking line...
        %
        handles.Data.currenttimestep = 1;
        plot(handles.MainAxes, [handles.Data.currenttimestep, handles.Data.currenttimestep;...
                                min(handles.Data.TopicData{1}.position(1,:)), max(handles.Data.TopicData{1}.position(1,:))], 'b');
        axis([0 length(handles.Data.TopicData{1}.position(1,:))...
              min(handles.Data.TopicData{1}.position(1,:)) max(handles.Data.TopicData{1}.position(1,:))]);
        
        % Reset the bag file...
        % handles.Data.Bag = handles.Data.Bag.resetView(handles.Data.TopicNames, [], []);
        % handles.Data.BagTopicViews{1} = handles.Data.BagTopicViews{1}.resetView(handles.Data.TopicNames, [], []);        
        
        %
        % Read and plot the camera image...
        %
        % It uses BGR8 encoding.
        % 
        handles.Data.BagTopicViews{16} = handles.Data.Bag.resetView(handles.Data.TopicNames{16});
        [Msg Meta] = handles.Data.BagTopicViews{16}.read();
        %Convert data type
        ImageData = typecast(Msg.data,'uint8');
        % ImageData = Msg{1}.data;
        %Re-Order the data into a matlab rgb array. The raw data has the
        %format RGBRGBRGB.... beginning with the upper left image pixel
        %(0,0). This format has to be converted to matlab format
        Image(:,:,1) = reshape(ImageData(1:3:end), Msg.width, Msg.height);
        Image(:,:,2) = reshape(ImageData(2:3:end), Msg.width, Msg.height);
        Image(:,:,3) = reshape(ImageData(3:3:end), Msg.width, Msg.height);        
        % Flip the values
        Image = flipdim(Image,2);        
        % Flip again for bgr encoding.
        Image = flipdim(Image,3);
        %Rotate the image 90 degrees
        Image = imrotate(Image, 90);               
        handles.hImage = figure;
        imshow(Image);
        
        %
        % Read and plot the depth image...
        %k
        % It uses 16UC1 encoding.
        %
        handles.Data.BagTopicViews{14} = handles.Data.Bag.resetView(handles.Data.TopicNames{14});
        [Msg Meta] = handles.Data.BagTopicViews{14}.read();
        % DepthIndices = 1 : 2 : (Msg{1}.width * Msg{1}.height * 2);
        % DepthImage = reshape(Msg{1}.data(DepthIndices), Msg{1}.width, Msg{1}.height);
        DepthImage = reshape(typecast(Msg.data,'uint16'), Msg.width, Msg.height);
        DepthImage = flipdim(DepthImage, 2);
        DepthImage = imrotate(DepthImage, 90);
        handles.hDepthImage = figure;
        imagesc(DepthImage);
        
        % Populate the topics list...        
        % for iTopic = 1:length(handles.Data.TopicNames)    
        %     TopicTypeList{iTopic} = [handles.Data.TopicNames{iTopic}...
        %                              '  ('...
        %                              handles.Data.TopicTypes{iTopic} ')'];
        % end
        % set(handles.TopicList, 'String', TopicTypeList);
        
        set(handles.TopicList, 'String', handles.Data.TopicNames);
        
        fprintf('\n...finished!\n');
        
    end

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes adteditor wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    


% --- Outputs from this function are returned to the command line.
function varargout = adteditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function MainAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate MainAxes


% --- Executes on selection change in TopicList.
function TopicList_Callback(hObject, eventdata, handles)
% hObject    handle to TopicList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns TopicList contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from TopicList    


% --- Executes during object creation, after setting all properties.
function TopicList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TopicList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    


% --- Executes on button press in StepButton.
function StepButton_Callback(hObject, eventdata, handles)
% hObject    handle to StepButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    %
    % Read and plot the camera image...
    %
    % It uses BGR8 encoding.
    % 
    [Msg Meta] = handles.Data.BagTopicViews{16}.read();
    %Convert data type
    ImageData = typecast(Msg.data,'uint8');
    % ImageData = Msg{1}.data;
    %Re-Order the data into a matlab rgb array. The raw data has the
    %format RGBRGBRGB.... beginning with the upper left image pixel
    %(0,0). This format has to be converted to matlab format
    Image(:,:,1) = reshape(ImageData(1:3:end), Msg.width, Msg.height);
    Image(:,:,2) = reshape(ImageData(2:3:end), Msg.width, Msg.height);
    Image(:,:,3) = reshape(ImageData(3:3:end), Msg.width, Msg.height);        
    % Flip the values
    Image = flipdim(Image,2);        
    % Flip again for bgr encoding.
    Image = flipdim(Image,3);
    %Rotate the image 90 degrees
    Image = imrotate(Image, 90);               
    figure(handles.hImage);
    imshow(Image);
    drawnow;
    
    %
    % Read and plot the depth image...
    %k
    % It uses 16UC1 encoding.
    %
    [Msg Meta] = handles.Data.BagTopicViews{14}.read();
    % DepthIndices = 1 : 2 : (Msg{1}.width * Msg{1}.height * 2);
    % DepthImage = reshape(Msg{1}.data(DepthIndices), Msg{1}.width, Msg{1}.height);
    DepthImage = reshape(typecast(Msg.data,'uint16'), Msg.width, Msg.height);
    DepthImage = flipdim(DepthImage, 2);
    DepthImage = imrotate(DepthImage, 90);
    figure(handles.hDepthImage);
    imagesc(DepthImage);
    drawnow;

    %
    % Draw a blue vertical timestep tracking line...
    %
    handles.Data.currenttimestep = handles.Data.currenttimestep + 1;
    plot(handles.MainAxes, [handles.Data.currenttimestep, handles.Data.currenttimestep;...
                            min(handles.Data.TopicData{1}.position(1,:)), max(handles.Data.TopicData{1}.position(1,:))], 'b');
    axis([0 length(handles.Data.TopicData{1}.position(1,:))...
          min(handles.Data.TopicData{1}.position(1,:)) max(handles.Data.TopicData{1}.position(1,:))]);

