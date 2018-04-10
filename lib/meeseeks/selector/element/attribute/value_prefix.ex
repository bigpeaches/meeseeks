defmodule Meeseeks.Selector.Element.Attribute.ValuePrefix do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.Attribute.Helpers

  defstruct attribute: nil, value: nil

  @impl true
  def match(selector, %Document.Element{} = element, _document, _context) do
    value = Helpers.get(element.attributes, selector.attribute)
    String.starts_with?(value, selector.value)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
