#If Shoulda still has been loaded - unload it
Object.send(:remove_const, :Shoulda) rescue nil
require File.dirname(__FILE__) + '/../test'
