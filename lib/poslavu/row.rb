require "nokogiri"

# The POSLavu API principally operates on database rows exchanged in
# XML fragments. These are encapsulated as POSLavu::Row objects, which
# is really just a Hash with some additional methods.
class POSLavu::Row < Hash
  # Instantiate a Row, optionally copying an existing Hash.
  def initialize(hash_to_copy = nil)
    if hash_to_copy
      hash_to_copy.each { |key,value|
        self[key.to_sym] = value.to_s
      }
    end
  end
  
  # Instantiate a Row given a string containing a <tt><row/></tt> XML fragment.
  # This XML fragment must contain exactly one <tt><row></tt> element at the root.
  def self.from_xml(string)
    fragment = Nokogiri::XML.fragment(string)
    from_nokogiri(fragment)
  end
  
  # Instantiate a Row from a Nokogiri::XML::Node or similar. If you're using
  # the public interface, you shouldn't ever need to call this.
  def self.from_nokogiri(xml)   # :nodoc:
    raise ArgumentError, "argument is not a Nokogiri node" unless xml.kind_of?(Nokogiri::XML::Node)
    
    if xml.element? && xml.name == 'row'
      xml_row = xml
    else
      rows = xml.xpath('./row')
      raise ArgumentError, "argument does not directly contain a <row> element" if rows.empty?
      raise ArgumentError, "argument contains more than one <row> element" if rows.size > 1
      
      xml_row = rows.first
    end
    
    new.tap { |row|
      xml_row.element_children.each { |element|
        row[element.name.to_sym] = element.text
      }
    }
  end
  
  # Adds this Row to a Nokogiri::XML::Node. If you're using the public
  # interface, you shouldn't ever need to call this.
  def to_nokogiri(doc)  # :nodoc:
    row = doc.create_element('row'); doc.add_child(row)
    each { |key,value|
      element = doc.create_element(key.to_s)
      element.add_child(doc.create_text_node(value.to_s))
      row.add_child(element)
    }
    row
  end

  # Transform this Row into a string containing a <tt><row/></tt> XML fragment
  def to_xml
    doc = Nokogiri::XML::Document.new
    element = to_nokogiri(doc)
    element.to_s
  end
end
