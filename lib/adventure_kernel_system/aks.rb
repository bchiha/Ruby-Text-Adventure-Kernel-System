module Aks
	
	require "csv"
	require "io/console"
	require 'ruby-debug'

	class GameEngine

		#constants

		def initialize
		
			#location structure
			# locations have (D)escriptions, (C)onnections and (T)riggers.  Triggers have (A)ctions
			@locations = []
			# objects have a (D)escription, a (P)lace, a (N)ame and (S)uitabilities
			@objects = []
			# events have (A)ctions
			@events = []

			@datafile = nil		#game csv data file
			@comline = ""		#input from the command line

			#game flags
			@eogame = false		#End of game flag
			@flags = []			#In game flags, 		index=flag number
			@wearing = []		#Object is worn, 		index=object number
			@visited = []		#Location visited?,		index=location number
			@counting = []		#Has a counter?,		index=counter number
			@count = []			#Counter value			index=counter number
			@score = 0			#Score
		end
		
		def run
			#initialise variables and load the adventure game from a data file
			raise ArgumentError, "Usage: $adventure <aks data file.csv>", caller if ARGV[0].nil?
			@datafile = CSV.open(ARGV[0], mode="r")
			init_locations
			init_objects
			init_events
			@datafile.close

			#main loop
			#---------
			# There are four steps here, Describe the current location, get input from the command line,
			# process the command line (do the action) and update any global timers. Do all this until
			# the end of game flag is set.

			while !@eogame
				describe_loc
				@visited[@objects[0][:place]] = true
				get_com_line
				process_com_line
				update_countdowns
			end

		end

		private
		#initialisation routines
		# The first stage of the program requires it to initialise all the variables it is going to use.
		# This is done by the three routines init_locations, init_objects, and init_events, As their names
		# suggest, they initialise all the variables associated with the locations, the objects, and the 
		# events respectively

		# init_locations loads all the location data begining with location 0 (General Actions) until all
		# locations are found.  It stops when object, event or F end marker is found.
		# Locations utilise a hash structure like so
		# {:descriptions=>[],:connections=>[],:triggers=>[]}
		def init_locations
			locationNo = 0
			locationHash = {:descriptions=>[],:connections=>[],:triggers=>[]}
			
			#read a line from the csv and check its first field (the key)
			csvLine = @datafile.readline
			while csvLine[0] != "O" && csvLine[0] != "E" && csvLine[0] != "F"
				lastLineWasAction = false
				case  csvLine[0]
				when "L" #location
					locationNo = csvLine[1].to_i 
					@locations[locationNo] = locationHash.deep_copy
				when "D" #description
					@locations[locationNo][:descriptions] << Aks::Description.new(csvLine[1],csvLine[2])
				when "C" #connection
					@locations[locationNo][:connections] << Aks::Connection.new(csvLine[1],csvLine[2],csvLine[3].to_i)
				when "T" #trigger
					lastLineWasAction = true
					triggerHash = {:trigger => Aks::Trigger.new(csvLine[1..csvLine.count-2],csvLine.last), :actions=>[]}
					# all triggers must have a subset of actions
					csvLine = @datafile.readline
					raise "Trigger must have action : csvLine " << @datafile.lineno if csvLine[0] != "A"
					while csvLine[0] == "A"
						triggerHash[:actions] << assign_action(csvLine)
						csvLine = @datafile.readline
					end
					@locations[locationNo][:triggers] << triggerHash
				else
					raise "unknown location key :" << csvLine[0] << " line number :" << @datafile.lineno
				end
				csvLine = @datafile.readline unless lastLineWasAction
			end
		end

		# init_objects loads all the object data begin with the first object 0 (The Player) until all
		# objects are found.  It stops when event or F end marker is found.
		# The player object 0 is important as this object's place will move to the location you go to.
		# Objects utilise a hash structure like so
		# {:description=>nil,:place=>nil,:name=>nil,:suitabilities=>[]}
		def init_objects
			objectNo = 0
			objectHash = {:descriptions=>[],:place=>nil,:name=>nil,:suitabilities=>[]}

			#redo current line in csv (Object 0)
			csvLine = ["O","0"]
			while csvLine[0] != "E" && csvLine[0] != "F"
				case csvLine[0]
				when "O" #object
					objectNo = csvLine[1].to_i
					@objects[objectNo] = objectHash.deep_copy
				when "D" #description
					@objects[objectNo][:descriptions] << Aks::Description.new(csvLine[1],csvLine[2])
				when "P" #place
					@objects[objectNo][:place] = csvLine[1].to_i
				when "N" #name
					@objects[objectNo][:name] = Aks::Name.new(csvLine[1..csvLine.count-2],csvLine.last)
				when "S" #suitability
					if csvLine[1] == "EX" #Examine has extra text
						@objects[objectNo][:suitabilities] << Aks::Suitability.new(csvLine[1],csvLine[2],csvLine[3])
					else #Get, Put On, Take Off, Drop
						@objects[objectNo][:suitabilities] << Aks::Suitability.new(csvLine[1],csvLine[2])
					end
				else
					raise "unknown object key :" << csvLine[0] << " line number :" << @datafile.lineno	
				end
				csvLine = @datafile.readline
			end
		end

		# init_events loads all the event data begin with the first event 0 until all
		# events are found.  It stops when a F end marker is found
		# Events utilise a hash structure like so
		# {:actions=>[]}
		def init_events
			eventNo = 0
			eventHash = {:actions=>[]}

			#redo current line in csv (Event 0)
			csvLine = ["E","0"]
			while csvLine[0] != "F"
				case csvLine[0]
				when "E" #event
					eventNo = csvLine[1].to_i
					@events[eventNo] = eventHash.deep_copy
				when "A" #action
					@events[eventNo][:actions] << assign_action(csvLine)
				else
					raise "unknown event key :" << csvLine[0] << " line number :" << @datafile.lineno
				end
				csvLine = @datafile.readline
			end
		end

		def assign_action(csvLine)
			case csvLine[1]
			when "AF" #Assign Flag
				Aks::Action.new(csvLine[1], csvLine[2].to_i, csvLine[3])
			when "DR", "EX", "GE", "IN", "LO", "PO", "QU", "SA", "SC", "TO" #Drop etc
				Aks::Action.new(csvLine[1])
			when "GO" #Go
				Aks::Action.new(csvLine[1],nil,nil,csvLine[2])
			when "HC" #Halt Counter
				Aks::Action.new(csvLine[1],nil,nil,nil,csvLine[2].to_i)
			when "IS" #Increment Score
				Aks::Action.new(csvLine[1],nil,nil,nil,nil,csvLine[2].to_i)
			when "IC" #Initialise Counter
				Aks::Action.new(csvLine[1],nil,nil,nil,csvLine[2].to_i,csvLine[3].to_i)
			when "MO" #Move Object
				Aks::Action.new(csvLine[1],nil,nil,nil,nil,nil,csvLine[2].to_i,csvLine[3].to_i)
			when "PR" #Printe
				Aks::Action.new(csvLine[1],nil,nil,nil,nil,nil,nil,nil,csvLine[2])
			when "ZI", "ZO" #Zap In / Zap Out
				Aks::Action.new(csvLine[1],nil,nil,nil,nil,nil,csvLine[2].to_i)
			else
				raise "unknown action key :" << csvLine[1] << " line number :" << @datafile.lineno
			end
		end

		#This is the routine which prints out the appropriate description for the current location, 
		#in a neat and formatted form. The first step is to find the player's current location, 
		#and then to call describe_ln, to print out the current description. We then test to see
		#if any objects are at the current location. lf there are objects here, we search through
		#all the objects, printing out the object descriptions for all objects at this location.
		def describe_loc
			puts("","",display_exits.rjust(IO.console.winsize[1],'-'),"")
			@locations[@objects[0][:place]][:descriptions].each do |desc|
				if eval_this(desc.condition)
					puts print_description(desc.text) 
				end
			end
			#print objects in current location
			objectsHere = @objects[1..@objects.count].find_all {|obj| obj[:place] == @objects[0][:place]}
			if !objectsHere.empty?
				puts("","There is/are : ")
				objectsHere.each do |obj|
					obj[:descriptions].each do |desc|
						if eval_this(desc.condition)
							puts "\t" << print_description(desc.text)
						end
					end
				end
			end
			puts
		end

		def display_exits
			exits = []
			@locations[@objects[0][:place]][:connections].each do |conn|
				if eval_this(conn.condition)
					exits << conn.direction
				end
			end
			" Exits: " << exits.join(", ") << "  "
		end

		def print_description(text)
			max_length = IO.console.winsize[1]
			result = ""
			word_array = text.split(/\s|-/)
			line = word_array.shift
			word_array.each do |word|
			  if (line + " " + word).length <= max_length
			    line << " " + word
			  elsif word.length > max_length
			    result << line + "\n" unless line.empty?
			    line = ""
			    word.each_char do |c|
			      line << c
			      if line.length == max_length
			        result << line + "\n"
			        line = ""
			      end
			    end
			  else
			    result << line + "\n"
			    line = word
			  end
			end
			result << line
		end

		#This method takes in an AKS condition and evaulates it to be either True of False
		#All expressions must have as the first character a "*" symbol.  If no other characters are found
		#then there is no condition and return true.  If characters are found they can be a in the following
		#format:
		# 	Cx ......... Carrying object x
		# 	Fx ......... Flag x
		# 	Lx ......... at Location x
		# 	Ox ......... Object x at current location
		# 	Wx ......... Wearing object x
		# 	Vx ......... Visited location x
		#
		#The first letter represents the condition type and the next is a number relating to that condition
		#So, C6 means check if the person is carrying object 6.
		#If you want to test for the inverse or NOT, then prefix the condition with a "-" minus sign
		#ln addition to the "NOT" operator, Basic conditional expressions allow the use of "AND" and "OR"
		#to construct complex tests. AKS uses the symbols "." for "AND" and "/" for "OR". To combine conditions
		#brackets () can also be used.  Here is a complicated condition
		# => *-((C4.C5)/(C4.C6.W7/C7))
		#AKS evaluates conditional expressions starting with the highest priority operators first unless
		#brackets specify otherwise.  The priority of operators in descending order are:
		# - (not), / (or), . (and). So in the above example the order of evaluation is:
		# <a> (C4. C5)
		# <b> W7/C7 	"/" is higher than "."
		# <c> C4.C6
		# <d> result of <c> . result of <b>
		# <e> result of <a> / result of <d>
		# <f> - result of <e>
		#
		# Fortunately Ruby can simply convert a given condition to what Ruby likes and evaluate it. So
		# a condition like '-(W3/C3).V12' could be turned into '!(@wearing[3] || @carrying[3]) && @visited[12]'
		def eval_this(condition)
			raise "condition doesn't start with * [" << condition << "]" if condition[0] != "*"
			return true if condition.length == 1
			cond = condition.upcase.split(//)
			charPos=0
			maxPos=cond.size
			evalStr = ""
			#test every character and convert it to something useful
			while charPos < maxPos
				#get number if condition
				char = cond[charPos]
				if "CFLOWV".include?(char)
					ref = ""
					while charPos+1 != maxPos && cond[charPos+1].is_number?
						ref += cond[charPos+1]
						charPos += 1
					end
				end
				case char
				when "*" # ignore
					evalStr = evalStr
				when "-" # !
					evalStr << " not "
				when "." # &&
					evalStr << " and "
				when "/" # ||
					evalStr << " or "
				when "(", ")" # ()
					evalStr << char
				when "C" # Carrying
					evalStr << "@objects[" << ref << "][:place] == 0"
				when "F" # Flag
					evalStr << "@flags[" << ref << "] == true"
				when "L" # Location
					evalStr << "@objects[0][:place] == " << ref
				when "O" # Object at current location
					evalStr << "@objects[" << ref << "][:place] == @objects[0][:place]"
				when "W" # Wearing
					evalStr << "@wearing[" << ref << "] == true"
				when "V" # Visited location
					evalStr << "@visited[" << ref << "] == true"
				else
					raise "unknown expression value ? " << cond[charPos]
				end
				charPos += 1
			end
			#evaluate the expression and return the result
			begin
				eval(evalStr)
			rescue SyntaxError
				puts "Something went wrong with a condition. Check out : " << condition
				raise	
			end
		end

		#get input from the player
		def get_com_line
			@comline = (print "What now ? "; $stdin.gets.rstrip)
		end

		#process the input from the player.  This first looks at the location triggers, then the standard
		#location 0 triggers.  Triggers are things that you type in.  They are either complete phrases or
		#an action with an object.  EG: 'ring bell' or 'east'.
		#We first check triggers at the location, if not found then check location 0 (global triggers).
		#If a trigger is found then do an action if possible, otherwise display an 'unknown input message'.
		#If a trigger includes an object, then the action will search for the object, using its name and
		#check its suitability.  Not all objects can be manipulated.
		def process_com_line
			#check current location for matching trigger and its condition is true
			triggerFound = nil
			@locations[@objects[0][:place]][:triggers].each do |trig|
				trig[:trigger].wordlist.each do |word|
					if @comline.pad(2).include?(word.pad(2))
						if eval_this(trig[:trigger].condition)
							triggerFound = trig
							break
						end
					end
				end
				break if triggerFound
			end
			#check global location for matching trigger and its condition is true
			if !triggerFound
				@locations[0][:triggers].each do |trig|
					trig[:trigger].wordlist.each do |word|
						if @comline.pad(2).include?(word.pad(2))
							if eval_this(trig[:trigger].condition)
								triggerFound = trig
								break
							end
						end
					end
				break if triggerFound
			    end
			end
			#if trigger found then check its actions otherwise print message
			if triggerFound
				process_action(triggerFound)
			else
				puts("", "Sorry, I do not understand that.")
			end
		end

		#process an action based on a trigger.  Each trigger must have atleast one action.
		#go through these actions and do them.  Some actions require an object like a 'hat',
		#find this object and check its suitability for the required action.
		def process_action(trigger)
			#process all actions with this trigger
			trigger[:actions].each do |act|
				case act.type
				when "SC" #Score
					puts("","You have scored " << @score.to_s << " points")
				when "IN" #Inventory
					objCarrying = @objects[1..@objects.count].find_all {|obj| obj[:place] == 0}
					if objCarrying.empty?
						puts("","You are not carrying anything.")
					else
						puts("","You are carrying : ")
						objCarrying.each do |obj|
							obj[:descriptions].each do |desc|
								if eval_this(desc.condition)
									#check if worn
									worn = @wearing[@objects.find_index(obj)] == true ? " (worn)" : ""
									puts "\t" << print_description(desc.text) << worn
								end
							end
						end
					end
				when "QU" #Quit
					response = (print "Are you sure (Y/N) ? "; $stdin.gets.rstrip.upcase)
					if response == "Y" then
						@eogame = true
					end
				when "IS" #Increment Score
					@score += act.int
				when "AF" #Assign Flag
					@flags[act.fnum] = act.flagstatus == "T" ? true : false
				when "PR" #Print
					puts("",print_description(act.text))
				when "GO" #Go
					goodConnection = @locations[@objects[0][:place]][:connections].find do |conn|
						conn.direction == act.direction
					end
					if goodConnection
						if eval_this(goodConnection.condition)
							@objects[0][:place] = goodConnection.location
						end
					else
						puts("","You can not go that way.")
					end
				when "MO" #Move Object
					@objects[act.obj][:place] = act.loc
					@wearing[act.obj] = false
				when "GE" #Get
					obj_id = assign_object(act.type)
					unless obj_id.nil?
						if @objects[obj_id][:place] == @objects[0][:place]
							@objects[obj_id][:place] = 0
							puts("","Taken.")
						else
							puts("","You can not see it here.")
						end
					end
				when "DR" #Drop
					obj_id = assign_object(act.type)
					unless obj_id.nil?
						if @objects[obj_id][:place] == 0
							@objects[obj_id][:place] = @objects[0][:place]
							@wearing[obj_id] = false
							puts("","Dropped.")
						else
							puts("","You do not have it.")
						end
					end
				when "PO" #Put On
					obj_id = assign_object(act.type)
					unless obj_id.nil?
						if @objects[obj_id][:place] == 0
							@wearing[obj_id] = true
							puts("","Worn.")
						else
							puts("","You do not have it.")
						end
					end
				when "TO" #Take Off
					obj_id = assign_object(act.type)
					unless obj_id.nil?
						if @wearing[obj_id] == true
							@wearing[obj_id] = false
							puts("","Removed.")
						else
							puts("","You are not wearing it.")
						end
					end
				when "EX" #Examine
					obj_id = assign_object(act.type)
					unless obj_id.nil?
						if @objects[obj_id][:place] == 0 && @objects[obj_id][:place] == @objects[0][:place]
							puts("","You see nothing special.")
						else
							suit = @objects[obj_id][:suitabilities].find {|suit| suit.action == "EX"}
							#if here suit must be found
							puts("",print_description(suit.text))
						end
					end
				when "IC" #Initialise 
					@counting[act.cnum] = true
					@count[act.cnum] = act.int
				when "HC" #Halt Counter
					@counting[act.cnum] = false
				when "ZI" #Zap In
					@objects[act.obj][:place] = @objects[0][:place] #current location
					@wearing[act.obj] = false
				when "ZO" #Zap Out
					@objects[act.obj][:place] = -1 #nowhere
					@wearing[act.obj] = false
				when "LO" #Load
					puts("","Sorry, this feature isn't implemented...")
				when "SA" #Save
					puts("","Sorry, this feature isn't implemented...")
				else
					raise "unknown action type ? " << act.type
				end

			end
		end

		#assign object is similar to process com line.  It looks at @comline and find a matching object
		#based on its 'name' type.  If one is found, then it looks at the action and sees if there is a 
		#suitable action for the object.  IE: if action is get, the object must be able to be picked up
		#Suitability also has a condition which needs to be met.  If all true, the object reference is 
		#returned.  actionType is one of the actions. like GE and DR etc.
		def assign_object(actionType)
			#check all objects and find a name matching what is in the command line
			suitable = false
			objectFound = nil
			@objects[1..@objects.count].each do |obj|
				obj[:name].namelist.each do |name|
					if @comline.pad(2).include?(name.pad(2))
						if eval_this(obj[:name].condition)
							objectFound = obj
							break
						end
					end
				end
				break if objectFound
			end
			#if object is found, check for suitability against actionType
			if objectFound
				objectFound[:suitabilities].each do |suit|
					if suit.action == actionType && eval_this(suit.condition)
						suitable = true
						break
					end
				end
			else
				puts("","You can't do that.")
			end
			if suitable && objectFound
				@objects.find_index(objectFound)
			else
				puts("","That is not possible.")
				nil
			end
		end

		#update countdowns finds any active countdowns set using IC type.  If countdown reaches 0
		#then do the actions associated with the countdowns event
		def update_countdowns
			@counting.each_with_index do |isCounting,i|
				@count[i] -= 1 if isCounting == true
				if @count[i] == 0
					@counting[i] = false
					process_action(@events[i])
				end
			end
		end
	end
end