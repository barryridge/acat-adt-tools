function varargout = adtgenerator(varargin)
% 
% adtgenerator
%
% Generates new, or populates existing, ADT XML files using rosbag
% recordings.
%
% ACAT Project
% http://www.acat-project.eu/
% Author: Barry Ridge, JSI
% Date: 22nd Oct 2014
%

    %% Defaults...
    DirName = [];
    BagFileName = [];
    XMLFileName = [];
    ADTBag = [];
    XML = [];

    % Check arguments...
    if nargin == 1        
        if isdir(varargin{1})                        
            
            % Get the directory name...
            [Pathstr, Name, Ext] = fileparts(varargin{1});
            DirName = [Pathstr '/' Name];
            
            % Find the bag file...                        
            BagFileNames = dir([DirName '/*.bag']);            
            if size(BagFileNames,1) >= 1
                % We just assume it's the first in the list.
                BagFileName = BagFileNames(1).name;
            end
            
            % Find the xml file...
            % We just assume it's the first in the list.
            XMLFileNames = dir([DirName '/ADT*.xml']);
            if size(XMLFileNames,1) >= 1
                % We just assume it's the first in the list.
                XMLFileName = XMLFileNames(1).name;
            end
            
        else
           %
            % TODO: Input handling non-dir single argument.
            % 
        end
    elseif nargin == 2
        %
        % TODO: Input handling for two arguments.
        % 
    end
    
    
    %% Load rosbag file...
    fprintf('\nLoading rosbag file.  Please wait, this can take a while.');
    ADTBag = Bag.load([DirName '/' BagFileName]);
    
    % Print progress dots...
    fprintf('.');

    % Parse info from the rosbag...
    Info = ADTBag.info();
    TopicStrings = strsplit(Info(findstr(Info, 'topics:'):end), '\n');

    topiccounter = 1;
    for iTopic = 1:length(TopicStrings)            

        TopicInfo = strsplit(TopicStrings{iTopic});

        if length(TopicInfo) >= 6
            TopicNames{topiccounter} = TopicInfo{2};
            TopicSizes{topiccounter} = str2num(TopicInfo{3});
            TopicTypes{topiccounter} = TopicInfo{6};
        end

        topiccounter = topiccounter + 1;
    end
    
    % Read all data in each topic separately...
    for iTopic = 1:length(TopicNames)        
       
        [Msg{iTopic} Meta{iTopic}] = ADTBag.readAll({TopicNames{iTopic}});
        
        % Print progress dots...
        fprintf('.');
    end
    
    fprintf('finished!\n');
    
    
    %% Load xml file...
    if ~isempty(XMLFileName)
              
        % NOTE: I have tried a number of different methods
        % for parsing, reading, and writing the XML,
        % and xml_io_tools, of which xml_read and xml_write
        % are functions, was the best I could find
        % for those requirements.
        % (http://www.mathworks.com/matlabcentral/fileexchange/12907-xml-io-tools)
        %
        % The parseXML functions provided in the
        % Matlab XML documentation (though not in the codebase!),
        % do an okay job of parsing XML, but the task of how to writing it
        % back to file appears to be non-trivial and left as a exercise
        % for the reader of said documentation.
        % (http://www.mathworks.com/help/matlab/ref/xmlread.html)
        %
        % xml2struct, on the other hand, appeared not to do
        % a full deep parsing of the XML, and thus turned out
        % to be useless.
        % (http://www.mathworks.com/matlabcentral/fileexchange/28518-xml2struct)
        %
        % I mention them here for posterity.       
        try
            fprintf('Reading ADT XML file...');
            [XML XMLRootName XMLDOMNode] = xml_read([DirName '/' XMLFileName]);
            fprintf('finished!\n');
            
        catch XMLReadException
            
            error('XML file reading error from xml_io_tools, xml_read()');            
            rethrow(XMLReadException);
        end
        
    else        
                
        % Generate XML boilerplate for ADT.
        fprintf('No ADT XML file found.\n');
        fprintf('Generating ADT XML...');
        [~, XMLFileName, ~] = fileparts(BagFileName);
        XMLFileName = ['ADT_' XMLFileName '.xml'];
                
        % Actual XML starts here...        
        XMLRootName = 'action_DASH_primitive';
        
        XML.instruction.COMMENT = 'Instruction of an action';
        XML.instruction.CONTENT = 'ADT instruction text';
        
        XML.action_DASH_context.COMMENT = 'Description of the instruction in more detail';
        XML.action_DASH_context.CONTENT = 'ADT context text';
        
        XML.name.COMMENT = 'Name of the action (e.g., PickAndPlace, Push, Unscrew, Open, Close, etc.)';
        XML.name.CONTENT = 'ADT name';
        
        XML.refframe.COMMENT = 'Reference frame of the  setup. We describe everything with respect to robot base frame. Robot based is 0,0,0 (x,y,z)';
        XML.refframe.CONTENT = 'ADT reference frame';
        
        % Main object
        %
        % NOTE: How much of this boilerplate is really necessary for a
        % first-time ADT?
        %
        XML.main_DASH_object.name.COMMENT = 'Name of the object';
        XML.main_DASH_object.name.CONTENT = 'Main object name';
        XML.main_DASH_object.cad_DASH_model.COMMENT = 'Model/models of the object, can have formats 3ds, obj, stl, pcd';
        XML.main_DASH_object.cad_DASH_model.uri.COMMENT = 'Point cloud model of the object';
        XML.main_DASH_object.cad_DASH_model.uri.CONTENT = {'xxx.3ds' 'xxx.obj' 'xxx.stl' 'xxx.pcd'};
        XML.main_DASH_object.part_DASH_graph.COMMENT = 'Part-graph of the object';
        XML.main_DASH_object.part_DASH_graph.uri.COMMENT = ' (labelled point cloud) ';
        XML.main_DASH_object.part_DASH_graph.uri.CONTENT = 'xxx.pcd';
        XML.main_DASH_object.potential_DASH_objects.COMMENT =...
            ['In the following we describe all potential objects. '...
            'E.g, if we are interested in a jar we need to describe '... 
            'all the jars which are present in the scene'];
        XML.main_DASH_object.potential_DASH_objects.object.pose.position.COMMENT = 'x,y,z in meters';
        XML.main_DASH_object.potential_DASH_objects.object.pose.position.CONTENT = 'xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.pose.quaternion.COMMENT = 'x y z (imaginary part)  and w (real part)';
        XML.main_DASH_object.potential_DASH_objects.object.pose.quaternion.CONTENT = 'xxx xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.pose.pose_DASH_reliability.COMMENT = 'value of pose reliability from 0 to 1';
        XML.main_DASH_object.potential_DASH_objects.object.pose.pose_DASH_reliability.CONTENT = 'xxx';
        XML.main_DASH_object.potential_DASH_objects.object.part_DASH_of0x2Dinterest.COMMENT =...
            'Here we define part of interest. E.g., if we were interested in taking lid off a jar we would specify here "Lid"';
        XML.main_DASH_object.potential_DASH_objects.object.part_DASH_of0x2Dinterest.CONTENT = 'void';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.COMMENT =...
            'Description of object parts if any, otherwise "void"';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).name.CONTENT = 'xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.position.COMMENT = 'x,y,z in meters';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.position.CONTENT = 'xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.quaternion.COMMENT = 'x y z (imaginary part)  and w (real part)';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.quaternion.CONTENT = 'xxx xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.pose_DASH_reliability.COMMENT = 'value of pose reliability from 0 to 1';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(1).pose.pose_DASH_reliability.CONTENT = 'xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).name.CONTENT = 'xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.position.COMMENT = 'x,y,z in meters';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.position.CONTENT = 'xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.quaternion.COMMENT = 'x y z (imaginary part)  and w (real part)';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.quaternion.CONTENT = 'xxx xxx xxx xxx';
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.pose_DASH_reliability.COMMENT = 'value of pose reliability from 0 to 1';        
        XML.main_DASH_object.potential_DASH_objects.object.object_DASH_parts.part(2).pose.pose_DASH_reliability.CONTENT = 'xxx';

        %
        % NOTE: We leave these next entries empty since, according to the specs,
        % they are not always present.
        %
        
        % Primary object        
        XML.primary_DASH_object = [];
        
        % Secondary object        
        XML.secondary_DASH_object = [];
        
        % Main support plain        
        XML.main_support_plane = [];
        
        % Primary support plain        
        XML.primary_support_plane = [];
        
        % Secondary support plain
        XML.secondary_support_plain = [];
        
        % Tool
        XML.tool = [];
        
        % Wrist-to-TCP-transform
        % (don't worry about the weird UTF codes... should come out
        % ok in the XML file)        
        XML.wrist_DASH_to0x2DTCP0x2Dtransform.COMMENT = 'Transformation with respect to the hand';
        % XML.wrist_DASH_to0x2DTCP0x2Dtransform.pose.position;
        % XML.wrist_DASH_to0x2DTCP0x2Dtransform.pose.COMMENT = 
        
        
        
        % Action chunks
        XML.action_DASH_chunks = [];
        
        %
        % TODO: Finish this section!
        %
        
        fprintf('finished!\n');        
        
    end
    
    
    %% Main XML processing loops...
    fprintf('Processing XML.');
    if isfield(XML, 'action_DASH_chunks')
        
        if isfield(XML.action_DASH_chunks, 'action_DASH_chunk')
            
            %
            % NOTE: Proof of concept, for the moment (24th Oct 2014).
            % We traverse each action_chunk(i).main_object_act field,
            % search for the start and end timestamps in the rosbag,
            % and modify the position, quaternion and pose_reliability
            % fields for each action_chunk by replacing 'xxx xxx xxx' placeholders
            % with numerical placeholders based on the relevant rosbag frame.
            % Object poses have not been included in rosbags recorded up
            % until now (24/10/14).  Work in progress.
            % 
            for iActionChunk = 1:size(XML.action_DASH_chunks.action_DASH_chunk,1)
                                                                
                %% Search for the start position timestamp in the rosbag.
                % We just use the first topic for now in the absence
                % of a main object pose topic.
                iTopic = 1;
                for iFrame = 1:size(Meta{iTopic}, 2)
                    % 
                    if Meta{1}{iFrame}.time.time >=...
                       XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.timestamp
                        iStartFrame = iFrame;
                        break;
                    end
                end                
                
                % Modify the position, quaternion and pose_reliability
                % fields.                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.position = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.position.CONTENT =...
                    [iStartFrame iStartFrame iStartFrame];
                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.quaternion = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.quaternion.CONTENT =...
                    [iStartFrame iStartFrame iStartFrame iStartFrame];
                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.pose_DASH_reliability = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.start_DASH_point.pose.pose_DASH_reliability.CONTENT =...
                    iStartFrame;
                
                % Print progress dots...
                fprintf('.');
                
                %% Search for the end position timestamp in the rosbag.
                % We just use the first topic for now in the absence
                % of a main object pose topic.
                iTopic = 1;
                for iFrame = 1:size(Meta{iTopic}, 2)
                    % 
                    if Meta{1}{iFrame}.time.time >=...
                       XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.timestamp
                        iEndFrame = iFrame;
                        break;
                    end
                end                
                
                % Modify the position, quaternion and pose_reliability
                % fields.                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.position = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.position.CONTENT =...
                    [iEndFrame iEndFrame iEndFrame];
                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.quaternion = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.quaternion.CONTENT =...
                    [iEndFrame iEndFrame iEndFrame iEndFrame];
                
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.pose_DASH_reliability = [];
                XML.action_DASH_chunks.action_DASH_chunk(iActionChunk).main_DASH_object0x2Dact.end_DASH_point.pose.pose_DASH_reliability.CONTENT =...
                    iEndFrame;
                
                % Print progress dots...
                fprintf('.');
            end
            
        else
            %
            % TODO: What happens if we have no action_chunk field entries?
            %
        end
        
        fprintf('finished!\n');
        
    else
        error(['The XML file ' XMLFileName ' does not appear to be formatted correctly.']);
    end
    
    
    %% Write xml file...
    if ~isempty(XMLFileName)
        
        try        
            fprintf('Writing ADT XML file...');
            Prefs.CellItem = false;
            Prefs.StructItem = false;
            xml_write([DirName '/' XMLFileName], XML, XMLRootName, Prefs);
            fprintf('finished!\n');
            
        catch XMLWriteException            
            error('XML file writing error from xml_io_tools, xml_write()');            
            rethrow(XMLWriteException);
        end
        
    else
        %
        % TODO: We should have an XML filename by this point...
        % 
    end

    