include ContactsHelper

Redmine::WikiFormatting::Macros.register do
  desc "Contact Description Macro" 
  macro :Contact_plain do |obj, args|
    args, options = extract_macro_options(args, :parent)
    raise 'No or bad arguments.' if args.size != 1
    contact = Contact.find(args.first)
    link_to_source(contact)
  end  

  desc "Contact with avatar"
  macro :Contact_avatar do |obj, args|
    args, options = extract_macro_options(args, :parent)
    raise 'No or bad arguments.' if args.size != 1
    contact = Contact.find(args.first)
    link_to avatar_to(contact, :size => "32"),  contact_url(contact), :id => "avatar", :title => contact.name
  end  

  desc "Contact with avatar"
  macro :Contact do |obj, args|
    args, options = extract_macro_options(args, :parent)
    raise 'No or bad arguments.' if args.size != 1
    contact = Contact.find(args.first)
    link_to(avatar_to(contact, :size => "16"),  contact_url(contact), :id => "avatar") + ' ' + link_to_source(contact)
  end  
  
end 
