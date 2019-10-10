# BatchBashRegTools
A collection of scripts made in Bash (.sh), Batch (.bat) &amp; Registry Data (.reg) files.

## src/main/bash ##
* pull.sh
  * Recursivly pulls all git repos using these rules as path:
    * Path parameter
    * REPOS enviroment variable
    * Current directory
  * Ignores folders with a file named ".ignorerepos"
  * [Original ASCII art](https://blog.kazitor.com/2014/12/portal-ascii/) by [kazitor](https://blog.kazitor.com/author/kazitor/)

## src/main/batch ##
* killName.bat
  * Prompts user to type a process name to terminate it (Faster than windows task manager!)
  
* moboModel.bat
  * Prints motherboard model (Useful when I'm lazy)
  
* restartAudio.bat
  * Restarts windows audio service (Useful for when audio programs require you to restart your computer Ex: EqualiserAPO)
  * [Original UAC request code](https://stackoverflow.com/a/30590134) by [cyberponk](https://stackoverflow.com/users/4932683/cyberponk)

### Tip: Running .sh files on Windows ###
One easy way to run .sh files in windows is to install [Git](https://git-scm.com/downloads) as it comes with a bash shell emulator, that's able to run .sh files
 (You could also create an .exe file that runs the emulator using C:\Windows\System32\iexpress.exe)
