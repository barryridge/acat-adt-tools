function [BagOut BagMeta BagMsg BagInfo BagTopicNames BagTopicSizes BagTopicTypes] = loadbag(BagSpec)

    % Output variables...
    BagOut = [];
    BagMeta = [];
    BagMsg = [];
    BagInfo = [];
    BagTopicNames = [];
    BagTopicSizes = [];
    BagTopicTypes = [];
    
    % Check BagSpec argument...
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
        BagOut = BagSpec;

    elseif ~ischar(BagSpec) && iscell(BagSpec)

        if size(BagSpec,2) == 3 && isobject(BagSpec{1}) && iscell(BagSpec{2}) && iscell(BagSpec{3})

            BagOut = BagSpec{1};
            BagMeta = BagSpec{2};
            BagMsg = BagSpec{3};

        else
            error('adtgenerator: argument 1 was not in [Bag, Meta, Msg] format!');
        end

    else

        error(['loadbag: argument 1 should be either a directory name, '...
               'a rosbag file name or a rosbag struct.']);

    end

    % Load rosbag...
    if ~isempty(BagFileName)

        fprintf('Loading rosbag file...');
        BagOut = Bag.load([BagDirName '/' BagFileName]);
        fprintf('finished!\n');

    else
        error('adtgenerator: No rosbag specified!');
    end    
    
    % Read rosbag topic info...     
    fprintf('Loading rosbag topic info');

    % Parse info from the rosbag...
    BagInfo = BagOut.info();
    BagTopicStrings = strsplit(BagInfo(findstr(BagInfo, 'topics:'):end), '\n');

    topiccounter = 1;
    for iTopic = 1:length(BagTopicStrings)            

        BagTopicInfo = strsplit(BagTopicStrings{iTopic});

        if length(BagTopicInfo) >= 6
            BagTopicNames{topiccounter} = BagTopicInfo{2};
            BagTopicSizes{topiccounter} = str2num(BagTopicInfo{3});
            BagTopicTypes{topiccounter} = BagTopicInfo{6};
        end

        topiccounter = topiccounter + 1;

        % Print progress dots...
        fprintf('.');

    end

    fprintf('finished!\n');        
    
    % Read topics...    
    fprintf('Reading rosbag topics.  This can take some time.  Grab a coffee or watch the dots.');

    % Read all data in each topic separately...
    for iTopic = 1:length(BagTopicNames)        

        [BagMsg{iTopic} BagMeta{iTopic}] = BagOut.readAll({BagTopicNames{iTopic}});

        % Print progress dots...
        fprintf('.');
    end

    fprintf('finished!\n');    