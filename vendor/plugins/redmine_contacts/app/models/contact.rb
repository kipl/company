class Contact < ActiveRecord::Base
unloadable
belongs_to :project
has_many :moa
has_many :customer


has_many :notes, :as => :source, :dependent => :delete_all, :order => "created_on DESC"
has_many :tags, :through => :taggings, :uniq => true
has_many :taggings, :dependent => :delete_all, :as => :container
belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
has_and_belongs_to_many :issues, :order => "#{Issue.table_name}.due_date", :uniq => true
has_and_belongs_to_many :deals, :order => "#{Deal.table_name}.status_id"
belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'


attr_accessor :tag_names
attr_accessor :phones
attr_accessor :emails
VALID_GENDERS = ["Male", "Female"]
VALID_MARITALSTATUS = ["Unmarried", "Married","Divorced"]
VALID_STATUS = ["Pending", "Approved"]
after_save :assign_tags
# before_save :assign_phone

acts_as_watchable

acts_as_attachable :view_permission => :view_contacts,
:delete_permission => :edit_contacts

# acts_as_activity_provider :type => 'contacts',
# :timestamp => "#{Contact.table_name}.created_on",
# :author_key => "#{Contact.table_name}.author_id",
# :permission => :view_contacts

acts_as_event :datetime => :created_on,
:url => Proc.new {|o| {:controller => 'contacts', :action => 'show', :id => o}},
:type => Proc.new {|o| 'contact' },
:title => Proc.new {|o| o.name },
:description => Proc.new {|o| o.notes }

named_scope :visible, lambda {|*args| { :include => :project,
:conditions => Project.allowed_to_condition(args.first || User.current, :view_contacts) } }


# name or company is mandatory
validates_presence_of :first_name
validates_uniqueness_of :first_name, :scope => [:last_name, :middle_name, :company]
validates_inclusion_of :gender,
                        :in => VALID_GENDERS,
                        :allow_nil => false
validates_inclusion_of :maritalstatus,
                        :in => VALID_MARITALSTATUS,
                        :allow_nil => false                        

validates_inclusion_of :status,
                        :in => VALID_STATUS,
                        :allow_nil => false 
                               
def visible?(usr=nil)
(usr || User.current).allowed_to?(:view_contacts, self.project)
end

def name
result = []
if !self.is_company
[self.first_name, self.middle_name, self.last_name].each {|field| result << field unless field.blank?}
else
result << self.first_name
end
return result.join(" ")
end

 
def tag_names
@tag_names || tags.map(&:name).join(', ')
end

def phones
@phones || self.phone ? self.phone.split( /, */) : []
end

def emails
@emails || self.email ? self.email.split( /, */) : []
end


private

def assign_phone
if @phones
self.phone = @phones.uniq.map {|s| s.strip.delete(',').squeeze(" ")}.join(', ')
end
end

def assign_tags
if @tag_names
self.tags = @tag_names.mb_chars.downcase.to_s.squeeze(" ").strip.squeeze(",").strip.split( /, */).map { |s| s.strip unless s.blank?}.compact.uniq.map do |name|
Tag.find_or_create_by_name(name)
end
end
end

end
