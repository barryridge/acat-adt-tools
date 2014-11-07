% 
% adtdemo
%
% ACAT Project
% http://www.acat-project.eu/
% Author: Barry Ridge, JSI.
% E-mail: barry.ridge@ijs.si
% Last updated: 7th Nov 2014 (or check repository!)
% Repository: https://barryridge@bitbucket.org/barryridge/acat-adt-generator.git
% Please e-mail me for access.
%
% Description:              Demo
%
% Usage:                    Don't forget to change the path for the rosbag!
%   
% Prerequisite packages:    matlab_rosbag, xml_io_tools
%                           (see README.md and setpaths.m for further
%                           info)
%

% Pre-load the rosbag, topic meta-data, and topic message data...
[ADTBag ADTBagMeta BagMsg] = loadbag('/home/barry/Research/Data/SampleROSBagRecordings/2014-11-04-14-38-49.bag');

% Generate XML
XML = adttool({ADTBag, ADTBagMeta, ADTBagMsg},... % Use the pre-loaded rosbag data
              'xml', 'demotemp.xml',... % Set an output XML filename
              'set', 'main-object.cad-model.uri', 'blah.pcd',... % Example of setting an XML node value              
              'objlink', '/pose_estimation_jsi_live/object_pose',... % Link a rosbag object pose topic to an object in the XML
                         'faceplate', 'primary-object',...
              'seclink', '/HvsM', 'hand', 'main-object',... % Link a SEC topic to objects in the XML
              'seclink', '/MvsP', 'main-object', 'primary-object',...
              'seclink', '/MvsS', 'main-object', 'secondary-object')