Adventure Kernel System in Ruby
===============================

The Adventure Kernel System is a text adventure game engine writen initially for the Amstrad.  This is a Ruby port.

All credit goes to Mike Lewis and Simon Price.  It is based on their book on 'Writing Adventure Games on the Amstrad' ISBN 0 86161 196 9

I've kept the same input structure being a CSV file so that exisiting games writen in this langauge will (*or should*) work.  Game variables and function names are as similar to the original.

## Game Iteration

The game loops the following until an end of game flag is true
```
	Describe Location
	Get command line
	Process command line
	Update Countdowns
```

## Input Structure

The Basics are:

The overall structure is to have three data sections and an end identifier F.  All data is in CSV format

| Section | Identifier |
| ------- | :--------: |
| Locations | L |
| Objects | O |
| Events | E |
| Finish | F |

## Locations

Locations are where the adventure moves to usually via North, East, South and West.  With AKS, Location zero is a special location that can't be reached but contains key triggers that are not location specific.  Like the word **Get**, it can be used in any location, but might not do anything useful.  Locations have the following structure and identifiers.

* `L,<number>` Location id with its location number.
* `D,<condition>,<text>` Description of the location with a condition and text to display if condition is met.
* `C,<direction>,<condition>,<location>` Connection with the direction to travel, condition and location number to go to if condition is met.
* `T,<wordlist>,<conditions>` Triggers (words that the user types) have a wordlist that match the trigger and a condtion.  All Triggers must have an action if the condition is met.  These are on the next lines after the trigger.
* `A,<actiontype>,<actiondata>`  An action with an action type and its associated action data.  Every action has a different set of data.  Like to print a message will have some text, or to update a flag will have the flag number and its boolean value.

Here are all valid action types and their data
* `AF,<flag number>,<flag status>` Assign Flag with the flag number and its boolean status (T or F)
* `DR` Drop action
* `EX` Examine action
* `GE` Get action
* `IN` Inventory action
* `LO` Load action
* `SA` Save action
* `QU` Quit action
* `SC` Score action
* `PO` Put on action
* `TO` Take off action
* `DR` Drop action
* `GO,<direction>` Move player to a new location in that direction
* `IC,<counter number>,<int>` Initialise counter of counter number with value of int.
* `HC,<counter number>` Stop a counter with counter number from decreasing
* `RC,<counter number>` Resumes a counter with counter number decreasing
* `IS,<int>` Increment score by the value of int
* `MO,<object number>,<location>` Move an object to a location, if location is 0 then a random location is given
* `PR,<text>` Print the text
* `ZI,<object number>` Zap in the object
* `ZO,<object number>` Zap out the object

The variables are defined as
* `<flag number>` 0..maxint
* `<flag status>` 'T' for true and 'F' for false
* `<direction>` 'E','N','S','W','U','D'
* `<counter number>` 0..maxint
* `<int>` 0..maxint
* `<object number>` 0..max objects
* `<location>` 0..max locations
* `<text>` string with single quotes if talking

Here is an example of a Trigger with some actions to do when the trigger is typed by the user.
```
T, feed ducks, feed duck,*
A, PR, the ducks gobble up all the bread and leave.
A, ZO,5
```
Here when the user types 'feed ducks' or 'feed duck' a message will be printed and object 5 (bread) will be zapped out of the game.

## Objects

Objects are things that can be interacted with, like being picked up or looked at.  These include people who are at the location.  Object 0 is a special object that represents the player.  If an object is in Place 0, the user is carrying it.  Objects have the following identifiers.

* `O,<number>` Object id with its Object number.
* `D,<condition>,<text>` Description of the object with a condition and text to display if condition is met.
* `N,<namelist>,<conditions>` Name of the object that the user can type to interact with it.  The name list could contain multiple verbs.  And a condition to be true to have it useable
* `P,<location>` The Place where the object is found.
* `V,<number>` [Optional], if object is carried, add a score value of number. Defaults to 0
* `S,<actiontype>,<condition>,<text>` Suitability to the action.  If something can be picked up or droped then this object will have the action type of 'GE' and 'DR', if the action is 'EX', then display a text for describing the object.  Not all actiontype are used, 

Here is an example of an Object
```
O,4
D, *, A small rusty lamp
P, 19
N, rusty lamp, torch, * 
S, GE, *
S, DR, *
S, EX, *, It's just a plain oil lamp
```
This object 4, is a lamp, is in location 19, can be called a torch or rusty lamp and can be picked up, dropped an examined.

## Events

Events are triggered when an assoociated counter is has reached 0.  The event number matches the counter number.  This could be if after 100 moves, the game is over.  Events have the following identifiers.  Counters decrease every turn unless halted.

* `E,<counter number>` Event id with the associated counter number
* `A,<actiontype>,<actiondata>`  An action with an action type and its associated action data.  Every action has a different set of data.  Like to print a message will have some text, or to update a flag will have the flag number and its boolean value. See Triggers for all actions

Here is an example of an Event
```
E,0
A, PR, You have run out of time
A, SC
A, QU
```
Event 0, (Counter 0), prints a message, displays the score and quits the game

## Conditions

Conditions are requirements that are to be met or be true if the associated task is to be done.  All conditions must start with an '*' astericks.  And if no condition is needed then it will just have an '*'.  There are six types of conditions that can be checked.  They are

```
Cx ......... Carrying object x
Fx ......... Flag x
Lx ......... at Location x
Ox ......... Object x at current location
Rx ......... Random chance of being true where x is whole number between 1-100
Wx ......... Wearing object x
Vx ......... Visited location x
```
'x' represents a number.  These conditions can be joined with **AND**, **OR** and **NOT** statements and also surrounded with brackets.  An **AND** is represented by a **.** full stop character, an **OR** with a **/** forward slash character and a **NOT** by a **-** minus character.  An example of a more complicated condition is.
```
.-((C4.C5)/(C4.C6.W7/C7))
```
For this condition to be met the player must not be carrying object 4 and not object 5 or not carrying object 4 and not object 6 and not wearing object 7 or carrying object 7.  Conditions can be as compllicated as you need them.

## Example Game

Please have a look at **witch_hunt_aks.csv** for an example on how to use all the AKS elements to create an adventure game.

# REQUIREMENTS:

* ruby 1.9 or maybe higher?

## SETUP and FILE DESCRIPTIONS

* **lib** - source code
* **bin** - game files
* **amstrad** - original Amstrad Basic AKS system and AKS system with game data.

## PLAY THE GAME

```
$cd bin
$ruby adventure.rb <game data.csv>
```

To run the example game call `$ruby adventure.rb witch_hunt_aks.csv`

## WRITE YOUR OWN ADVENTURE PROGRAM - USBORNE PUBLISHING 
### By Jenny Tyler and Les Howarth - ISBN 0 86020 741 2

Usborne Publishing printed a book in the 80's on how to write your own adventure games written in Basic.  I've been facinated by this book and have made some attempts to convert this game into more modern code.  One recent convertion is to write the game using [Scratch](https://scratch.mit.edu/projects/130894359/).

I have also converted this game to use AKS.  You can now play this game using this game engine.  The game has simple descriptions and a fairly easy game to solve.  I've made some small changes to the origial AKS to include features needed for this game, like randomness, teleporting the player, halting and resuming timers and scoring on carried objects.

To play this game call `$ruby adventure.rb haunted_house_aks.csv`

I've also include a walkthrough just incase.
