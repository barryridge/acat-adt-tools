![ACat Project Logo](https://github.com/barryridge/acat-adt-tools/images/acatlogo.png)

# ACAT ADT Tools #

A suite of tools for creating and manipulating ADTs (Action Data Tables) for the [EU FP7 ACat project](http://www.acat-project.eu/), consisting of:

  1. adttool:
  
    A tool that generates new, or populates existing, ADT XML files using ROS bag recordings.

  2. adteditor (currently adteditor_GUIDE):

    A GUI editor that acts as an interface to _adttool_ in order to make certain tasks easier.

### Install ###

1. Install the following prerequisites:

  [matlab_rosbag](https://github.com/bcharrow/matlab_rosbag) - A tool for manipulating rosbags in Matlab without ROS.

  Notes:

  * Compilation can be a bit tricky.  Use one of the binaries if possible.


  [xml_io_tools](http://www.mathworks.com/matlabcentral/fileexchange/12907-xml-io-tools) - A tool for reading XML into Matlab structs and writing them out to XML again.


2. Change the path settings in the setpaths.m file.

### Usage ###

Try running the adtdemo.m file.  A path pointing to a sample rosbag needs to be changed in there too.

The demo file will load up a rosbag file, generate ADT XML from it using the adttool script, and start the adteditor GUI tool.

For more detailed usage instructions, ACat project members should refer to *Deliverable 1.2* for now.  These instructions shall be transcribed to a USAGE.md file at a later date.

### Release Notes ###

[688448a](https://github.com/barryridge/acat-adt-tools/commit/688448a99a6479553481e114b8e4a5de25ad00d5), _28/10/2015_:

  * Problems with the checkboxes and removing topics from the timeline stem from the decision to use GUIDE for UI design.
  * In order to deal with this, I have frozen GUIDE-based development and created temporary adteditor_GUIDE.m and adteditor_GUIDE.fig files for user testing purposes that still contain the bug, and will re-develop the adteditor with separately.  Once this is completed, the GUIDE-based version can be purged.
  * Progress-bar dialogs have been added to show rosbag loading progress.

[0252d31](https://github.com/barryridge/acat-adt-tools/commit/0252d31f127c879082e52280c7293c75de51db3c), _23/3/2015_:

  * Major update to adteditor.
  * Still some work to be done on the interface, but the hard work has been completed.

*v0.1*:

  * adttool is working well, but adteditor, the GUI ADT editing tool, is not yet in a functional state.
