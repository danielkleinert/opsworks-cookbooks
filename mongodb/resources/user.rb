actions :add, :delete, :update
#undefined method `default_action' for #<Class:0x7f67e3f2f2e0>
#default_action :add

attribute :name, :name_attribute => true, :kind_of => String, :required => true
attribute :password, :kind_of => String, :required => true
attribute :database, :kind_of => String, :required => true
