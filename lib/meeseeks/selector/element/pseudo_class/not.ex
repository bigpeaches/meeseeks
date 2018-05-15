defmodule Meeseeks.Selector.Element.PseudoClass.Not do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.{Document, Error, Selector}
  alias Meeseeks.Selector.Element

  defstruct args: []

  @impl true
  def match(selector, %Document.Element{} = element, document, context) do
    case selector.args do
      [[sel]] ->
        !Selector.match(sel, element, document, context)

      [selectors] when is_list(selectors) ->
        !Enum.any?(selectors, &Selector.match(&1, element, document, context))

      _ ->
        false
    end
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def validate(selector) do
    case selector.args do
      [selectors] when is_list(selectors) ->
        Enum.reduce_while(selectors, {:ok, selector}, &validate_selector/2)

      _ ->
        {:error,
         Error.new(:css_selector, :invalid, %{
           description: ":not has invalid arguments",
           selector: selector
         })}
    end
  end

  defp validate_selector(%Element{} = selector, ok) do
    cond do
      combinator?(selector) ->
        {:halt,
         {:error,
          Error.new(:css_selector, :invalid, %{
            description: ":not doesn't allow selectors containing combinators",
            selector: selector
          })}}

      contains_not_selector?(selector) ->
        {:halt,
         {:error,
          Error.new(:css_selector, :invalid, %{
            description: ":not doesn't allow selectors containing :not selectors",
            selector: selector
          })}}

      true ->
        {:cont, ok}
    end
  end

  defp combinator?(element_selector) do
    element_selector.combinator != nil
  end

  defp contains_not_selector?(element_selector) do
    Enum.any?(element_selector.selectors, &not_selector?/1)
  end

  defp not_selector?(%Element.PseudoClass.Not{}), do: true
  defp not_selector?(_), do: false
end
