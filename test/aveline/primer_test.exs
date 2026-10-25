defmodule Aveline.PrimerTest do
  @moduledoc """
  The primer is served to every agent in every workspace, so its blocks
  must be valid by the same rules as any doc, and the parts other code
  relies on must be there.
  """
  use ExUnit.Case, async: true

  alias Aveline.Blocks.Block
  alias Aveline.Primer

  test "version is a positive integer and the payload carries it" do
    assert is_integer(Primer.version()) and Primer.version() >= 1
    assert %{"version" => v, "blocks" => blocks} = Primer.payload()
    assert v == Primer.version()
    assert blocks == Primer.blocks()
  end

  test "every block validates against Block.validate/2" do
    for block <- Primer.blocks() do
      assert {:ok, _} = Block.validate(block, mint_id?: true),
             "primer block did not validate: #{inspect(block)}"
    end
  end

  test "says the workspace doc wins, and carries the block for the person" do
    text =
      Primer.blocks()
      |> Enum.flat_map(fn
        %{"type" => "heading", "text" => t} -> [t]
        %{"type" => "paragraph", "content" => spans} -> Enum.map(spans, & &1["text"])
        _ -> []
      end)
      |> Enum.join(" ")

    assert text =~ "the workspace doc wins"
    assert Enum.any?(Primer.blocks(), &(&1["type"] == "heading" and &1["text"] == Primer.person_heading()))
  end
end
