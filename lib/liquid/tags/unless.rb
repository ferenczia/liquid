# frozen_string_literal: true

require_relative 'if'

module Liquid
  # Unless is a conditional just like 'if' but works on the inverse logic.
  #
  #   {% unless x < 0 %} x is greater than zero {% endunless %}
  #
  class Unless < If
    def render_to_output_buffer(context, output)
      # First condition is interpreted backwards ( if not )
      first_block = @blocks.first
      result = first_block.evaluate(context)

      # if a Liquid::Drop has been given, check its to_liquid_value
      # The drop could be a BooleanDrop, and we need to evaluate its actual value
      result = result.to_liquid_value if result.is_a?(Liquid::Drop)

      unless result
        return first_block.attachment.render_to_output_buffer(context, output)
      end

      # After the first condition unless works just like if
      @blocks[1..-1].each do |block|
        result = block.evaluate(context)
        result = result.to_liquid_value if result.is_a?(Liquid::Drop)

        if result
          return block.attachment.render_to_output_buffer(context, output)
        end
      end

      output
    end
  end

  Template.register_tag('unless', Unless)
end
