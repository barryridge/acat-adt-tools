function varargout = adttool(BagSpec, varargin)
% 
% adttool
%
% ACAT Project
% http://www.acat-project.eu/
% Author: Barry Ridge, JSI.
% E-mail: barry.ridge@ijs.si
% Last updated: 4th Nov 2014 (or check repository!)
% Repository: https://barryridge@bitbucket.org/barryridge/acat-adt-generator.git
% Please e-mail me for access.
%
% Description:              Generates new, or populates existing, ADT XML
%                           files using rosbag recordings.
%   
%
% Usage:                    [XMLOut] = adttool(BagSpec, Options)
%
% Input Arguments:
%       
%   BagSpec (required):     rosbag specification.  Filename or
%                           directory name of rosbag location,
%                           or a previously loaded rosbag object
%                           (matlab_rosbag format).
%                           If a directory is specificied, adttool
%                           searches for an XML file in the directory
%                           also.
%
%   Options (optional name/value pairs):
%
%       'XMLSpec', Value:   ADT XML input specification. Value should be
%                           XML filename or directory name of XML file
%                           location. If file does not exist, it is generated.
%                           If XMLSpec option is omitted, it defaults
%                           to BagSpec location.
%
%       'SECLink', Topic, FirstObj, SecondObj:
%                           
%                           Links a topic in the rosbag to the objects
%                           defined by FirstObj and SecondObj for
%                           SEC (semantic event chain) generation.
%                           If such SECLinks are defined, both SECs
%                           and action chunks can be automatically
%                           generated in the ADT XML.
%
% Output Arguments:
%
%       XMLOut:             An XML struct structured using xml_io_tools
%                           formatting.
%                               
% Prerequisite packages:    matlab_rosbag, xml_io_tools
%                           (see README.md and setpaths.m for further
%                           info)
%

    %% ---------
    % VARIABLES
    %-----------

    % File/directory variables...
    BagDirName = [];
    XMLDirName = [];
    BagFileName = [];
    XMLFileName = [];
    
    % rosbag variables...
    ADTBag = [];
    ADTBagMeta = [];
    ADTBagMsg = [];
    
    ADTBagInfo = [];
    ADTBagTopicInfo = [];
    ADTBagTopicNames = [];
    ADTBagTopicSizes = [];
    ADTBagTopicStrings = [];
    ADTBagTopicTypes = [];
    
    % XML variables...
    XML = [];    
    
    % SECs and action chunks...
    SECLinks = [];
    SEC = [];
    ADTBagActionChunkMeta = [];
    Objects = [];
    SECObjTab = [];
    
    
    %% -------------------------
    % INPUT ARGUMENT PROCESSING
    %---------------------------

    % Check BagSpec argument...
    if nargin >= 1        
        if ischar(BagSpec) && isdir(BagSpec)                        
            
            % Get the directory name...
            [Pathstr, Name, Ext] = fileparts(BagSpec);
            BagDirName = [Pathstr '/' Name];
            
            % Find the bag file...                        
            BagFileNames = dir([BagDirName '/*.bag']);            
            if size(BagFileNames,1) >= 1
                % We just assume it's the first in the list.
                BagFileName = BagFileNames(1).name;
            end
            
            % Find the xml file...
            % We just assume it's the first in the list.
            XMLDirName = BagDirName;
            XMLFileNames = dir([BagDirName '/ADT*.xml']);
            if size(XMLFileNames,1) >= 1
                % We just assume it's the first in the list.
                XMLFileName = XMLFileNames(1).name;
            end
            
        elseif ischar(BagSpec) && exist(BagSpec, 'file')
            
            % Get the file name...
            [Pathstr, BagFileName, Ext] = fileparts(BagSpec);
            BagFileName = [BagFileName Ext];
            if isempty(Pathstr)
                Pathstr = '.';
            else
                BagDirName = Pathstr;
            end            
            
        elseif ~ischar(BagSpec) && isobject(BagSpec)
            
            % We assume a bag file has been passed...
            ADTBag = BagSpec;
            
        elseif ~ischar(BagSpec) && iscell(BagSpec)
            
            if size(BagSpec,2) == 3 && isobject(BagSpec{1}) && iscell(BagSpec{2}) && iscell(BagSpec{3})
                
                ADTBag = BagSpec{1};
                ADTBagMeta = BagSpec{2};
                ADTBagMsg = BagSpec{3};
                
            else
                error('adttool: argument 1 was not in [Bag, Meta, Msg] format!');
            end
            
        else
            
            error(['adttool: argument 1 should be either a directory name, '...
                   'a rosbag file name or a rosbag struct.']);
            
        end
    else
       error('adttool requires at least one argument.'); 
    end
        
    
    % Check varargin
    i=1; 
    while i<=length(varargin), 
      argok = 1; 
      if ischar(varargin{i}), 
        switch lower(varargin{i}), 
            
            % argument IDs                      
            case {'xml', 'xmlfile', 'xmldir', 'xmlspec'},
                i=i+1;
                
                XMLSpec = varargin{i};                                
                
                if ischar(XMLSpec) && isdir(XMLSpec) 
                    
                    % Get the directory name...
                    [Pathstr, Name, Ext] = fileparts(XMLSpec);
                    XMLDirName = [Pathstr '/' Name];
                    
                    % Find the xml file...
                    % We just assume it's the first in the list.
                    XMLFileNames = dir([XMLDirName '/ADT*.xml']);
                    if size(XMLFileNames,1) >= 1
                        % We just assume it's the first in the list.
                        XMLFileName = XMLFileNames(1).name;
                    end
                    
                elseif ischar(XMLSpec)
                    
                    % Get the file name...
                    [Pathstr, XMLFileName, Ext] = fileparts(XMLSpec);
                    XMLFileName = [XMLFileName Ext];
                    if isempty(Pathstr)
                        XMLDirName = '.';
                    else
                        XMLDirName = Pathstr;
                    end
                    
                elseif ~ischar(XMLSpec) && isobject(XMLSpec)
                    
                    % We assume an ADT XML struct has been passed...
                    XML = XMLSpec;
                    
                else
                    error(['adttool: XML argument should be either a directory name, '...
                           'an XML file name or an XML struct.']);
                end
                
            case {'sec', 'seclink', 'sec_link'},                
                i=i+1; if ischar(varargin{i}) SECLinks{end+1}.Topic = varargin{i}; else argok = 0; end
                i=i+1; if ischar(varargin{i}) SECLinks{end}.FirstObj = varargin{i}; else argok = 0; end
                i=i+1; if ischar(varargin{i}) SECLinks{end}.SecondObj = varargin{i}; else argok = 0; end                
                
            otherwise, argok = 0;
        end
      else
        argok = 0;
      end
      if ~argok, 
        error(['adttool: Invalid argument #' num2str(i)]);
      end
      i = i+1;
    end
    
    
    %% ------------
    % FILE LOADING
    %--------------
    
    % Load rosbag...
    if isempty(ADTBag)
        if ~isempty(BagFileName)

            fprintf('Loading rosbag file...');
            ADTBag = ros.Bag.load([BagDirName '/' BagFileName]);
            fprintf('finished!\n');

        else
            error('adttool: No rosbag specified!');
        end    
    end
    
    % Read rosbag topic info...
    if isempty(ADTBagInfo)        
        fprintf('Loading rosbag topic info');
        
        % Parse info from the rosbag...
        ADTBagInfo = ADTBag.info();
        ADTBagTopicStrings = strsplit(ADTBagInfo(findstr(ADTBagInfo, 'topics:'):end), '\n');

        topiccounter = 1;
        for iTopic = 1:length(ADTBagTopicStrings)            

            ADTBagTopicInfo = strsplit(ADTBagTopicStrings{iTopic});

            if length(ADTBagTopicInfo) >= 6
                ADTBagTopicNames{topiccounter} = ADTBagTopicInfo{2};
                ADTBagTopicSizes{topiccounter} = str2num(ADTBagTopicInfo{3});
                ADTBagTopicTypes{topiccounter} = ADTBagTopicInfo{6};
            end

            topiccounter = topiccounter + 1;
            
            % Print progress dots...
            fprintf('.');
            
        end
        
        fprintf('finished!\n');        
    end
    
    % Read topics...
    if isempty(ADTBagMeta) || isempty(ADTBagMsg)
        fprintf('Reading rosbag topics.  This can take some time.  Grab a coffee or watch the dots.');
        
        % Read all data in each topic separately...
        for iTopic = 1:length(ADTBagTopicNames)        

            [ADTBagMsg{iTopic} ADTBagMeta{iTopic}] = ADTBag.readAll({ADTBagTopicNames{iTopic}});

            % Print progress dots...
            fprintf('.');
        end
        
        fprintf('finished!\n');
    end
    
    % Load XML...
    if isempty(XML)
        if ~isempty(XMLFileName) && exist([XMLDirName '/' XMLFileName])

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
                if exist([XMLDirName '/' XMLFileName])
                    fprintf('Reading ADT XML file...');
                    [XML XMLRootName XMLDOMNode] = xml_read([XMLDirName '/' XMLFileName]);
                    fprintf('finished!\n');
                else
                    XMLRootName = 'action_DASH_primitive';
                end

            catch XMLReadException

                error('XML file reading error from xml_io_tools, xml_read()');            
                rethrow(XMLReadException);
            end
        
        % ...or generate XML.
        else

            % Generate XML boilerplate for ADT.
            fprintf('No ADT XML file found.\n');
            fprintf('Generating ADT XML...');

            if ~isempty(BagFileName)
                [~, XMLFileName, ~] = fileparts(BagFileName);
                XMLFileName = ['ADT_' XMLFileName '.xml'];
            end

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

            % Room description...
            XML.room_DASH_description.CONTENT = 'void';
            
            % Recording method...
            XML.recording_DASH_method.CONTENT = 'void';
            
            % Recording data...
            XML.recording_DASH_data.CONTENT = BagFileName;

            % Anchor points (SEC)...
            XML.anchor_DASH_points.SEC_DASH_line = [];
            XML.anchor_DASH_points.ATTRIBUTE.nr_DASH_events = [];
            
            % Action chunks
            XML.action_DASH_chunks = [];
            % XML.action_DASH_chunks.action_DASH_chunk(1).COMMENT = 'First action chunk'
            % XML.action_DASH_chunks.action_DASH_chunk(1).context = 'Description'            

            %
            % TODO: Finish this section!
            %

            fprintf('finished!\n');        

        end
    end
    
    
    %% -------------------
    % MAIN XML PROCESSING
    %---------------------
    
    fprintf('Processing XML.');
    
    % SEC links...
    if ~isempty(SECLinks)
        
        % Find the SEC topic indices
        for iSEC = 1:size(SECLinks,2)
            SECTopicIndices(iSEC) = findtopic(ADTBagTopicNames, SECLinks{iSEC}.Topic);
        end
        
        % Grab the first semantic event (SE) from the first timestep
        % and start building the SEC and collecting topic metas for
        % action chunks.
        currentchunk = 1;
        for iTopic = 1:size(SECTopicIndices,2)
            
            PreviousSE(iTopic) = str2num(ADTBagMsg{SECTopicIndices(iTopic)}{1}.data);
            
            ADTBagActionChunkMeta{currentchunk}.StartStep{iTopic} = 1;
            
            ADTBagActionChunkMeta{currentchunk}.StartMeta{iTopic} =...
                ADTBagMeta{SECTopicIndices(iTopic)}{1};
        end
        
        SEC(:,1) = PreviousSE';
        
        % Build both the SEC and an action chunk meta sequence.
        for iStep = 1:size(ADTBagMsg{SECTopicIndices(1)}, 2)
            
            for iTopic = 1:size(SECTopicIndices,2)
                CurrentSE(iTopic) = str2num(ADTBagMsg{SECTopicIndices(iTopic)}{iStep}.data);
            end
            
            % If there has been a semantic change...
            if sum(abs(CurrentSE - PreviousSE)) > 0
                
                for iTopic = 1:size(SECTopicIndices,2)
                    
                    % ...we record the end of the previous action chunk...
                    ADTBagActionChunkMeta{currentchunk}.EndStep{iTopic} = iStep;

                    ADTBagActionChunkMeta{currentchunk}.EndMeta{iTopic} =...
                        ADTBagMeta{SECTopicIndices(iTopic)}{iStep};
                    
                    % ...and record the start of the current action chunk.
                    ADTBagActionChunkMeta{currentchunk + 1}.StartStep{iTopic} = iStep;

                    ADTBagActionChunkMeta{currentchunk + 1}.StartMeta{iTopic} =...
                        ADTBagMeta{SECTopicIndices(iTopic)}{iStep};
                end
                
                % Finally we update the previous SE...
                PreviousSE = CurrentSE;
                
                % ...advance the action chunk marker...
                currentchunk = currentchunk + 1;
                
                % ...and record the current SE in the SEC.
                SEC(:,end+1) = CurrentSE';                
            end

        end
        
        % Delete the last action chunk...
        ADTBagActionChunkMeta(end) = [];
        
        % Check to ensure that the SEC size corresponds to the number of
        % action chunks...
        if size(ADTBagActionChunkMeta,2) ~= (size(SEC,2) - 1)            
            error('adttool: SEC and action chunk cardinalities do not match!');
        end
        
    end
    
    % Generate SEC XML...
    if ~isempty(SEC)
        
        % Number of action chunks...
        XML.anchor_DASH_points.ATTRIBUTE.nr_DASH_events = size(SEC,2) - 1;
        
        % Loop and add SEC lines to XML...
        for iSECLine = 1:size(SEC,1)
            
            % SEC lines...
            XML.anchor_DASH_points.SEC_DASH_line(iSECLine).CONTENT = SEC(iSECLine, :);
            
            % Link the objects...
            XML.anchor_DASH_points.SEC_DASH_line(iSECLine).ATTRIBUTE.first =...
                SECLinks{iSECLine}.FirstObj;
            XML.anchor_DASH_points.SEC_DASH_line(iSECLine).ATTRIBUTE.second =...
                SECLinks{iSECLine}.SecondObj;
        end
        
    end
    
    % Generate action chunks from SEC links...
    if ~isempty(ADTBagActionChunkMeta)
        
        % Find unique objects in SECLinks...
        for iSECLink = 1:size(SECLinks,2)
            if sum(strcmp(Objects, SECLinks{iSECLink}.FirstObj)) == 0
                Objects{end+1} = SECLinks{iSECLink}.FirstObj;
            end
            
            if sum(strcmp(Objects, SECLinks{iSECLink}.SecondObj)) == 0
                Objects{end+1} = SECLinks{iSECLink}.SecondObj;
            end
        end
        
        % Build SECObject lookup table...
        for iSECLink = 1:size(SECLinks,2)
            SECObjTab(iSECLink,1) = find(strcmp(Objects, SECLinks{iSECLink}.FirstObj));
            SECObjTab(iSECLink,2) = find(strcmp(Objects, SECLinks{iSECLink}.SecondObj));
        end
        
        % Generate each action chunk...
        for iChunk = 1:(size(SEC,2) - 1)
            
            % Build interaction table...
            IntTab = zeros(size(Objects,2));
            
            % We assume the first SEC link involves the hand and
            % main-object, and we assume an OR relation between, i.e.,
            % if they're touching at all, they're interacting.
            IntTab(SECObjTab(1,1), SECObjTab(1,2)) =...
                or(SEC(1,iChunk+1), SEC(1,iChunk));
            IntTab(SECObjTab(1,2), SECObjTab(1,1)) =...
                or(SEC(1,iChunk+1), SEC(1,iChunk));
            
            % For the remaining SEC links, we assume an XOR relation, i.e.,
            % there must have been a state change to count as an
            % interaction.
            for iSECLink = 2:size(SECLinks,2)
                IntTab(SECObjTab(iSECLink,1), SECObjTab(iSECLink,2)) =...
                    xor(SEC(iSECLink,iChunk+1), SEC(iSECLink,iChunk));
                IntTab(SECObjTab(iSECLink,2), SECObjTab(iSECLink,1)) =...
                    xor(SEC(iSECLink,iChunk+1), SEC(iSECLink,iChunk));
            end
            
            % Generate the XML for each object depending on whether or not
            % the object interacts with the hand.
            for iObj = 1:size(Objects,2)
                
                % Format the object field string for xml_io_tools...
                ObjField = strrep(Objects{iObj}, '-', '_DASH_');
                ObjField = [ObjField '_DASH_act'];
                
                if interactswithhand(IntTab, iObj)                                        
                    
                    % Start timestamp...
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.timestamp =...
                        ADTBagActionChunkMeta{1}.StartMeta{1}.time.time;
                    
                    % Modify the position, quaternion and pose_reliability
                    % fields.                
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.position = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.position.CONTENT =...
                        [ADTBagActionChunkMeta{iChunk}.StartStep{1} ADTBagActionChunkMeta{iChunk}.StartStep{1} ADTBagActionChunkMeta{iChunk}.StartStep{1}];

                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.quaternion = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.quaternion.CONTENT =...
                        [ADTBagActionChunkMeta{iChunk}.StartStep{1} ADTBagActionChunkMeta{iChunk}.StartStep{1} ADTBagActionChunkMeta{1}.StartStep{iChunk} ADTBagActionChunkMeta{iChunk}.StartStep{1}];

                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.pose_DASH_reliability = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).start_DASH_point.pose.pose_DASH_reliability.CONTENT =...
                        ADTBagActionChunkMeta{iChunk}.StartStep{1};
                    
                    % End timestamp...
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.timestamp =...
                        ADTBagActionChunkMeta{1}.EndMeta{1}.time.time;
                    
                    % Modify the position, quaternion and pose_reliability
                    % fields.                
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.position = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.position.CONTENT =...
                        [ADTBagActionChunkMeta{iChunk}.EndStep{1} ADTBagActionChunkMeta{iChunk}.EndStep{1} ADTBagActionChunkMeta{iChunk}.EndStep{1}];

                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.quaternion = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.quaternion.CONTENT =...
                        [ADTBagActionChunkMeta{iChunk}.EndStep{1} ADTBagActionChunkMeta{1}.EndStep{1} ADTBagActionChunkMeta{iChunk}.EndStep{1} ADTBagActionChunkMeta{iChunk}.EndStep{1}];

                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.pose_DASH_reliability = [];
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).end_DASH_point.pose.pose_DASH_reliability.CONTENT =...
                        ADTBagActionChunkMeta{iChunk}.EndStep{1};
                else
                    
                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).(ObjField).CONTENT = 'void';
                end
                
            end
        end
        
    end
    
    
    % if isfield(XML, 'action_DASH_chunks')
    % 
    %     if isfield(XML.action_DASH_chunks, 'action_DASH_chunk')
    % 
    %         %
    %         % NOTE: Proof of concept, for the moment (24th Oct 2014).
    %         % We traverse each action_chunk(i).main_object_act field,
    %         % search for the start and end timestamps in the rosbag,
    %         % and modify the position, quaternion and pose_reliability
    %         % fields for each action_chunk by replacing 'xxx xxx xxx' placeholders
    %         % with numerical placeholders based on the relevant rosbag frame.
    %         % Object poses have not been included in rosbags recorded up
    %         % until now (24/10/14).  Work in progress.
    %         % 
    %         for iChunk = 1:size(XML.action_DASH_chunks.action_DASH_chunk,1)
    % 
    %             %% Search for the start position timestamp in the rosbag.
    %             % We just use the first topic for now in the absence
    %             % of a main object pose topic.
    %             iTopic = 1;
    %             for iFrame = 1:size(ADTBagMeta{iTopic}, 2)
    %                 % 
    %                 if ADTBagMeta{1}{iFrame}.time.time >=...
    %                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.timestamp
    %                     iStartFrame = iFrame;
    %                     break;
    %                 end
    %             end                
    % 
    %             % Modify the position, quaternion and pose_reliability
    %             % fields.                
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.position = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.position.CONTENT =...
    %                 [iStartFrame iStartFrame iStartFrame];
    % 
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.quaternion = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.quaternion.CONTENT =...
    %                 [iStartFrame iStartFrame iStartFrame iStartFrame];
    % 
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.pose_DASH_reliability = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.start_DASH_point.pose.pose_DASH_reliability.CONTENT =...
    %                 iStartFrame;
    % 
    %             % Print progress dots...
    %             fprintf('.');
    % 
    %             %% Search for the end position timestamp in the rosbag.
    %             % We just use the first topic for now in the absence
    %             % of a main object pose topic.
    %             iTopic = 1;
    %             for iFrame = 1:size(ADTBagMeta{iTopic}, 2)
    %                 % 
    %                 if ADTBagMeta{1}{iFrame}.time.time >=...
    %                    XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.timestamp
    %                     iEndFrame = iFrame;
    %                     break;
    %                 end
    %             end                
    % 
    %             % Modify the position, quaternion and pose_reliability
    %             % fields.                
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.position = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.position.CONTENT =...
    %                 [iEndFrame iEndFrame iEndFrame];
    % 
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.quaternion = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.quaternion.CONTENT =...
    %                 [iEndFrame iEndFrame iEndFrame iEndFrame];
    % 
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.pose_DASH_reliability = [];
    %             XML.action_DASH_chunks.action_DASH_chunk(iChunk).main_DASH_object0x2Dact.end_DASH_point.pose.pose_DASH_reliability.CONTENT =...
    %                 iEndFrame;
    % 
    %             % Print progress dots...
    %             fprintf('.');
    %         end
    % 
    %     else
    %         %
    %         % TODO: What happens if we have no action_chunk field entries?
    %         %
    %     end
    % 
    %     fprintf('finished!\n');
    % 
    % else
    %     error(['The XML file ' XMLFileName ' does not appear to be formatted correctly.']);
    % end
    
    
    %% -----------
    % FILE SAVING
    %-------------
    
    % Write xml file...
    if ~isempty(XMLFileName)
        
        try        
            fprintf('Writing ADT XML file...');
            Prefs.CellItem = false;
            Prefs.StructItem = false;
            xml_write([XMLDirName '/' XMLFileName], XML, XMLRootName, Prefs);
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
    
    
    %% --------------------------
    % OUTPUT ARGUMENT PROCESSING
    %----------------------------
    
    % Output XML
    varargout{1} = XML;
    
    
    %% ----------------
    % HELPER FUNCTIONS
    %------------------

    function index = findtopic(TopicNames, Topic)

        for index = 1:size(TopicNames,2)

            found = false;

            if strcmp(TopicNames{index}, Topic)
                found = true;
                break;
            end

            if ~found
                index = 0;
            end

        end
    
    function result = interactswithhand(IntTab, iObj)
        
        % Here be recursive dragons! 
        
        for jObj = 1:size(IntTab,2)
            if IntTab(iObj, jObj) && jObj == 1
                result = true;
                return;
            elseif IntTab(iObj, jObj)
                result = interactswithhand(IntTab, jObj);
                return;
            end
        end
        
        result = false;
        
        