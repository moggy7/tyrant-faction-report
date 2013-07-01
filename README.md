TYRANT Faction Report Script
========================================
Code version 1.6.3
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
  Xd | Net Damage        | the total damage the player dealt to opposing faction, minus the damage they took
   i | User ID           | the unique ID given by the Tyrant client for each user
  Xl | Loyalty Gain      | the amount of loyalty the player gained (this is equal to their win count)
   n | Name              | the name of the user (if you supply a file to REPORT_FORMAT:aliases, the name from that file)
  Xp | Win %             | the percentage of battles won over total battles fought, including defensive battles
   q | Last Login        | the number of days ago that the user last logged in
  Xr | Total Losses      | the total number of battles the user lost
  Xs | Approx. Surge %   | an estimate of the percentage of the time the user chose Surge instead of Fight
   u | Total Loyalty     | the total loyalty points accumulated by the user since joining the faction
   v | Level             | the user's level at the time the report is generated
  Xw | Total Wins        | the total number of battles won, including defensive battles


OTHER OPTIONS:

:aliases should contain a path to a file containing user names/nicknames for members of your faction, mapped
to their user ids in the JSON format. If you don't have one of these files but would like to use one, set
:aliases to true and a template will be generated for you when you run the script. You can then
modify the template names to your preferred aliases for each faction member. Remember to update the value
of :aliases to contain the path to the file once it has been generated!

:output should contain the file path to which you want your report output. If an argument is supplied to the script
when it is run, that argument will take precedence over the value stored in :output. If no value is supplied for
:output and no argument is supplied to the script, the report will simply be output to the command line.

========================================
