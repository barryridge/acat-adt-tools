function [BagOut BagMeta BagMsg BagInfo BagTopicNames BagTopicSizes BagTopicTypes] = loadbag(BagSpec, varargin)

    % Output variables...
    BagOut = [];
    BagMeta = [];
    BagMsg = [];
    BagInfo = [];
    BagTopicNames = [];
    BagTopicSizes = [];
    BagTopicTypes = [];
    
    % Flags...
    guidialogs = false;
    hProgressBar = [];
    progress = 0.0;
    
    % Check varargin...
    if nargin >= 1
        if islogical(varargin{end})
            guidialogs = varargin{end};
        end
    end
    
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
            if guidialogs
                errordlg('loadbag: argument 1 was not in [Bag, Meta, Msg] format!');
            else
                error('loadbag: argument 1 was not in [Bag, Meta, Msg] format!');
            end
        end

    else
        if guidialogs
            errordlg(['loadbag: argument 1 should be either a directory name, '...
                      'a rosbag file name or a rosbag struct.']);
        else
            error(['loadbag: argument 1 should be either a directory name, '...
                   'a rosbag file name or a rosbag struct.']);
        end

    end

    % Load rosbag...
    if ~isempty(BagFileName)
        
        % Replace spaces...
        BagDirName = strrep(BagDirName, ' ', '\ ');
        BagFileName = strrep(BagFileName, ' ', '\ ');
        
        if guidialogs
            % progress = progress + 0.1;
            hProgressBar = waitbar(progress, 'Loading ROS bag file...');
        else
            fprintf('Loading ROS bag file...');
        end
                
        BagOut = ros.Bag.load(fullfile(BagDirName, BagFileName));
        
        if guidialogs
            progress = progress + 0.1;
            waitbar(progress, hProgressBar, '...finished loading rosbag file!');
        else
            fprintf('finished!\n');
        end

    else
        if guidialogs
            errordlg('loadbag: No ROS bag specified!');
        else            
            error('loadbag: No ROS bag specified!');
        end
    end    
    
    % Read rosbag topic info...
    if guidialogs
        % progress = progress + 0.1;
        waitbar(progress, hProgressBar, 'Loading ROS bag topic info...');
    else        
        fprintf('Loading ROS bag topic info');
    end

    % Parse info from the rosbag...
    BagInfo = BagOut.info();
    BagTopicStrings = strsplit(BagInfo(findstr(BagInfo, 'topics:'):end), '\n');
    
    if guidialogs
        increment = ((1.0 - progress) / 2) / length(BagTopicStrings);
    end

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
        if guidialogs
            progress = progress + increment;
            waitbar(progress, hProgressBar);
        else
            fprintf('.');
        end

    end

    if guidialogs
        % progress = progress + 0.1;
        waitbar(progress, hProgressBar, '...finished loading ROS bag topic info!');
    else
        fprintf('finished!\n');
    end
    
    % Read topics...
    if guidialogs
        % progress = progress + 0.1;
        waitbar(progress, hProgressBar, 'Reading ROS bag topics. This can take some time...');
    else
        fprintf('Reading ROS bag topics.  This can take some time.  Grab a coffee or watch the dots.');
    end
    
    % Calculate the progress bar increment...
    if guidialogs
        increment = ((1.0 - progress) / 2) / length(BagTopicNames);
    end

    % Read all data in each topic separately...
    for iTopic = 1:length(BagTopicNames)        

        [BagMsg{iTopic} BagMeta{iTopic}] = BagOut.readAll({BagTopicNames{iTopic}});

        % Print progress dots...
        if guidialogs
            progress = progress + increment;
            waitbar(progress, hProgressBar);        
        else
            fprintf('.');
        end
    end

    if guidialogs
        progress = 1.0;
        waitbar(progress, hProgressBar, 'Finished!');
        close(hProgressBar);
    else
        fprintf('finished!\n');    
    end