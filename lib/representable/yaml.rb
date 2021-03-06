require 'representable/hash'
require 'representable/bindings/yaml_bindings'

module Representable
  module YAML
    include Hash
    
    def self.binding_for_definition(definition)
      return CollectionBinding.new(definition)      if definition.array?
      #return HashBinding.new(definition)            if definition.hash? and not definition.options[:use_attributes] # FIXME: hate this.
      #return AttributeHashBinding.new(definition)   if definition.hash? and definition.options[:use_attributes]
      #return AttributeBinding.new(definition)       if definition.attribute
      PropertyBinding.new(definition)
    end
    
    def self.included(base)
      base.class_eval do
        include Representable
        extend ClassMethods
        #self.representation_wrap = true # let representable compute it.
      end
    end
    
    
    module ClassMethods
      # Creates a new Ruby object from XML using mapping information declared in the class.
      #
      # Accepts a block yielding the currently iterated Definition. If the block returns false 
      # the property is skipped.
      #
      # Example:
      #   band.from_xml("<band><name>Nofx</name></band>")
      def from_yaml(*args, &block)
        create_represented(*args, &block).from_yaml(*args)
      end
    end
    
    
    def from_yaml(doc, *args)
      hash = Psych.load(doc)
      from_hash(hash, *args)
    end
    
    # Returns a Nokogiri::XML object representing this object.
    def to_ast(options={})
      #root_tag = options[:wrap] || representation_wrap
      
      Psych::Nodes::Mapping.new.tap do |map|
        create_representation_with(map, options, YAML)
      end
    end
    
    def to_yaml(*args)
      stream = Psych::Nodes::Stream.new 
      stream.children << doc = Psych::Nodes::Document.new
      
      doc.children << to_ast(*args)
      stream.to_yaml
    end
  end
end
