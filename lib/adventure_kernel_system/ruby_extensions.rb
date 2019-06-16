#extensions to ruby classes

class Object
	def deep_copy
  		Marshal.load(Marshal.dump(self))
	end
end

class String
  def is_number?
    true if Float(self) rescue false
  end

  def pad(spaces)
  	self.center(self.length+spaces)
  end
end