# simple time tracker using sinatra and files.

 - start tracker
 - stop tracker
 - grouped by day
 - no authentication
 - no projects
 - loads of juice!

to get started:

    git clone git://github.com/qzio/timesheet.git
    cd timesheet
    bundle install
    bin/tscmd.sh startd


visit http://localhost:1337, or use the startup script

    bin/tscmd.sh startd - start daemon
    bin/tscmd.sh stopd  - stop daemon
    bin/tscmd.sh start  - start timer
    bin/tscmd.sh stop   - stop timer
