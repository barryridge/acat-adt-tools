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
%      existing singleton*.  Starting from the left, property value pairs ar
%      applied to the GUI before adteditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to adteditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help adteditor

% Last Modified by GUIDE v2.5 10-Nov-2014 15:08:28

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
    
    %% ---------
    % VARIABLES
    %-----------
    
    % File/directory variables...
    handles.Data.BagDirName = [];
    handles.Data.XMLDirName = [];
    handles.Data.BagFileName = [];
    handles.Data.XMLFileName = [];

    % rosbag variables. Stored in handles.
    handles.Data.ADTBag = [];
    handles.Data.ADTBagMeta = [];
    handles.Data.ADTBagMsg = [];
    
    handles.Data.ADTBagInfo = [];
    handles.Data.ADTBagTopicInfo = [];
    handles.Data.ADTBagTopicNames = [];
    handles.Data.ADTBagTopicSizes = [];
    handles.Data.ADTBagTopicStrings = [];
    handles.Data.ADTBagTopicTypes = [];

    % Let's roll out...
    fprintf('\nStarting ADT editor...\n');

    %% -------------------------
    % INPUT ARGUMENT PROCESSING
    %---------------------------
    
    % Check BagSpec argument...
    if nargin >= 1
        
        BagSpec = varargin{1};
        
        if ischar(BagSpec) && isdir(BagSpec)                        
            
            % Get the directory name...
            [Pathstr, Name, Ext] = fileparts(BagSpec);
            handles.Data.BagDirName = [Pathstr '/' Name];
            
            % Find the bag file...                        
            BagFileNames = dir([BagDirName '/*.bag']);            
            if size(BagFileNames,1) >= 1
                % We just assume it's the first in the list.
                handles.Data.BagFileName = BagFileNames(1).name;
            end
            
            % Find the xml file...
            % We just assume it's the first in the list.
            handles.Data.XMLDirName = handles.Data.BagDirName;
            XMLFileNames = dir([BagDirName '/ADT*.xml']);
            if size(XMLFileNames,1) >= 1
                % We just assume it's the first in the list.
                handles.Data.XMLFileName = XMLFileNames(1).name;
            end
            
        elseif ischar(BagSpec) && exist(BagSpec, 'file')
            
            % Get the file name...
            [Pathstr, handles.Data.BagFileName, Ext] = fileparts(BagSpec);
            handles.Data.BagFileName = [BagFileName Ext];
            if isempty(Pathstr)
                Pathstr = '.';
            else
                BagDirName = Pathstr;
            end
        
        elseif ~ischar(BagSpec) && isobject(BagSpec)

            % WARNING: Passing the rosbag as an argument is not going to work
            % at the moment because it relies on deep copying of handle
            % objects which is not currently working.  Work in progress.
            handles.Data.ADTBag = BagSpec;

        elseif ~ischar(BagSpec) && iscell(BagSpec)

            if size(BagSpec,2) == 3 && isobject(BagSpec{1}) && iscell(BagSpec{2}) && iscell(BagSpec{3})

                handles.Data.ADTBag = BagSpec{1};
                handles.Data.ADTBagMeta = BagSpec{2};
                handles.Data.ADTBagMsg = BagSpec{3};

            else
                error('adttool: argument 1 was not in [Bag, Meta, Msg] format!');
            end

        else
            
            error(['adteditor: argument 1 should be either a directory name, '...
                   'a rosbag file name or a rosbag struct.']);

        end
    end
    
    %% ------------
    % FILE LOADING
    %--------------
    
    % Load rosbag...
    if isempty(handles.Data.ADTBag)
        if ~isempty(BagFileName)

            fprintf('Loading rosbag file...');
            handles.Data.ADTBag = ros.ADTBag.load([BagDirName '/' BagFileName]);
            fprintf('finished!\n');

        else
            error('adttool: No rosbag specified!');
        end    
    end
    
    % Read rosbag topic info...
    if isempty(handles.Data.ADTBagInfo)        
        fprintf('Loading rosbag topic info');
        
        % Parse info from the rosbag...
        handles.Data.ADTBagInfo = handles.Data.ADTBag.info();
        handles.Data.ADTBagTopicStrings =...
            strsplit(handles.Data.ADTBagInfo(findstr(handles.Data.ADTBagInfo, 'topics:'):end), '\n');

        topiccounter = 1;
        for iTopic = 1:length(handles.Data.ADTBagTopicStrings)            

            handles.Data.ADTBagTopicInfo = strsplit(handles.Data.ADTBagTopicStrings{iTopic});

            if length(handles.Data.ADTBagTopicInfo) >= 6
                handles.Data.ADTBagTopicNames{topiccounter} = handles.Data.ADTBagTopicInfo{2};
                handles.Data.ADTBagTopicSizes{topiccounter} = str2num(handles.Data.ADTBagTopicInfo{3});
                handles.Data.ADTBagTopicTypes{topiccounter} = handles.Data.ADTBagTopicInfo{6};
            end

            topiccounter = topiccounter + 1;
            
            % Print progress dots...
            fprintf('.');
            
        end
        
        fprintf('finished!\n');        
    end
    
    % Read topics...
    if isempty(handles.Data.ADTBagMeta) || isempty(handles.Data.ADTBagMsg)
        fprintf('Reading rosbag topics.  This can take some time.  Grab a coffee or watch the dots.');
        
        % Read all data in each topic separately...
        for iTopic = 1:length(handles.Data.ADTBagTopicNames)        

            [handles.Data.ADTBagMsg{iTopic} handles.Data.ADTBagMeta{iTopic}] =...
                handles.Data.ADTBag.readAll({handles.Data.ADTBagTopicNames{iTopic}});

            % Print progress dots...
            fprintf('.');
        end
        
        fprintf('finished!\n');
    end
    
    % Plot topics...
    if ~isempty(handles.Data.ADTBagMeta) && ~isempty(handles.Data.ADTBagMsg)                        
        
        handles.Data.currentframe = 1;
        handles.Data.currenttimestep =...
            handles.Data.ADTBagMeta{1}{handles.Data.currentframe}.time.time;
        
        handles.hImage = figure;
        handles.hDepthImage = figure;
        
        update(hObject, eventdata, handles);
        
        %
        % Set up axis button-down callback...
        %
        % set(gcf,'WindowButtonDownFcn', @(hObject,eventdata)adteditor('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
        set(handles.MainAxes,'HitTest','on');
        set(handles.MainAxes,'ButtonDownFcn', @(hObject,eventdata)adteditor('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
        hMainAxesChildren = get(handles.MainAxes, 'Children');
        for iChild = 1:size(hMainAxesChildren,1)
            set(hMainAxesChildren(iChild),'HitTest','off');
            set(hMainAxesChildren(iChild), 'ButtonDownFcn', @(hObject,eventdata)adteditor('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
        end
        
        % Populate the topics list...        
        % for iTopic = 1:length(handles.Data.TopicNames)    
        %     TopicTypeList{iTopic} = [handles.Data.TopicNames{iTopic}...
        %                              '  ('...
        %                              handles.Data.TopicTypes{iTopic} ')'];
        % end
        % set(handles.TopicList, 'String', TopicTypeList);
        
        set(handles.TopicList, 'String', handles.Data.ADTBagTopicNames);
        
        fprintf('\n...finished!\n');
        
    end

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes adteditor wait for user response (see UIRESUME)
    % uiwait(handles.figure1);
    
    
function varargout = update(hObject, eventdata, handles)

    %
    % Draw arm position trajectories...
    %
    figure(handles.figure1);
    subplot(handles.MainAxes);
    cla;
    
    % Search for the robot data topic...
    iDataTopic = findtopic(handles.Data.ADTBagTopicNames, 'data', 'fuzzy');

    % MsgMat = cell2mat(handles.Data.ADTBagMsg);
    % MetaMat = cell2mat(handles.Data.ADTBagMeta);

    % handles.Data.TopicData{1}.position = [MsgMat.position];
    % handles.Data.TopicData{1}.orientation = [MsgMat.orientation];
    % handles.Data.TopicData{1}.time = [MetaMat.time];

    PosAccessor = @(X) X.ArmPose.position;
    % OrientAccessor = @(X) X.ArmPose.orientation;

    handles.Data.TopicData{1}.position =...
        ros.msgs2mat(handles.Data.ADTBagMsg{iDataTopic}, PosAccessor);

    plot(handles.MainAxes, handles.Data.TopicData{1}.position(1,:), 'r');        
    hold on;
    
    %
    % Draw a blue vertical timestep tracking line...
    %
    plot(handles.MainAxes, [handles.Data.currentframe, handles.Data.currentframe],...
                           [min(handles.Data.TopicData{1}.position(1,:)), max(handles.Data.TopicData{1}.position(1,:))], 'b');
    axis([0 length(handles.Data.TopicData{1}.position(1,:))...
          min(handles.Data.TopicData{1}.position(1,:)) max(handles.Data.TopicData{1}.position(1,:))]);

    %
    % Read and plot the camera image...
    %
    % It uses BGR8 encoding.
    % 
    iRGBTopic = findtopic(handles.Data.ADTBagTopicNames, 'rgb/image_color', 'fuzzy');
    % handles.Data.ADTBagTopicViews{iRGBTopic} = handles.Data.ADTBag.resetView(handles.Data.ADTBagTopicNames{iRGBTopic});
    % [Msg Meta] = handles.Data.ADTBagTopicViews{iRGBTopic}.read();
    
    % Search for the right frame in the topic based on current timestep.
    iRGBTopicFrame = 0;
    for iFrame = 1:size(handles.Data.ADTBagMeta{iRGBTopic}, 2)
        if handles.Data.ADTBagMeta{iRGBTopic}{iFrame}.time.time >=...
            handles.Data.currenttimestep....
                && ~iRGBTopicFrame
            iRGBTopicFrame = iFrame;  
            break;
        end       
    end
    
    Msg = handles.Data.ADTBagMsg{iRGBTopic}{iRGBTopicFrame};
    Meta = handles.Data.ADTBagMeta{iRGBTopic}{iRGBTopicFrame};
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
    %
    % It uses 16UC1 encoding.
    %
    % [Msg Meta] = handles.Data.ADTBagTopicViews{iDepthTopic}.read();
    iDepthTopic = findtopic(handles.Data.ADTBagTopicNames, 'depth_registered/image_raw', 'fuzzy');
    % handles.Data.ADTBagTopicViews{iDepthTopic} = handles.Data.ADTBag.resetView(handles.Data.ADTBagTopicNames{iDepthTopic});
    % [Msg Meta] = handles.Data.ADTBagTopicViews{iDepthTopic}.read();
    
    % Search for the right frame in the topic based on current timestep.
    iDepthTopicFrame = 0;
    for iFrame = 1:size(handles.Data.ADTBagMeta{iDepthTopic}, 2)
        if handles.Data.ADTBagMeta{iDepthTopic}{iFrame}.time.time >=...
            handles.Data.currenttimestep....
                && ~iDepthTopicFrame
            iDepthTopicFrame = iFrame;  
            break;
        end       
    end
    
    Msg = handles.Data.ADTBagMsg{iDepthTopic}{iDepthTopic};
    Meta = handles.Data.ADTBagMeta{iDepthTopic}{iDepthTopic};
    % DepthIndices = 1 : 2 : (Msg{1}.width * Msg{1}.height * 2);
    % DepthImage = reshape(Msg{1}.data(DepthIndices), Msg{1}.width, Msg{1}.height);
    DepthImage = reshape(typecast(Msg.data,'uint16'), Msg.width, Msg.height);
    DepthImage = flipdim(DepthImage, 2);
    DepthImage = imrotate(DepthImage, 90);
    figure(handles.hDepthImage);
    imagesc(DepthImage);
    drawnow;
    
    % Update handles structure
    guidata(hObject, handles);


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

    handles.Data.currentframe = handles.Data.currentframe + 100;
    
    update(hObject, eventdata, handles);
    
    % Update handles structure
    guidata(hObject, handles);
    

%% ----------------
% HELPER FUNCTIONS
%------------------

function index = findtopic(TopicNames, Topic, varargin)

    % Defaults
    cmpfunc = @strcmp;

    if nargin
        switch lower(varargin{1})
            case {'fuzzy', 'strfind'},
                cmpfunc = @strfind;
            case {'exact', 'strcmpi'},
                cmpfunc = @strcmpi;
            case {'exactcase', 'strcmp'}
                cmpfunc = @strcmp;
                
            otherwise, cmpfnc = @strcmp;
        end
    end

    for index = 1:size(TopicNames,2)

        found = false;

        if cmpfunc(TopicNames{index}, Topic)
            found = true;
            break;
        end

        if ~found
            index = 0;
        end

    end


% --- Executes on mouse press over axes background.
function MainAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    cp = get(gca,'currentpoint');
    
    handles.Data.currentframe = round(cp(1,1));    
    handles.Data.currenttimestep =...
        handles.Data.ADTBagMeta{1}{handles.Data.currentframe}.time.time;
    
    update(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);