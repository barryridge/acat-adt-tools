# ACAT ADT GENERATOR/GUI EDITOR #

Generates new, or populates existing, ADT XML files using rosbag recordings.

### INSTALL ###

1. Install the following prerequisites:

    [matlab_rosbag](https://github.com/bcharrow/matlab_rosbag) - A tool for manipulating rosbags in Matlab without ROS.

    Notes:

    * Compilation can be a bit tricky.  Use one of the binaries if possible.


    [xml_io_tools](http://www.mathworks.com/matlabcentral/fileexchange/12907-xml-io-tools) - A tool for reading XML into Matlab structs and writing them out to XML again.


2. Change the path settings in the setpaths.m file.

### USAGE ###

Try running the demo.m file.  A path pointing to a sample rosbag needs to be changed in there too.

The demo file will load up a rosbag file, generate ADT XML from it using the adttool script, and start the adteditor GUI tool.


### RELEASE NOTES ###

v0.2, 23/3/2015: Major update to adteditor.  Still some work to be done on the interface, but the hard work has been completed.

v0.1: adttool is working well, but adteditor, the GUI ADT editing tool, is not yet in a functional state.