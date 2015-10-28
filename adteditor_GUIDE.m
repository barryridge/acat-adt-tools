function varargout = adteditor_GUIDE(varargin)
% adteditor_GUIDE MATLAB code for adteditor_GUIDE.fig
%      adteditor_GUIDE, by itself, creates a new adteditor_GUIDE or raises the existing
%      singleton*.
%
%      H = adteditor_GUIDE returns the handle to a new adteditor_GUIDE or the handle to
%      the existing singleton*.
%
%      adteditor_GUIDE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in adteditor_GUIDE.M with the given input arguments.
%
%      adteditor_GUIDE('Property','Value',...) creates a new adteditor_GUIDE or raises the
%      existing singleton*.  Starting from the left, property value pairs ar
%      applied to the GUI before adteditor_GUIDE_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to adteditor_GUIDE_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help adteditor_GUIDE

% Last Modified by GUIDE v2.5 27-Oct-2015 17:53:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @adteditor_GUIDE_OpeningFcn, ...
                   'gui_OutputFcn',  @adteditor_GUIDE_OutputFcn, ...
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

% --- Executes just before adteditor_GUIDE is made visible.
function adteditor_GUIDE_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to adteditor_GUIDE (see VARARGIN)

     import javax.swing.*
     import javax.swing.tree.*;

    %
    % Set up persistent variables in Data struct in handles,
    % but only if the opening function is being called for
    % the first time...
    %
    if ~isfield(handles, 'Data') 

        % Choose default command line output for adteditor_GUIDE
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

        % ADT XML struct...
        handles.Data.XML = [];

        % Topic indices...
        handles.Data.iRGBTopic = 0;
        handles.Data.iDepthTopic = 0;    

        % Currently loaded topics...
        handles.Data.TopicData = {};
        handles.Data.TopicMap = [];

        % Main axes object handles..
        % handles.Data.CurrentPlots = {};
        handles.Data.hTopicPlots = [];
        handles.Data.hTrackingLine = [];
        handles.Data.hSelection = [];
        % handles.Data.hSelectionContextMenu = [];
        % handles.Data.hSelectionContextMenuItems = [];

        % Set up selection context menu...        
        handles.Data.hSelectionContextMenu = uicontextmenu;
        handles.Data.hSelectionContextMenuItems(1) =...
            uimenu(handles.Data.hSelectionContextMenu, 'label', 'New Action Chunk');                  

        % Topic tree stuff...
        handles.Data.Tree = [];
        handles.Data.hJTree = [];
        handles.Data.TreeModel = [];
        handles.Data.hTree = [];
        handles.Data.hTreeContainer = [];
        handles.Data.topicTreeDimLimit = 10;

        % Checkbox stuff...
        handles.Data.javaImage_checked = [];
        handles.Data.javaImage_unchecked = [];
        handles.Data.iconWidth = [];

        % Action chunks...
        handles.Data.ActionChunks = [];
        handles.Data.ActionChunkNames = [];
        handles.Data.hActionChunks = [];
        handles.Data.hActionChunksText = [];
        % handles.Data.hActionChunkContextMenu = [];
        % handles.Data.hActionChunkContextMenuItems = [];

        % Set up action chunk context menu...        
        handles.Data.hActionChunkContextMenu = uicontextmenu;
        handles.Data.hActionChunkContextMenuItems(1) =...
            uimenu(handles.Data.hActionChunkContextMenu, 'label', 'Delete Action Chunk');

        % SEC...
        handles.Data.SECButtons = [];

        % Plot flags...
        handles.Data.isselectionplotted = false;
        handles.Data.istrackinglineplotted = false;

        % Axes limits...
        handles.Data.mainAxesMaxX = NaN;
        handles.Data.mainAxesMinY = NaN;
        handles.Data.mainAxesMaxY = NaN;

        % Mouse click flags...
        handles.Data.LeftButtonStates = struct('DOWN',1,'INMOTION',2,'UP',3);
        handles.Data.LastLeftButtonState = handles.Data.LeftButtonStates.UP;
        handles.Data.CurrentLeftButtonState = handles.Data.LeftButtonStates.UP;

        % Mouse click points...
        handles.Data.iCurrentFrame = 1;
        handles.Data.DownPoint = [0,0];
        handles.Data.CurrentPoint = [0,0];

        % Current timing topic...
        handles.Data.iTimingTopic = 1;

        % Current timestep in bag...
        handles.Data.currenttimestep = 0;

        % Flags...
        handles.Data.updateplots = true;    
        handles.Data.fileinputspecified = false;
        handles.Data.alreadyrunning = true;
        handles.Data.isgrabbinghandacttopic = false;

        % function_handle callbacks...
        handles.Data.SetTextToEditing = @(~,~,x) set(x, 'editing', 'on');

        % Update handles structure
        guidata(hObject, handles);

        % Let's roll out...
        fprintf('\nStarting ADT editor...\n');

    end

    %% -------------------------
    % INPUT ARGUMENT PROCESSING
    %---------------------------        

    % When a rosbag specification has been passed...
    if nargin > 3

        InputSpec = varargin{1};

        % ...if it's a directory...
        if ischar(InputSpec) && isdir(InputSpec)                        

            % Get the directory name...
            [Pathstr, Name, Ext] = fileparts(InputSpec);
            handles.Data.BagDirName = fullfile(Pathstr, Name);

            % Find the bag file...                        
            BagFileNames = dir([handles.Data.BagDirName '/*.bag']);            
            if size(BagFileNames,1) >= 1
                % We just assume it's the first in the list.
                handles.Data.BagFileName = BagFileNames(1).name;
            end

            % Find the xml file...
            % We just assume it's the first in the list.
            handles.Data.XMLDirName = handles.Data.BagDirName;
            XMLFileNames = dir([handles.Data.BagDirName '/ADT*.xml']);
            if size(XMLFileNames,1) >= 1
                % We just assume it's the first in the list.
                handles.Data.XMLFileName = XMLFileNames(1).name;
            end

            handles.Data.fileinputspecified = true;

        % ...if it's a file...
        elseif ischar(InputSpec) && exist(InputSpec, 'file')

            % Get the file name...
            [Pathstr, FileName, Ext] = fileparts(InputSpec);

            switch lower(Ext)
                case {'.bag'}
                    handles.Data.BagDirName = Pathstr;
                    handles.Data.BagFileName = [FileName, Ext];

                case {'.xml', '.txt'}
                    handles.Data.XMLDirName = Pathstr;
                    handles.Data.XMLFileName = [FileName, Ext];
            end

            handles.Data.fileinputspecified = true;

        % ...if it's ros bag variable...
        elseif ~ischar(InputSpec) && isobject(InputSpec)

            % WARNING: Passing the rosbag as an argument is not going to work
            % at the moment because it relies on deep copying of handle
            % objects which is not currently working.  Work in progress.
            handles.Data.ADTBag = InputSpec;

        % ...if it's a ros bag cell array in {Bag, Meta, Msg} format...
        elseif ~ischar(InputSpec) && iscell(InputSpec)

            if size(InputSpec,2) == 3 && isobject(InputSpec{1}) && iscell(InputSpec{2}) && iscell(InputSpec{3})

                handles.Data.ADTBag = InputSpec{1};
                handles.Data.ADTBagMeta = InputSpec{2};
                handles.Data.ADTBagMsg = InputSpec{3};

            else
                handles.Data.fileinputspecified = false;
                display('adteditor_GUIDE: argument 1 was not in [Bag, Meta, Msg] format!');
            end

        else
            handles.Data.fileinputspecified = false;
            display(['adteditor_GUIDE: argument 1 should be either a directory name, '...
                   'a rosbag file name or a rosbag struct.']);

        end        

    end

    %% ------------
    % FILE LOADING
    %--------------        

    % Load rosbag...
    if handles.Data.fileinputspecified

        if ~isempty(handles.Data.XMLFileName)

            % Load ADT XML file...
            [handles.Data.XML XMLRootName XMLDOMNode] =...
                xml_read(fullfile(handles.Data.XMLDirName, handles.Data.XMLFileName));

            % Search for a ros bag filename in the XML...
            if isfield(handles.Data.XML, 'recording_DASH_data')

                % Grab the file spec. from the XML...
                BagFileSpec = handles.Data.XML.recording_DASH_data;

                if ~isempty(BagFileSpec)

                    % Break it down...
                    [BagDirName BagFileName BagFileExt] = fileparts(BagFileSpec);

                    if isempty(BagDirName)
                        handles.Data.BagDirName = handles.Data.XMLDirName;                    
                    else
                        handles.Data.BagDirName = BagDirName;                    
                    end

                    handles.Data.BagFileName = [BagFileName BagFileExt];

                    if exist(fullfile(handles.Data.BagDirName, handles.Data.BagFileName), 'file')

                        % Ask if we should load the ros bag...
                        rosbagchoice = questdlg(['A ROS bag file associated with this ADT was found. '...
                                           '(' fullfile(handles.Data.BagDirName, handles.Data.BagFileName) ') '...
                                           'Would you like to load the ROS bag? (Note: this could take some time!)'],...
                                           'Load ROS bag file?',...
                                           'Yes','No','No');

                        % Handle response
                        switch rosbagchoice

                            case 'Yes'

                                % Load ros bag file...
                                [handles.Data.ADTBag, handles.Data.ADTBagMeta, handles.Data.ADTBagMsg,...
                                 handles.Data.ADTBagInfo, handles.Data.ADTBagTopicNames, handles.Data.ADTBagTopicSizes,...
                                 handles.Data.ADTBagTopicTypes] =...
                                    loadbag(fullfile(handles.Data.BagDirName, handles.Data.BagFileName), true);

                                %
                                % Populate the SECLink list boxes etc...
                                %
                                set(handles.SECLink_Topic_DropDown, 'string', {'None' handles.Data.ADTBagTopicNames{:}});
                                set(handles.SECLink_Topic_ListBox, 'string', {'None', 'None', 'None'});
                                set(handles.SECLink_FirstObj_TextBox, 'string', 'First Object');
                                set(handles.SECLink_FirstObj_ListBox, 'string', {'hand', 'main-object', 'main-object'});
                                set(handles.SECLink_SecondObj_TextBox, 'string', 'Second Object');
                                set(handles.SECLink_SecondObj_ListBox, 'string', {'main-object', 'primary-object', 'secondary-object'});

                               % Search for action chunks...
                               if isfield(handles.Data.XML, 'action_DASH_chunks')
                                   % XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.timestamp
                                   if isfield(handles.Data.XML.action_DASH_chunks, 'action_DASH_chunk')

                                       % Ask if we should load the ros bag...
                                       chunkchoice = questdlg(['Action chunks and SEC information were found for this ADT/ROS bag. '...
                                                               '(' fullfile(handles.Data.BagDirName, handles.Data.BagFileName) ') '...
                                                               'Would you like to load the action chunks and SEC?'],...
                                                               'Load action chunks?',...
                                                               'Yes','No','Yes');

                                       switch chunkchoice

                                           case 'Yes'

                                                % Find a data topic in the bag...
                                                %
                                                % NOTE: We're going to cheat a little here.
                                                % Since we don't know in advance what topic we
                                                % should actually be using, we pick the longest one...
                                                iDataTopic = 0;
                                                maxtopiclength = 0;
                                                for iTopic = 1:size(handles.Data.ADTBagMeta, 2)
                                                    if size(handles.Data.ADTBagMeta{iTopic}, 2) >= maxtopiclength
                                                        maxtopiclength = size(handles.Data.ADTBagMeta{iTopic}, 2);
                                                        iDataTopic = iTopic;
                                                    end
                                                end

                                                % Set the axis based on
                                                % this...
                                                axis([0 maxtopiclength 0 1]);

                                                % Loop through action chunks...
                                                for iChunk = 1:length(handles.Data.XML.action_DASH_chunks.action_DASH_chunk)

                                                   % Find a valid object field in this chunk...
                                                   ActionChunkFields = fields(handles.Data.XML.action_DASH_chunks.action_DASH_chunk(iChunk));
                                                   ObjField = [];
                                                   for iField = 1:size(ActionChunkFields,1)                                                       
                                                       if isstruct(handles.Data.XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ActionChunkFields{iField}))
                                                           ObjField = ActionChunkFields{iField};
                                                           break;
                                                       end
                                                   end                                                                                                                                                         

                                                   % If a valid object field was found in the XML and a valid
                                                   % data topic was found in the ROS bag, we continue...
                                                   if ~isempty(ObjField) && iDataTopic ~= 0 && maxtopiclength ~= 0

                                                       % ...search for the start and end position timestamps in the
                                                       % rosbag...
                                                       iObjStartFrame = 0;
                                                       iObjEndFrame = 0;
                                                       for iFrame = 1:size(handles.Data.ADTBagMeta{iDataTopic}, 2)

                                                           if handles.Data.ADTBagMeta{iDataTopic}{iFrame}.time.time >=...
                                                              handles.Data.XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.timestamp...
                                                               && ~iObjStartFrame
                                                               iObjStartFrame = iFrame;                               
                                                           end

                                                           if handles.Data.ADTBagMeta{iDataTopic}{iFrame}.time.time >=...
                                                              handles.Data.XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.timestamp
                                                               iObjEndFrame = iFrame;
                                                               break;
                                                           end
                                                       end

                                                       % Set up chunk coords...
                                                       Axis = axis;                                                       
                                                       XData(1) = iObjStartFrame;
                                                       YData(1) = Axis(3);                                                       
                                                       XData(2) = iObjEndFrame;
                                                       YData(2) = Axis(3);                                                       
                                                       XData(3) = iObjEndFrame;
                                                       YData(3) = Axis(4);                                                       
                                                       XData(4) = iObjStartFrame;
                                                       YData(4) = Axis(4);                                                       

                                                       % Draw a blue action chunk...
                                                       handles.Data.hActionChunks{end+1} =...
                                                            patch(XData,...
                                                                  YData,...
                                                                  [0 0 0.75],...                 
                                                                  'Parent', handles.MainAxes);

                                                        XData = sort(XData(1:2));

                                                        % Draw a text box...
                                                        handles.Data.hActionChunksText{end+1} =...
                                                            text(XData(1) + abs((XData(2) - XData(1))/2),...
                                                                 YData(1) + abs((YData(1) - YData(3))/2),...
                                                                 handles.Data.XML.action_DASH_chunks.action_DASH_chunk(iChunk).context,...
                                                                 'color', 'w',...
                                                                 'BackgroundColor', [0 0 0.75],...
                                                                 'HorizontalAlignment','center',...
                                                                 'editing', 'on');

                                                        % settexttoediting = @(~, ~) set(handles.Data.hActionChunksText{end}, 'editing', 'on');
                                                        % set(handles.Data.hActionChunksText{end}, 'buttondownfcn', settexttoediting);                                                                        
                                                        set(handles.Data.hActionChunksText{end}, 'buttondownfcn',...
                                                            {handles.Data.SetTextToEditing, handles.Data.hActionChunksText{end}});

                                                        % Send the blue action chunk to the bottom of the draw stack...
                                                        uistack(handles.Data.hActionChunks{end}, 'bottom');      

                                                        % Send the action chunk text to the top of the draw stack...
                                                        uistack(handles.Data.hActionChunksText{end}, 'top');

                                                        % Create a new action chunk...
                                                        % handles.Data.ActionChunks{end+1}.iStartFrame = handles.

                                                        % Update handles structure
                                                        guidata(hObject, handles);

                                                        % Attach a context menu...        
                                                        set(handles.Data.hActionChunks{end}, 'uicontextMenu', handles.Data.hActionChunkContextMenu);
                                                        set(handles.Data.hActionChunkContextMenuItems(1),'callback',...
                                                            {@DeleteActionChunk_Callback, guidata(hObject), size(handles.Data.hActionChunks,2)});

                                                   else

                                                       errordlg('Invalid action chunks in ADT!');

                                                   end

                                                end

                                                % Update handles structure
                                                guidata(hObject, handles);

                                                % Update the SEC button panel...
                                                [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles);

                                                % Grab SEC values from ADT...
                                                SEC = [];
                                                for iSECRow = 1:size(handles.Data.XML.anchor_DASH_points.SEC_DASH_line,1)
                                                    SEC(iSECRow,:) = handles.Data.XML.anchor_DASH_points.SEC_DASH_line(iSECRow).CONTENT;
                                                end

                                                % Set the values in the
                                                % GUI...
                                                for iSEC = 1:size(SEC(:),1)
                                                    set(handles.Data.SECButtons(iSEC), 'Value', SEC(iSEC));
                                                end

                                           case 'No'

                                               % Do nothing...
                                       end

                                   end
                               end


                            case 'No'

                                % Do nothing...
                                errordlg('No ROS bag file loaded!');
                        end

                    end

                else

                    errordlg('No ROS bag file specified!');

                end

            elseif ~isempty(handles.Data.BagFileName)

                % Load ros bag file...
                [handles.Data.ADTBag, handles.Data.ADTBagMeta, handles.Data.ADTBagMsg] =...
                    loadbag(fullfile(handles.Data.BagDirName, handles.Data.BagFileName), true);            

            else

                errordlg('No ROS bag file specified in ADT XML file!');

            end

        elseif ~isempty(handles.Data.BagFileName)

                % Load ros bag file...
                [handles.Data.ADTBag, handles.Data.ADTBagMeta, handles.Data.ADTBagMsg] =...
                    loadbag(fullfile(handles.Data.BagDirName, handles.Data.BagFileName), true);            

        else

            errordlg('No ADT XML file or ROS bag file specified!');

        end

    end

    if ~isempty(handles.Data.ADTBag)

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

        % Set up topics plot...
        if ~isempty(handles.Data.ADTBagMeta) && ~isempty(handles.Data.ADTBagMsg)                        

            handles.Data.iCurrentFrame = 1;
            handles.Data.currenttimestep =...
                handles.Data.ADTBagMeta{handles.Data.iTimingTopic}{handles.Data.iCurrentFrame}.time.time;

            [hObject, eventdata, handles] = updatemainplot(hObject, eventdata, handles);                

            % Check for the JSI image topic format first...            
            handles.Data.iRGBTopic = findtopic(handles.Data.ADTBagTopicNames, 'rgb/image_color', 'fuzzy');

            % Otherwise try the AAU image topic format...
            if handles.Data.iRGBTopic == 0                
                handles.Data.iRGBTopic = findtopic(handles.Data.ADTBagTopicNames, '/carmineAAU/rgb/image_rect_color', 'fuzzy');
            end                                     

            % If we have a valid image topic, set up a preview figure and
            % perform the first update...
            if handles.Data.iRGBTopic ~= 0 && ~isfield(handles, 'hImageFig')                
                handles.hImageFig = figure;
                handles.hImageAxes = axes;
                [hObject, eventdata, handles] = updatecameraimage(hObject, eventdata, handles);
            end                

            % Check for the JSI depth topic format...
            handles.Data.iDepthTopic = findtopic(handles.Data.ADTBagTopicNames, 'depth_registered/image_raw', 'fuzzy');

            % If we have a valid image topic, set up a preview figure and
            % perform the first update...
            if handles.Data.iDepthTopic ~= 0 && ~isfield(handles, 'hDepthImageFig')
                handles.hDepthImageFig = figure;
                handles.hDepthImageAxes = axes;
                [hObject, eventdata, handles] = updatedepthimage(hObject, eventdata, handles);
            end

            %
            % Focus and hold main figure axes...
            %        
            figure(handles.MainFig);
            subplot(handles.MainAxes);
            hold on;

            %
            % Set callbacks to be uninterruptible...
            %        
            set(handles.MainFig, 'Interruptible', 'off');
            set(handles.MainFig, 'BusyAction', 'cancel');

            %
            % Close all figures when main fig is closed...
            %        
            % deleteallfigures = @(~, ~) delete(findobj(0,'type','figure'));
            set(handles.MainFig, 'DeleteFcn', {@deletefigures, guidata(hObject)});

            % Update handles structure
            guidata(hObject, handles);

            %
            % Set up axis button-down, button-motion and button-up callbacks...
            %
            % set(hObject,'WindowButtonDownFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
            set(handles.MainAxes,'HitTest','on');
            % set(hObject,'WindowButtonDownFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
            % set(hObject,'WindowButtonMotionFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonMotionFcn',hObject,eventdata,guidata(hObject)));        
            set(handles.MainAxes,'ButtonDownFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
            set(handles.MainFig,'WindowButtonUpFcn', @(hObject,eventdata)adteditor_GUIDE('MainFig_ButtonUpFcn',hObject,eventdata,guidata(hObject)));
            % hMainAxesChildren = get(handles.MainAxes, 'Children');
            % for iChild = 1:size(hMainAxesChildren,1)
            %     set(hMainAxesChildren(iChild),'HitTest','off');
            %     set(hMainAxesChildren(iChild), 'ButtonDownFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonDownFcn',hObject,eventdata,guidata(hObject)));
            %     set(hMainAxesChildren(iChild), 'ButtonUpFcn', @(hObject,eventdata)adteditor_GUIDE('MainAxes_ButtonUpFcn',hObject,eventdata,guidata(hObject)));
            % end                

            %
            % Populate the topics list...        
            %
            % for iTopic = 1:length(handles.Data.TopicNames)    
            %     TopicTypeList{iTopic} = [handles.Data.TopicNames{iTopic}...
            %                              '  ('...
            %                              handles.Data.TopicTypes{iTopic} ')'];
            % end
            % set(handles.TopicList, 'String', TopicTypeList);        
            % set(handles.TopicList, 'String', handles.Data.ADTBagTopicNames);                

            % Set up checked/unchecked icons for topic tree...
            [I,map] = checkedIcon;
            handles.Data.javaImage_checked = im2java(I,map);

            [I,map] = uncheckedIcon;
            handles.Data.javaImage_unchecked = im2java(I,map);

            handles.Data.iconWidth = handles.Data.javaImage_unchecked.getWidth;

            % Set up hash table for topic data...        
            handles.Data.TopicMap = containers.Map;

            % Search for the robot data topic...
            % handles.Data.iDataTopic = findtopic(handles.Data.ADTBagTopicNames, 'lwr_data', 'fuzzy');

            % Recursively build topic tree from the data topic root...
            % handles.Data.Tree = buildtopictree(hObject, eventdata, handles, handles.Data.iDataTopic);
            handles.Data.Tree = buildtopictree(hObject, eventdata, handles);

            % set treeModel
            handles.Data.TreeModel = DefaultTreeModel( handles.Data.Tree );

            % create the tree
            % handles.Data.Tree = uitree('v0');
            [handles.Data.hTree, handles.Data.hTreeContainer] =...
                uitree('v0', 'Root', handles.Data.Tree);
            handles.Data.hTree.setModel( handles.Data.TreeModel );
            handles.Data.hTree.MultipleSelectionEnabled = true;
            % we often rely on the underlying java tree
            handles.Data.hJTree = handle(handles.Data.hTree.getTree, 'CallbackProperties');

            % Update handles structure
            guidata(hObject, handles);

            % set(handles.Data.Tree, 'Units', 'normalized', 'position', [0 0 1 0.5]);
            % set(tree, 'NodeSelectedCallback', @selected_cb );
            % function selected_cb( tree, ev )
            Tree = handles.Data.Tree;
            % set(handles.Data.hTree, 'NodeSelectedCallback',...
            %     @(Tree, eventdata, hObject)adteditor_GUIDE('CheckBoxSelected_Callback', handles.Data.Tree, eventdata, hObject, guidata(hObject)) );
            set(handles.Data.hTree,'NodeSelectedCallback', {@CheckBoxSelected_Callback, hObject, guidata(hObject)});

            % make root the initially selected node
            % handles.Data.hTree.setSelectedNode(handles.Data.Tree);

            % Update handles structure
            guidata(hObject, handles);

            % MousePressedCallback is not supported by the uitree, but by jtree
            % set(jtree, 'MousePressedCallback', @mousePressedCallback);
            % function mousePressedCallback(hTree, eventData) %,additionalVar)
            % function NodeMousePressed_Callback(tree, eventdata, hObject, handles)
            % set(handles.Data.hJTree, 'MousePressedCallback', @(hObject,eventdata)adteditor_GUIDE('NodeMousePressed_Callback',hObject,eventdata,guidata(hObject)));
            % set(handles.Data.hJTree, 'MousePressedCallback', @(hObject)adteditor_GUIDE('NodeMousePressed_Callback', guidata(hObject)));
            % set(handles.Data.hJTree, 'MousePressedCallback',...
            %     @(handles, eventdata, hObject)adteditor_GUIDE('NodeMousePressed_Callback', handles.Data.hTree, eventdata, hObject, guidata(hObject)));
            set(handles.Data.hJTree,'MousePressedCallback', {@NodeMousePressed_Callback, hObject, guidata(hObject)});

            % figure(handles.MainFig, 'pos',[300,300,150,150]);
            set(handles.Data.hTreeContainer, 'Parent',handles.MainFig);
            set(handles.Data.hTreeContainer, 'Units','pixels', 'Position', [20 180 160 500]);

            %
            % Set up action chunk mask...
            %                
            % handles.Data.ActionChunkMask = zeros(size(handles.Data.ADTBagMeta{handles.Data.iDataTopic}));

            %
            % Populate the SECLink list boxes etc...
            %
            set(handles.SECLink_Topic_DropDown, 'string', {'None' handles.Data.ADTBagTopicNames{:}});
            set(handles.SECLink_Topic_ListBox, 'string', {'None', 'None', 'None'});
            set(handles.SECLink_FirstObj_TextBox, 'string', 'First Object');
            set(handles.SECLink_FirstObj_ListBox, 'string', {'hand', 'main-object', 'main-object'});
            set(handles.SECLink_SecondObj_TextBox, 'string', 'Second Object');
            set(handles.SECLink_SecondObj_ListBox, 'string', {'main-object', 'primary-object', 'secondary-object'});

            fprintf('\n...finished!\n');

        end

    end

    %
    % Set renderer
    %
    set(handles.MainFig, 'Renderer', 'painters');
    % set(handles.MainFig, 'Renderer', 'opengl');

    %
    % Set draw mode...
    %
    % set(handles.MainAxes, 'drawmode', 'fast');
    % set(handles.MainAxes, 'SortMethod', 'depth');
    set(handles.MainAxes, 'SortMethod', 'childorder');

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes adteditor_GUIDE wait for user response (see UIRESUME)
    % uiwait(handles.MainFig);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% NodeMousePressed_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function NodeMousePressed_Callback(hObject, eventdata)
function NodeMousePressed_Callback(tree, eventdata, hObject, handles)
% if eventData.isMetaDown % right-click is like a Meta-button
% if eventData.getClickCount==2 % how to detect double clicks

    % Get the clicked node
    clickX = eventdata.getX;
    clickY = eventdata.getY;
    treePath = handles.Data.hJTree.getPathForLocation(clickX, clickY);
    % check if a node was clicked
    if ~isempty(treePath)

        % Check if we need to update hand_act_topic_link_textbox
        if get(handles.hand_act_topic_link_toggle, 'Value')
            set(handles.hand_act_topic_link_textbox, 'String', node2path(treePath));
        end

        % Check if the checkbox was clicked
        if clickX <= (handles.Data.hJTree.getPathBounds(treePath).x+handles.Data.iconWidth)
            node = treePath.getLastPathComponent;
            nodeValue = node.getValue;
            % as the value field is the selected/unselected flag,
            % we can also use it to only act on nodes with these values
            switch nodeValue
              case 'selected'
                node.setValue('unselected');
                node.setIcon(handles.Data.javaImage_unchecked);
                handles.Data.hJTree.treeDidChange();
              case 'unselected'
                node.setValue('selected');
                node.setIcon(handles.Data.javaImage_checked);
                handles.Data.hJTree.treeDidChange();
            end
        end
    end

    % Update handles structure
    % guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CheckBoxSelected_Callback 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function CheckBoxSelected_Callback( tree, ev, handles )
function CheckBoxSelected_Callback( tree, ev, hObject, handles)
   
    nodes = tree.getSelectedNodes;
    node = nodes(1);
    topicPath = node2path(node);

    if handles.Data.TopicMap.isKey(topicPath)

        TempStruct = handles.Data.TopicMap(topicPath);

        % Invert the selection...
        TempStruct.isSelected = ~TempStruct.isSelected;

        % Invert the plot flag...
        TempStruct.isPlotted = ~TempStruct.isPlotted;

        handles.Data.TopicMap(topicPath) = TempStruct;

        % Set plot update flag...
        handles.Data.updateplots = true;

        % Update handles structure
        guidata(hObject, handles);

        % Call for a plot update...        
        [hObject, eventdata, handles] = updatemainplot(hObject, ev, handles);

    else                

        %
        % Create the accessor string for the selected sub-topic...
        %

        % Search for the topic names inside the topic path and find the
        % right one...
        iDataTopic = findtopic(handles.Data.ADTBagTopicNames, topicPath, 'revfuzzy');

        if iDataTopic > 0                        

            % Remove this main topic path from topicPath and find the sub-path...
            iTopicStringStart = strfind(topicPath, handles.Data.ADTBagTopicNames{iDataTopic});
            topicSubPath = topicPath(iTopicStringStart + size(handles.Data.ADTBagTopicNames{iDataTopic},2):end);

            % Split up the topicSubPath into substrings...
            % topicStringSplitArray = strsplit(topicPath, '/');
            topicStringSplitArray = strsplit(topicSubPath, '/');

            % Drop the last sub-string (e.g. 'Dim 1', 'Dim 2', etc.) in order
            % to construct the topic accessor function (see below).
            % topicSubStrings = {topicStringSplitArray{find(strcmp(topicStringSplitArray, 'lwr_data'))+1:end-1}};
            topicSubStrings = topicStringSplitArray(1:end-1);

            % Remove any empty strings...
            topicSubStrings = topicSubStrings(~cellfun('isempty',topicSubStrings));

            if ~isempty(topicSubStrings)

                % Create temp struct for TopicMap hash table assignment...
                TempStruct = [];

                TempStruct.topicPath = topicPath;

                % Set up accessor string for the matlab_rosbag msgs2mat
                % function...
                TempStruct.accessor = ['@(X) X.' strjoin(topicSubStrings, '.')];

                % Grab the sub-topic data from the rosbag using the
                % accessor string...
                tempDataArray =...
                    ros.msgs2mat(handles.Data.ADTBagMsg{iDataTopic}, eval(TempStruct.accessor));

                if ~isempty(tempDataArray)                

                    % If there is more than one dimension, we need to select
                    % the right one...
                    if size(tempDataArray,1) > 1
                        dimStringSplitArray = strsplit(topicStringSplitArray{end});
                        TempStruct.dataArray = tempDataArray(str2num(dimStringSplitArray{end}), :);
                    else
                        TempStruct.dataArray = tempDataArray;
                    end                                    

                    % If the array is empty, then something has gone wrong and
                    % we should not try to plot it.
                    if ~isempty(TempStruct.dataArray)

                        TempStruct.isLoaded = true;
                        TempStruct.isPlotted = true;
                        TempStruct.isSelected = true;

                        TempStruct.plotColour = [rand rand rand];

                        handles.Data.TopicMap(topicPath) = TempStruct;

                        handles.Data.updateplots = true;

                        % Update handles structure
                        guidata(hObject, handles);

                        % Call for a plot update...
                        [hObject, eventdata, handles] = updatemainplot(hObject, ev, handles);

                        % If we've gotten this far, we might need to update
                        % the timing topic...
                        if size(handles.Data.ADTBagMeta{iDataTopic},2) >...
                           size(handles.Data.ADTBagMeta{handles.Data.iTimingTopic},2)

                            handles.Data.iTimingTopic = iDataTopic;

                        end

                    end

                end

            end
        end

    end


    % Update handles structure
    guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% node2path 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function path = node2path(node)
    path = node.getPath;
    for i=1:length(path);
      p{i} = char(path(i).getName);
    end
    if length(p) > 1
      path = fullfile(p{:});
    else
      path = p{1};
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% buildtopictree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Tree = buildtopictree(hObject, eventdata, handles, varargin)

    if nargin > 3

        Tree = varargin{1};
        TopicString = varargin{2};
        Topic = eval(TopicString);

        % If the topic is a struct, there are two possibilities...
        if isstruct(Topic)

            % If it's a valid struct, build a subtree from each field...
            if size(Topic,2) > 0

                TreeRootFields = fields(Topic);

                for iField = 1:size(TreeRootFields,1)

                    SubTree = uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], true);

                    Tree.setAllowsChildren(true);
                    Tree.add(buildtopictree(hObject, eventdata, handles, SubTree,...
                             [TopicString '.' TreeRootFields{iField}]));                    
                end

            % If we hit an empty struct, place leaf nodes for each field...    
            else

                TreeRootFields = fields(Topic);

                for iField = 1:size(TreeRootFields,1)
                    Tree.setAllowsChildren(true);
                    Leaf = uitreenode('v0', 'unselected', TreeRootFields{iField}, [], false);
                    Leaf.setIcon(handles.Data.javaImage_unchecked);
                    % Tree.add(uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], false));                
                    Tree.add(Leaf);
                end

            end

        % If the topic is an array, place leaf notes for each dimension...
        elseif size(Topic,1) > 1

            % topicStringSplitArray = strsplit(TopicString,'.');
            % TopicStringLeaf = topicStringSplitArray{end};

            % SubTree = uitreenode('v0', TopicStringLeaf, TopicStringLeaf, [], true);

            % Make sure we're not dealing with an image or there will be
            % too many dimensions...
            if size(Topic,1) <= handles.Data.topicTreeDimLimit

                for iRow = 1:size(Topic,1)
                    Tree.setAllowsChildren(true);
                    Leaf = uitreenode('v0', 'unselected', ['Dim ' num2str(iRow)], [], false);
                    Leaf.setIcon(handles.Data.javaImage_unchecked);
                    Tree.add(Leaf);
                end

            end

            % Tree.setAllowsChildren(true);
            % Tree.add(SubTree);

        % If the topic is a singleton, do nothing...
        else

            % topicStringSplitArray = strsplit(TopicString,'.');
            % TopicStringLeaf = topicStringSplitArray{end};
            % 
            % Tree.setAllowsChildren(true);
            % Tree.add(uitreenode('v0', TopicStringLeaf, TopicStringLeaf, [], false));

        end

    else

        % Make node...
        Tree = uitreenode('v0', 'root', 'root', [], true);

        for iTopic = 1:size(handles.Data.ADTBagTopicNames,2)

            if iscell(handles.Data.ADTBagMsg{iTopic})

                SubTree = uitreenode('v0', handles.Data.ADTBagTopicNames{iTopic},...
                                        handles.Data.ADTBagTopicNames{iTopic}, [], true);

                % if isstruct(handles.Data.ADTBagMsg{iTopic}{1})
                % 
                %     TreeRootFields = fields(handles.Data.ADTBagMsg{iTopic}{1});
                % 
                %     for iField = 1:size(TreeRootFields,1)
                % 
                %         SubTree = uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], true);
                % 
                %         Tree.setAllowsChildren(true);
                %         Tree.add(buildtopictree(hObject, eventdata, handles, SubTree,...
                %                  ['handles.Data.ADTBagMsg{' num2str(iTopic) '}{1}.' TreeRootFields{iField}]));                    
                %     end
                % 
                % end

                Tree.setAllowsChildren(true);
                Tree.add(buildtopictree(hObject, eventdata, handles, SubTree,...
                                 ['handles.Data.ADTBagMsg{' num2str(iTopic) '}{1}'])); 

            end
        end

    end        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% buildspecifictopictree 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Tree = buildspecifictopictree(hObject, eventdata, handles, iDataTopic, varargin)

    if nargin > 4

        Tree = varargin{1};
        TopicString = varargin{2};
        Topic = eval(TopicString);

        % If the topic is a struct, there are two possibilities...
        if isstruct(Topic)

            % If it's a valid struct, build a subtree from each field...
            if size(Topic,2) > 0

                TreeRootFields = fields(Topic);

                for iField = 1:size(TreeRootFields,1)

                    SubTree = uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], true);

                    Tree.setAllowsChildren(true);
                    Tree.add(buildtopictree(hObject, eventdata, handles, iDataTopic, SubTree,...
                             [TopicString '.' TreeRootFields{iField}]));                    
                end

            % If we hit an empty struct, place leaf nodes for each field...
            else

                TreeRootFields = fields(Topic);

                for iField = 1:size(TreeRootFields,1)
                    Tree.setAllowsChildren(true);
                    Leaf = uitreenode('v0', 'unselected', TreeRootFields{iField}, [], false);
                    Leaf.setIcon(handles.Data.javaImage_unchecked);
                    % Tree.add(uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], false));                
                    Tree.add(Leaf);
                end

            end

        % If the topic is an array, place leaf notes for each dimension...
        elseif size(Topic,1) > 1

            topicStringSplitArray = strsplit(TopicString,'.');
            TopicStringLeaf = topicStringSplitArray{end};

            % SubTree = uitreenode('v0', TopicStringLeaf, TopicStringLeaf, [], true);

            for iRow = 1:size(Topic,1)
                Tree.setAllowsChildren(true);
                Leaf = uitreenode('v0', 'unselected', ['Dim ' num2str(iRow)], [], false);
                Leaf.setIcon(handles.Data.javaImage_unchecked);
                Tree.add(Leaf);
            end

            % Tree.setAllowsChildren(true);
            % Tree.add(SubTree);

        % If the topic is a singleton, do nothing...
        else

            % topicStringSplitArray = strsplit(TopicString,'.');
            % TopicStringLeaf = topicStringSplitArray{end};
            % 
            % Tree.setAllowsChildren(true);
            % Tree.add(uitreenode('v0', TopicStringLeaf, TopicStringLeaf, [], false));
            % display('nothing');

        end

    else

        if iscell(handles.Data.ADTBagMsg{iDataTopic})

            % Make node...
            Tree = uitreenode('v0', handles.Data.ADTBagTopicNames{iDataTopic},...
                                handles.Data.ADTBagTopicNames{iDataTopic}, [], true);

            if isstruct(handles.Data.ADTBagMsg{iDataTopic}{1})

                TreeRootFields = fields(handles.Data.ADTBagMsg{iDataTopic}{1});

                for iField = 1:size(TreeRootFields,1)

                    SubTree = uitreenode('v0', TreeRootFields{iField}, TreeRootFields{iField}, [], true);

                    Tree.setAllowsChildren(true);
                    Tree.add(buildtopictree(hObject, eventdata, handles, iDataTopic, SubTree,...
                             ['handles.Data.ADTBagMsg{iDataTopic}{1}.' TreeRootFields{iField}]));                    
                end

            end
        end

    end        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updatemainplot 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hObject, eventdata, handles] = updatemainplot(hObject, eventdata, handles)   

    % MsgMat = cell2mat(handles.Data.ADTBagMsg);
    % MetaMat = cell2mat(handles.Data.ADTBagMeta);

    % handles.Data.TopicData{1}.position = [MsgMat.position];
    % handles.Data.TopicData{1}.orientation = [MsgMat.orientation];
    % handles.Data.TopicData{1}.time = [MetaMat.time];

    %
    % Clear the axes if necessary...
    %
    % if handles.Data.updateplots
    %     cla(handles.MainAxes);
    % end

    %
    % Plot a green selection box...
    %   
    if handles.Data.CurrentLeftButtonState == handles.Data.LeftButtonStates.INMOTION &&...
       handles.Data.LastLeftButtonState ~= handles.Data.LeftButtonStates.UP

        if handles.Data.isselectionplotted
            handles.Data.isselectionplotted = false;
        end

        if ishandle(handles.Data.hSelection)
            delete(handles.Data.hSelection);                        
        end

        if handles.Data.istrackinglineplotted            
            handles.Data.istrackinglineplotted = false;
        end       

        if ishandle(handles.Data.hTrackingLine)
            delete(handles.Data.hTrackingLine);
        end

        x_1 = round(handles.Data.DownPoint(1));
        y_1 = handles.Data.mainAxesMinY;
        x_2 = round(handles.Data.CurrentPoint(1));
        y_2 = handles.Data.mainAxesMaxY;        

        handles.Data.hSelection =...
            patch([x_1 x_2 x_2 x_1],...
                  [y_1 y_1 y_2 y_2],...
                  [0 0.75 0],...
                  'Parent', handles.MainAxes);

        uistack(handles.Data.hSelection, 'bottom');        

        % Record the selection info...
        handles.Data.Selection = [x_1, x_2];        
        handles.Data.isselectionplotted = true;                                               

    end            

    %
    % Plot selected topic data...
    %
    if handles.Data.updateplots                

        if ~isempty(handles.Data.TopicMap)

            topicKeyArray = handles.Data.TopicMap.keys;

            % Loop through each selected checked sub-topic as listed in the
            % topic hash table...
            for iKey = 1:length(topicKeyArray)

                if handles.Data.TopicMap(topicKeyArray{iKey}).isPlotted

                    TempStruct = handles.Data.TopicMap(topicKeyArray{iKey});

                    % Plot the selected data...
                    TempStruct.hTopicPlot =...
                        plot(handles.MainAxes, handles.Data.TopicMap(topicKeyArray{iKey}).dataArray,...
                             'Color', handles.Data.TopicMap(topicKeyArray{iKey}).plotColour,...
                             'LineWidth', 2);

                    % Find and set new axes limits...
                    handles.Data.mainAxesMaxX =...
                        max(handles.Data.mainAxesMaxX,...
                            size(handles.Data.TopicMap(topicKeyArray{iKey}).dataArray, 2));
                    handles.Data.mainAxesMinY =...
                        min(handles.Data.mainAxesMinY,...
                            min(handles.Data.TopicMap(topicKeyArray{iKey}).dataArray));
                    handles.Data.mainAxesMaxY =...
                        max(handles.Data.mainAxesMaxY,...
                            max(handles.Data.TopicMap(topicKeyArray{iKey}).dataArray));

                    axis(handles.MainAxes,...
                         [0 handles.Data.mainAxesMaxX...
                          handles.Data.mainAxesMinY handles.Data.mainAxesMaxY]);

                    % axis tight;

                    % hold on;

                    handles.Data.TopicMap(topicKeyArray{iKey}) = TempStruct;

                else

                    % TempStruct = handles.Data.TopicMap(topicKeyArray{iKey});

                    % delete(TempStruct.hTopicPlot);
                    % TempStruct.hTopicPlot = [];

                    if isgraphics(handles.Data.TopicMap(topicKeyArray{iKey}).hTopicPlot)                        
                        delete(handles.Data.TopicMap(topicKeyArray{iKey}).hTopicPlot);
                    end

                    % axis tight;

                    % handles.Data.TopicMap(topicKeyArray{iKey}) = TempStruct;

                end

            end

        end

        handles.Data.updateplots = false;                                

    end


    %
    % Plot a blue vertical timestep tracking line...
    %
    if handles.Data.LastLeftButtonState == handles.Data.LeftButtonStates.UP &&...
       handles.Data.CurrentLeftButtonState == handles.Data.LeftButtonStates.DOWN      

        % fprintf('DEBUG: Plotting a blue vertical timestep tracking line...\n');

        if handles.Data.isselectionplotted && ishandle(handles.Data.hSelection)
            delete(handles.Data.hSelection);
            handles.Data.isselectionplotted = false;
        end

        if handles.Data.istrackinglineplotted
            delete(handles.Data.hTrackingLine);
            handles.Data.istrackinglineplotted = false;
        end

        x_1 = round(handles.Data.DownPoint(1));

        handles.Data.hTrackingLine =...
            plot(handles.MainAxes,...
                 [x_1, x_1],...
                 [handles.Data.mainAxesMinY,...
                  handles.Data.mainAxesMaxY],...
                 'Color', [0 0 1]);                         

        handles.Data.istrackinglineplotted = true;        
    end

    % drawnow;

    % Update handles structure
    guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updatecameraimage 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hObject, eventdata, handles] = updatecameraimage(hObject, eventdata, handles)

    %
    % Read and plot the camera image...
    %
    % It uses BGR8 encoding.
    %     

    % Search for the right frame in the topic based on current timestep.
    iRGBTopicFrame = 0;
    for iFrame = 1:size(handles.Data.ADTBagMeta{handles.Data.iRGBTopic}, 2)
        if handles.Data.ADTBagMeta{handles.Data.iRGBTopic}{iFrame}.time.time >=...
            handles.Data.currenttimestep....
                && ~iRGBTopicFrame
            iRGBTopicFrame = iFrame;  
            break;
        end       
    end

    Msg = handles.Data.ADTBagMsg{handles.Data.iRGBTopic}{iRGBTopicFrame};
    Meta = handles.Data.ADTBagMeta{handles.Data.iRGBTopic}{iRGBTopicFrame};
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
    % figure(handles.hImage);
    imshow(Image, 'Parent', handles.hImageAxes);
    % drawnow;

    % Update handles structure
    guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updatedepthimage 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hObject, eventdata, handles] = updatedepthimage(hObject, eventdata, handles)

    %
    % Read and plot the depth image...
    %
    % It uses 16UC1 encoding.
    %    

    % Search for the right frame in the topic based on current timestep.
    iDepthTopicFrame = 0;
    for iFrame = 1:size(handles.Data.ADTBagMeta{handles.Data.iDepthTopic}, 2)
        if handles.Data.ADTBagMeta{handles.Data.iDepthTopic}{iFrame}.time.time >=...
            handles.Data.currenttimestep....
                && ~iDepthTopicFrame
            iDepthTopicFrame = iFrame;  
            break;
        end       
    end

    Msg = handles.Data.ADTBagMsg{handles.Data.iDepthTopic}{iDepthTopicFrame};
    Meta = handles.Data.ADTBagMeta{handles.Data.iDepthTopic}{iDepthTopicFrame};
    % DepthIndices = 1 : 2 : (Msg{1}.width * Msg{1}.height * 2);
    % DepthImage = reshape(Msg{1}.data(DepthIndices), Msg{1}.width, Msg{1}.height);
    DepthImage = reshape(typecast(Msg.data,'uint16'), Msg.width, Msg.height);
    DepthImage = flipdim(DepthImage, 2);
    DepthImage = imrotate(DepthImage, 90);
    % figure(handles.hDepthImage);
    imagesc(DepthImage, 'Parent', handles.hDepthImageAxes);
    % drawnow;

    % Update handles structure
    guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% updatesecpanel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles)

    % Delete previous SEC panel radio buttons...
    if ~isempty(handles.Data.SECButtons)
        delete(handles.Data.SECButtons);
    else
        SECButtons = get(handles.SECPanel, 'Children');
        delete(SECButtons)
    end

    set(handles.SECPanel, 'Units', 'Pixels');
    SECPanelPos = get(handles.SECPanel, 'Position');

    % Add SEC radio buttons to panel...
    for iRow = 1:size(get(handles.SECLink_Topic_ListBox, 'String'),1)        
        if ~isempty(handles.Data.hActionChunks)            
            for iCol = 1:size(handles.Data.hActionChunks,2)+1

                handles.Data.SECButtons(iRow, iCol) =...
                    uicontrol(handles.SECPanel,...
                              'style','checkbox',...
                              'unit','pix',...
                              'position',[iCol*20, (SECPanelPos(4)-40) - ((iRow-1) * 16), 15, 15,]);

            end
        end
    end

    % Update handles structure
    guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = adteditor_GUIDE_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);YData = get(handles.Data.hSelection, 'YData')
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

    handles.Data.iCurrentFrame = handles.Data.iCurrentFrame + 100;

    [hObject, eventdata, handles] = updatemainplot(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on selection of New Action Chunk context menu item.
function NewActionChunk_Callback(hObject, eventdata, handles)

    if handles.Data.isselectionplotted

        % Grab new action chunk info...
        XData = get(handles.Data.hSelection, 'XData');
        YData = get(handles.Data.hSelection, 'YData');

        % Delete green selection box...
        delete(handles.Data.hSelection);
        handles.Data.isselectionplotted = false;

        % Draw a blue action chunk...
        handles.Data.hActionChunks{end+1} =...
            patch(XData,...
                  YData,...
                  [0 0 0.75],...                 
                  'Parent', handles.MainAxes);

        XData = sort(XData(1:2));

        % Draw a text box...
        handles.Data.hActionChunksText{end+1} =...
            text(XData(1) + abs((XData(2) - XData(1))/2),...
                 YData(1) + abs((YData(1) - YData(3))/2),...
                 ['Action Chunk ' num2str(size(handles.Data.hActionChunks, 2))],...
                 'color', 'w',...
                 'BackgroundColor', [0 0 0.75],...
                 'HorizontalAlignment','center',...
                 'editing', 'on');

        settexttoediting = @(~, ~) set(handles.Data.hActionChunksText{end}, 'editing', 'on');
        set(handles.Data.hActionChunksText{end}, 'buttondownfcn', settexttoediting);                

        % Send the blue action chunk to the bottom of the draw stack...
        uistack(handles.Data.hActionChunks{end}, 'bottom');      

        % Send the action chunk text to the top of the draw stack...
        uistack(handles.Data.hActionChunksText{end}, 'top');

        % Create a new action chunk...
        % handles.Data.ActionChunks{end+1}.iStartFrame = handles.

        % Update handles structure
        guidata(hObject, handles);

        % Attach a context menu...        
        set(handles.Data.hActionChunks{end}, 'uicontextMenu', handles.Data.hActionChunkContextMenu);
        set(handles.Data.hActionChunkContextMenuItems(1),'callback',...
            {@DeleteActionChunk_Callback, guidata(hObject), size(handles.Data.hActionChunks,2)});

        % Update handles structure
        guidata(hObject, handles);                              

        % Update the SEC button panel...
        [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles);

    end

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on selection of New Action Chunk context menu item.
function DeleteActionChunk_Callback(hObject, eventdata, handles, iActionChunk)

    % Delete the action chunk...
    delete(handles.Data.hActionChunks{iActionChunk});
    handles.Data.hActionChunks(iActionChunk) = [];

    % Delete the action chunk text...
    delete(handles.Data.hActionChunksText{iActionChunk});
    handles.Data.hActionChunksText(iActionChunk) = [];

    % Update handles structure
    guidata(hObject, handles);

    % Update the SEC button panel...
    [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% findtopic 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function index = findtopic(TopicNames, Topic, varargin)

    % Defaults
    cmpfunc = @strcmp;
    reverse = false;

    if nargin
        switch lower(varargin{1})
            case {'revfuzzy', 'revstrfind'}
                cmpfunc = @strfind;
                reverse = true;
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

        if ~reverse
            if cmpfunc(TopicNames{index}, Topic)
                found = true;
                break;
            end
        else
            if cmpfunc(Topic, TopicNames{index})
                found = true;
                break;
            end
        end

        if ~found
            index = 0;
        end

    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checkedIcon 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,map] = checkedIcon()
    I = uint8(...
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0;
         2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1;
         2,2,2,2,2,2,2,2,2,2,2,2,0,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,0,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,0,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,0,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,0,0,1,1,2,2,3,1;
         2,2,1,0,0,1,1,0,0,1,1,1,2,2,3,1;
         2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
         2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
         2,2,1,1,1,0,0,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,0,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
         1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
    map = [0.023529,0.4902,0;
           1,1,1;
           0,0,0;
           0.50196,0.50196,0.50196;
           0.50196,0.50196,0.50196;
           0,0,0;
           0,0,0;
           0,0,0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% uncheckedIcon 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [I,map] = uncheckedIcon()
    I = uint8(...
        [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
         2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
         1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
    map = ...
        [0.023529,0.4902,0;
         1,1,1;
         0,0,0;
         0.50196,0.50196,0.50196;
         0.50196,0.50196,0.50196;
         0,0,0;
         0,0,0;
         0,0,0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% deletefigures 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deletefigures(hObject, eventdata, handles)

    if isfield(handles, 'hDepthImageFig')
        delete(handles.hImageFig);
    end
    
    if isfield(handles, 'hDepthImageFig')
        delete(handles.hDepthImageFig); 
    end


% --- Executes on mouse press over axes background.
function MainAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to MainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Set flags...
    handles.Data.LastLeftButtonState = handles.Data.CurrentLeftButtonState;
    handles.Data.CurrentLeftButtonState = handles.Data.LeftButtonStates.DOWN;

    % fprintf('DOWN: LastLeftButtonState = %d, CurrentLeftButtonState = %d\n',...
    %         handles.Data.LastLeftButtonState,...
    %         handles.Data.CurrentLeftButtonState);

    % Get mouse click location...
    handles.Data.DownPoint = get(handles.MainAxes,'currentpoint');

    % Update current frame from click location and time step from bag...    
    handles.Data.iDownFrame = round(handles.Data.DownPoint(1,1));    
    % handles.Data.currenttimestep =...
    %     handles.Data.ADTBagMeta{handles.Data.iTimingTopic}{handles.Data.iCurrentFrame}.time.time;

    [hObject, eventdata, handles] = updatemainplot(hObject, eventdata, handles);

    % Set the button-motion callback...
    set(handles.MainFig, 'WindowButtonMotionFcn',...
        @(hObject,eventdata)adteditor_GUIDE('MainFig_ButtonMotionFcn',hObject,eventdata,guidata(hObject)));        

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on mouse button-press motion over axes background.
function MainFig_ButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to MainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Set flags...
    handles.Data.LastLeftButtonState = handles.Data.CurrentLeftButtonState;
    handles.Data.CurrentLeftButtonState = handles.Data.LeftButtonStates.INMOTION;

    % fprintf('MOTION: LastLeftButtonState = %d, CurrentLeftButtonState = %d\n',...
    %         handles.Data.LastLeftButtonState,...
    %         handles.Data.CurrentLeftButtonState);    

    % Get mouse click location...
    handles.Data.CurrentPoint = get(handles.MainAxes, 'currentpoint');    

    % Update current frame from click location and time step from bag...
    % handles.Data.iCurrentFrame = round(handles.Data.CurrentPoint(1,1));

    % if handles.Data.iCurrentFrame <= size(handles.Data.ADTBagMeta{handles.Data.iTimingTopic},2) &&...
    %    handles.Data.iCurrentFrame >= 1
    %     handles.Data.currenttimestep =...
    %         handles.Data.ADTBagMeta{handles.Data.iTimingTopic}{handles.Data.iCurrentFrame}.time.time;   
    % end

    [hObject, eventdata, handles] = updatemainplot(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);    


% --- Executes on mouse release over axes background.
function MainFig_ButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to MainAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


    % if handles.Data.LastLeftButtonState == handles.Data.LeftButtonStates.INMOTION                

        % fprintf('UP: LastLeftButtonState = %d, CurrentLeftButtonState = %d\n',...
        %         handles.Data.LastLeftButtonState,...
        %         handles.Data.CurrentLeftButtonState);

        % Get mouse click location...
        handles.Data.CurrentPoint = get(handles.MainAxes, 'currentpoint');      

        % Update current frame from click location and time step from bag...
        handles.Data.iCurrentFrame = round(handles.Data.CurrentPoint(1,1));

        % Make sure we're not out of bounds (the mouse is a tricky beast!)
        if handles.Data.iCurrentFrame <= size(handles.Data.ADTBagMeta{handles.Data.iTimingTopic},2)

            handles.Data.currenttimestep =...
                handles.Data.ADTBagMeta{handles.Data.iTimingTopic}{handles.Data.iCurrentFrame}.time.time;

            if handles.Data.iRGBTopic ~= 0
                [hObject, eventdata, handles] = updatecameraimage(hObject, eventdata, handles);    
            end

            if handles.Data.iDepthTopic ~= 0
                [hObject, eventdata, handles] = updatedepthimage(hObject, eventdata, handles);    
            end

        end

        % Unset button-motion callback...
        set(handles.MainFig, 'WindowButtonMotionFcn', '');               

    % end

    %
    % If a selection box has been plotted, attach the context menu after
    % updating the handles structure...
    %
    if handles.Data.isselectionplotted && ishandle(handles.Data.hSelection)
        set(handles.Data.hSelection, 'uicontextMenu', handles.Data.hSelectionContextMenu);
        set(handles.Data.hSelectionContextMenuItems(1),'callback', {@NewActionChunk_Callback, guidata(hObject)});        
    end

    % Set flags...
    handles.Data.LastLeftButtonState = handles.Data.CurrentLeftButtonState;
    handles.Data.CurrentLeftButtonState = handles.Data.LeftButtonStates.UP;

    % Update handles structure
    guidata(hObject, handles);



% --- Executes on button press in generatexmlbutton.
function generatexmlbutton_Callback(hObject, eventdata, handles)
% hObject    handle to generatexmlbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hint: get(hObject,'Value') returns toggle state of generatexmlbutton  

    % Build action chunks cell array for adttool...
    for iChunk = 1:size(handles.Data.hActionChunks,2)

        XData = get(handles.Data.hActionChunks{iChunk}, 'XData');
        XData = sort(XData(1:2));        

        handles.Data.ActionChunks{iChunk}{1} = XData(1);
        handles.Data.ActionChunks{iChunk}{2} = XData(2);

    end

    % Build SECLink arg string...
    SECLinkTopics = get(handles.SECLink_Topic_ListBox, 'string');
    SECLinkFirstObjs = get(handles.SECLink_FirstObj_ListBox, 'string');
    SECLinkSecondObjs = get(handles.SECLink_SecondObj_ListBox, 'string');

    % TestString = '''seclink'', [], ''hand'', ''main-object'''

    SECLinkArgString = [];
    for iSECLink = 1:size(SECLinkTopics,1)
        SECLinkArgString = [SECLinkArgString 'seclink '];

        if strcmp(SECLinkTopics{iSECLink}, 'None')
            SECLinkArgString = [SECLinkArgString '[] '];
        else
            SECLinkArgString = [SECLinkArgString ' ' SECLinkTopics{iSECLink} ' '];
        end

        SECLinkArgString = [SECLinkArgString ' ' SECLinkFirstObjs{iSECLink} ' '];
        SECLinkArgString = [SECLinkArgString ' ' SECLinkSecondObjs{iSECLink} ' '];
    end
    % SECLinkArgString(end-1:end) = [];
    SECLinkArgs = strread(SECLinkArgString, '%s');

    handles.Data.XML = adttool({handles.Data.ADTBag, handles.Data.ADTBagMeta, handles.Data.ADTBagMsg},...
                               'xml', handles.Data.XMLFileName,...
                               SECLinkArgs{:},...
                               'actionchunks', handles.Data.ActionChunks);                           

    % Update handles structure
    guidata(hObject, handles);

% --- Executes on selection change in SECLink_Topic_ListBox.
function SECLink_Topic_ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_Topic_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns SECLink_Topic_ListBox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from SECLink_Topic_ListBox

    % Set the other two list boxes to the same value...
    iValue = get(handles.SECLink_Topic_ListBox, 'value');
    set(handles.SECLink_FirstObj_ListBox, 'value', iValue);
    set(handles.SECLink_SecondObj_ListBox, 'value', iValue);

    % Update handles structure
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SECLink_Topic_ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_Topic_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on selection change in SECLink_FirstObj_ListBox.
function SECLink_FirstObj_ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_FirstObj_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns SECLink_FirstObj_ListBox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from SECLink_FirstObj_ListBox

    % Set the other two list boxes to the same value...
    iValue = get(handles.SECLink_FirstObj_ListBox, 'value');
    set(handles.SECLink_Topic_ListBox, 'value', iValue);
    set(handles.SECLink_SecondObj_ListBox, 'value', iValue);

    % Update handles structure
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SECLink_FirstObj_ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_FirstObj_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on selection change in SECLink_SecondObj_ListBox.
function SECLink_SecondObj_ListBox_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_SecondObj_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns SECLink_SecondObj_ListBox contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from SECLink_SecondObj_ListBox

    % Set the other two list boxes to the same value...
    iValue = get(handles.SECLink_SecondObj_ListBox, 'value');
    set(handles.SECLink_Topic_ListBox, 'value', iValue);
    set(handles.SECLink_FirstObj_ListBox, 'value', iValue);

    % Update handles structure
    guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SECLink_SecondObj_ListBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_SecondObj_ListBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % Update handles structure
    guidata(hObject, handles);



% --- Executes on selection change in SECLink_Topic_DropDown.
function SECLink_Topic_DropDown_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_Topic_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: contents = cellstr(get(hObject,'String')) returns SECLink_Topic_DropDown contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from SECLink_Topic_DropDown



    % Update handles structure
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SECLink_Topic_DropDown_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_Topic_DropDown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: popupmenu controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



    % Update handles structure
    guidata(hObject, handles);


function SECLink_FirstObj_TextBox_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_FirstObj_TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of SECLink_FirstObj_TextBox as text
    %        str2double(get(hObject,'String')) returns contents of SECLink_FirstObj_TextBox as a double

    % Update handles structure
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SECLink_FirstObj_TextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_FirstObj_TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % Update handles structure
    guidata(hObject, handles);


function SECLink_SecondObj_TextBox_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_SecondObj_TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Hints: get(hObject,'String') returns contents of SECLink_SecondObj_TextBox as text
    %        str2double(get(hObject,'String')) returns contents of SECLink_SecondObj_TextBox as a double

    % Update handles structure
    guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SECLink_SecondObj_TextBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECLink_SecondObj_TextBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in SECLink_Add_Button.
function SECLink_Add_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_Add_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Topic listbox...
    Foo = get(handles.SECLink_Topic_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    Bar = get(handles.SECLink_Topic_DropDown, {'string', 'value'});    
    Values{end+1} = Bar{1}{Bar{2}};
    set(handles.SECLink_Topic_ListBox, 'string', Values, 'value', iValue+1);

    % First object listbox...
    Foo = get(handles.SECLink_FirstObj_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    Bar = get(handles.SECLink_FirstObj_TextBox, {'string', 'value'});    
    Values{end+1} = Bar{1};
    set(handles.SECLink_FirstObj_ListBox, 'string', Values, 'value', iValue+1);

    % Second object listbox...
    Foo = get(handles.SECLink_SecondObj_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    Bar = get(handles.SECLink_SecondObj_TextBox, {'string', 'value'});    
    Values{end+1} = Bar{1};
    set(handles.SECLink_SecondObj_ListBox, 'string', Values, 'value', iValue+1);        

    % Update the SEC button panel...
    [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);


% --- Executes on button press in SECLink_Delete_Button.
function SECLink_Delete_Button_Callback(hObject, eventdata, handles)
% hObject    handle to SECLink_Delete_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Topic listbox...
    Foo = get(handles.SECLink_Topic_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    if ~isempty(Values)
        Values(iValue) = [];
        set(handles.SECLink_Topic_ListBox, 'string', Values, 'value', iValue-1);
    end

    % First object listbox...
    Foo = get(handles.SECLink_FirstObj_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    if ~isempty(Values)
        Values(iValue) = [];
        set(handles.SECLink_FirstObj_ListBox, 'string', Values, 'value', iValue-1);
    end

    % Second object listbox...
    Foo = get(handles.SECLink_SecondObj_ListBox, {'string', 'value'});
    Values = Foo{1};
    iValue = Foo{2};
    if ~isempty(Values)
        Values(iValue) = [];
        set(handles.SECLink_SecondObj_ListBox, 'string', Values, 'value', iValue-1);
    end

    % Update the SEC button panel...
    [hObject, eventdata, handles] = updatesecpanel(hObject, eventdata, handles);

    % Update handles structure
    guidata(hObject, handles);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function SaveMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Pull up a file selection menu...
    if isempty(handles.Data.XMLFileName)        

        [XMLFileName,PathName,FilterIndex] =...
            uiputfile({'*.xml'; '*.txt'}, 'Export ADT XML', 'output.xml');

        if XMLFileName ~= 0
            handles.Data.XMLFileName = fullfile(PathName, XMLFileName);
        end
    end

    % ...and if we get a valid filename, try to generate and SaveMenuItem the XML.
    if ~isempty(handles.Data.XMLFileName)

        % Build action chunks cell array for adttool...
        for iChunk = 1:size(handles.Data.hActionChunks,2)

            XData = get(handles.Data.hActionChunks{iChunk}, 'XData');
            XData = sort(XData(1:2));        

            handles.Data.ActionChunks{iChunk}{1} = XData(1);
            handles.Data.ActionChunks{iChunk}{2} = XData(2);

        end

        % Build action chunk descriptions cell array...
        for iChunk = 1:size(handles.Data.hActionChunksText,2)
            handles.Data.ActionChunkNames{iChunk} = get(handles.Data.hActionChunksText{iChunk}, 'String');
        end

        % Build SECLink arg string...
        SECLinkTopics = get(handles.SECLink_Topic_ListBox, 'string');
        SECLinkFirstObjs = get(handles.SECLink_FirstObj_ListBox, 'string');
        SECLinkSecondObjs = get(handles.SECLink_SecondObj_ListBox, 'string');

        SECLinkArgString = [];
        for iSECLink = 1:size(SECLinkTopics,1)
            SECLinkArgString = [SECLinkArgString 'seclink '];

            if strcmp(SECLinkTopics{iSECLink}, 'None')
                SECLinkArgString = [SECLinkArgString '[] '];
            else
                SECLinkArgString = [SECLinkArgString ' ' SECLinkTopics{iSECLink} ' '];
            end

            SECLinkArgString = [SECLinkArgString ' ' SECLinkFirstObjs{iSECLink} ' '];
            SECLinkArgString = [SECLinkArgString ' ' SECLinkSecondObjs{iSECLink} ' '];
        end
        % SECLinkArgString(end-1:end) = [];
        SECLinkArgs = strread(SECLinkArgString, '%s');

        % Build ObjLink arg string for hand-act...
        HandActObjLinkArgs = [];
        HandActTopicLinkString = get(handles.hand_act_topic_link_textbox, 'String');

        if ~isempty(HandActTopicLinkString)

            % Reomve 'root' from the beginning if necessary...
            if strcmp(HandActTopicLinkString(1:4), 'root') ~= 0
                HandActTopicLinkString = HandActTopicLinkString(5:end);
            end

            % Find the name of the hand object in SECLinks...
            Objects = unique({SECLinkFirstObjs{:} SECLinkSecondObjs{:}});
            iHandObject = 0;
            for iObject = 1:size(Objects,2)
                % Assume it's the first one we find...
                if ~isempty(findstr(Objects{iObject}, 'hand'))
                    iHandObject = iObject;
                    break;
                end
            end

            % There should be a default...
            if iHandObject == 0
                HandObject = 'hand'
            else
                HandObject = Objects{iHandObject};
            end

            % Build the arg string...
            HandActObjLinkArgString =...
                ['objlink ' HandActTopicLinkString ' [] ' HandObject];

            HandActObjLinkArgs = strread(HandActObjLinkArgString, '%s');

        end

        % Build SEC args...
        if ~isempty(handles.Data.SECButtons)
            for iRow = 1:size(handles.Data.SECButtons,1)
                for iCol = 1:size(handles.Data.SECButtons,2)
                    SEC(iRow, iCol) = get(handles.Data.SECButtons(iRow,iCol), 'Value');
                end
            end
        end

        % Build up argument list...
        Args = {'xml', handles.Data.XMLFileName};

        if ~isempty(SECLinkArgs)
            Args = {Args{:} SECLinkArgs{:}};
        end

        if ~isempty(HandActObjLinkArgs)
            Args = {Args{:} HandActObjLinkArgs{:}};
        end

        if ~isempty(handles.Data.ActionChunks)
            Args = {Args{:} 'actionchunks' handles.Data.ActionChunks};
        end

        if ~isempty(handles.Data.ActionChunkNames)
            Args = {Args{:} 'actionchunknames' handles.Data.ActionChunkNames};
        end

        if ~isempty(handles.Data.SECButtons)
            Args = {Args{:} 'SEC' SEC};
        end

        % Pass everything to adttool...
        handles.Data.XML = adttool({handles.Data.ADTBag, handles.Data.ADTBagMeta, handles.Data.ADTBagMsg},...
                                   Args{:});       

    end

    % Update handles structure
    guidata(hObject, handles);



% --------------------------------------------------------------------
function SaveAsMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAsMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Clear the XML file name...
    handles.Data.XMLFileName = [];

    % Update handles structure
    guidata(hObject, handles);

    % Call the original save menu item callback, which will now re-trigger
    % the file selection dialogue...
    SaveMenuItem_Callback(hObject, eventdata, handles);       


% --- Executes during object creation, after setting all properties.
function SECPanel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SECPanel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called    


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [FileName,PathName,FilterIndex] =...
            uigetfile({'*.xml'; '*.txt'; '*.bag'}, 'Open ADT XML file or ROS bag file');

    handles.Data.fileinputspecified = true;

    % Update handles structure
    guidata(hObject, handles);

    adteditor_GUIDE_OpeningFcn(hObject, eventdata, handles, fullfile(PathName, FileName));


% --- Executes on button press in hand_act_topic_link_toggle.
function hand_act_topic_link_toggle_Callback(hObject, eventdata, handles)
% hObject    handle to hand_act_topic_link_toggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hand_act_topic_link_toggle

    % Invert the flag...
    % handles.Data.isgrabbinghandacttopic = get(hObject, 'Value');

    % Update handles structure
    % guidata(hObject, handles);        


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
