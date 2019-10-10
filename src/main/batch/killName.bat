SET /P NAME=Enter image name:
taskkill /f /fi "windowtitle eq %NAME%*"