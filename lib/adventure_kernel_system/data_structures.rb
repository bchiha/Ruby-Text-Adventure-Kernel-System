module Aks

	Description = Struct.new(:condition, :text)
	Connection = Struct.new(:direction, :condition, :location)
	Trigger = Struct.new(:wordlist, :condition)
	Action = Struct.new(:type, :fnum, :flagstatus, :direction, :cnum, :int, :obj, :loc, :text)
	Name = Struct.new(:namelist, :condition)
	Suitability = Struct.new(:action, :condition, :text)
	
end