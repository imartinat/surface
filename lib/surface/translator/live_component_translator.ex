defmodule Surface.Translator.LiveComponentTranslator do
  @moduledoc false

  alias Surface.Translator
  alias Surface.Properties
  import Surface.Translator.ComponentTranslatorHelper

  @behaviour Translator

  @impl true
  def translate(node, caller) do
    {mod_str, attributes, children, meta} = node
    %{module: mod, line: mod_line, directives: directives} = meta

    {children_props, children_contents} = translate_children(mod, attributes, directives, children, caller)
    children_props_str = ["%{", Enum.join(children_props, ", "), "}"]

    open = [
      ["<% props = ", Properties.translate_attributes(attributes, mod, mod_str, mod_line, caller), " %>"],
      add_begin_context(mod, mod_str),
      Translator.translate(children_contents, caller),
      ["<% children_props = ", children_props_str, " %>"],
      add_require(mod_str),
      add_render_call("live_component", ["@socket", mod_str, "Keyword.new(Map.merge(props, children_props))"])
    ]

    close = add_end_context(mod, mod_str)

    {open, [], close}
  end
end

