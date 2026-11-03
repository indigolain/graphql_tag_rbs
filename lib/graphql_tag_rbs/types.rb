# frozen_string_literal: true

module GraphqlTagRbs
  # A small RBS type AST. Every node renders itself given the indentation of
  # the line it starts on; records span several lines.
  module Types
    INDENT = "  "

    # A type written as-is, e.g. `::String`, `bool`, `untyped`, or a type alias reference.
    Named = Struct.new(:name) do
      def render(_indent) = name

      def compound? = name.match?(/[|&]/)
    end

    # A string literal type, e.g. `"User"`.
    Literal = Struct.new(:value) do
      def render(_indent) = value.dump
    end

    Optional = Struct.new(:type) do
      def render(indent)
        return type.render(indent) if type == UNTYPED

        inner = type.render(indent)
        needs_parens = type.is_a?(Union) || (type.is_a?(Named) && type.compound?)
        needs_parens ? "(#{inner})?" : "#{inner}?"
      end
    end

    ArrayOf = Struct.new(:type) do
      def render(indent) = "::Array[#{type.render(indent)}]"
    end

    Union = Struct.new(:types) do
      def self.of(types)
        unique = types.uniq
        unique.size == 1 ? unique.first : new(unique)
      end

      def render(indent) = types.map { |type| type.render(indent) }.join(" | ")
    end

    Field = Struct.new(:key, :type, :optional)

    Record = Struct.new(:fields, :key_style) do
      def render(indent)
        return "{}" if fields.empty?

        inner = indent + INDENT
        lines = fields.map { |field| "#{inner}#{key(field)}#{field.type.render(inner)}" }
        "{\n#{lines.join(",\n")}\n#{indent}}"
      end

      private

      def key(field)
        prefix = field.optional ? "?" : ""
        key_style == :symbol ? "#{prefix}#{field.key}: " : "#{prefix}#{field.key.dump} => "
      end
    end

    UNTYPED = Named.new("untyped")
  end
end
