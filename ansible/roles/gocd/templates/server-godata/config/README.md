The custom init script will copy this file OVER /godata/config/cruise-config.xml at boot time


Templating cruise-config.xml directly from ansible works fine but because gocd updates the xml file with agent info etc this will make ansible restart the containers on every run (bad hmmkay)
