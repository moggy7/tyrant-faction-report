TYRANT Faction Report Script
========================================
Code version 1.7.2
========================================
First run

1. Run ```ruby main.rb```

2. On your first run, 2 folders will be created, cache and configuration.

3. Open the config/settings.yml. It will probably look something like:
```---
:flashcode: ''
:faction_id: ''
:user_id: ''
:game_auth_token: ''
:facebook: false
:client_id:
:user_agent: Ruby Net Point Script 1.7.2
```

4. Find your flashcode, user_id, and game_auth_token.  Everything will be automatically filled in.  Read SETTINGS customization for help.

5. Configure Reports
	A. For Local Reports
		- Open "config/report.yml"
		- Set it up how you like.
		- Make sure output has a filename to save to.
	B. For uploading to Google Docs.
		- Make sure you have the ```google_drive``` gem installed. (```gem install google_drive```)
		- Open "config/spreadsheet.yml"
		- Add your Google user name and password (it will be stored in plaintext).
		- Find the spreadsheet key (it is a very long and unweildly mess).

6. Run the report as needed.

7. For automated report generation, you can look installing Cygwin on Windows and using Cron (both Linux and Mac OS X have cron by default).
8. 

========================================
SETTINGS customization:
========================================


See here for instructions on how to find these values:
http://www.kongregate.com/forums/65-tyrant/topics/257875-last-guide-auto-factions-net-dmg


========================================
REPORT:format character map
========================================

HOW IT WORKS:

To report a specific value, add the relevant character code to your REPORT:format string.

Your report will be sorted based on the value of REPORT:sort, which should be structured the same
way you would structure a column in the :format. This sort does not need to match any of the columns in your
report, though it's recommended for the purposes of readability.

Your results be listed in descending order on the sort column unless you specify 'asc' as the :order value.

'X' in front of a character code indicates that you should enter a number, as the value will be
calculated over the last 'X' days.

EXAMPLE:

'v 365d 30w 1a' would result in a report containing:
Level, Net Damage (for the last year), Total Wins (for the last month), Battles Initiated (in the last day)


Char | Reported Value    | Notes/Description
-----|-------------------|-------------------------------------------------------------------------------------
  Xa | Battles Initiated | the number of times the user clicked either Fight or Surge
  Xb | Damage For        | the total damage the player dealt to opposing faction
  Xc | Damage Against    | the total damage the player took
  Xd | Net Damage        | the total damage the player dealt to opposing faction, minus the damage they took
  Xe | Total Wins (Atk)  | the total number of battles won as attacker
  Xf | Total Losses (Atk)| the total number of battles lost as attacker
  Xg | Total Wins (Def)  | the total number of battles won as defender
  Xh | Total Losses (Def)| the total number of battles lost as defender
   i | User ID           | the unique ID given by the Tyrant client for each user
  Xl | Loyalty Gain      | the amount of loyalty the player gained (this is equal to their win count)
   n | Name              | the name of the user (if you supply a file to REPORT_FORMAT:aliases, the name from that file)
   o | Rank              | the rank of the user in faction
  Xp | Win %             | the percentage of battles won over total battles fought, including defensive battles
   q | Last Login        | the number of days ago that the user last logged in
  Xr | Total Losses      | the total number of battles the user lost
  Xs | Approx. Surge %   | an estimate of the percentage of the time the user chose Surge instead of Fight
   t | Last Claim        | the number of days ago that the user claimed tokens
   u | Total Loyalty     | the total loyalty points accumulated by the user since joining the faction
   v | Level             | the user's level at the time the report is generated
  Xw | Total Wins        | the total number of battles won, including defensive battles


OTHER OPTIONS:

```:aliases``` should contain a path to a file containing user names/nicknames for members of your faction, mapped
to their user ids in the JSON format. If you don't have one of these files but would like to use one, set
```:aliases``` to ```true``` and a template will be generated for you when you run the script. You can then
modify the template names to your preferred aliases for each faction member. Remember to update the value
of ```:aliases``` to contain the path to the file once it has been generated!

:output should contain the file path to which you want your report output. If an argument is supplied to the script
when it is run, that argument will take precedence over the value stored in :output. If no value is supplied for
:output and no argument is supplied to the script, the report will simply be output to the command line.  This behavior
has been identified as needed to change and will probably do so in a few version (currently written 1.7.0).

========================================
Previous Version: 

Version |  URL
--------|------------------------------
1.7.0   |  http://pastebin.com/RFDwZ3hg
1.6.3   |  http://pastebin.com/ssBesK9z
1.6.2   |  http://pastebin.com/Dqn01GYa
1.6.1   |  http://pastebin.com/5QcYuBpd
1.6.0   |  http://pastebin.com/JmA9dZs4
1.5.4   |  http://pastebin.com/7hpmi7nd

========================================
Changelog (git fork)

1.7.2

* Merged pastebin 1.7.0 changes so report functions with new format

1.7.1

* Updated logic so the report functions
* Added report values

1.7.0

* Liscenced under a very liberal MIT liscence.  This is basically how I treated the code, however this does require that the liscence be included in all future branches.
* Fixed some issues with ```duplicate_client_id```. Will now automatically fetch valid client code and update data if this error is retrieved.
* Seperated each class into it's own file.  This will make managing the growing code base far easier.
