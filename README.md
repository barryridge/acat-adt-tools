# ACAT ADT GENERATOR/GUI EDITOR #

Generates new, or populates existing, ADT XML files using rosbag recordings.

### INSTALL ###

Install the following prerequisites:

* [matlab_rosbag](https://github.com/bcharrow/matlab_rosbag) *

A tool for manipulating rosbags in Matlab without ROS.

Notes:
* Compilation can be a bit tricky.  Use one of the binaries if possible.

* [xml_io_tools](http://www.mathworks.com/matlabcentral/fileexchange/12907-xml-io-tools)

A tool for reading XML into Matlab structs and writing them out to XML again.

### USAGE ###

1. Check the path settings in the setpaths.m file.
2. Try running the demo.m file.  A path pointing to a sample rosbag needs to be changed in there too.