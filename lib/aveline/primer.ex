defmodule Aveline.Primer do
  @moduledoc """
  Aveline's base doc, the "primer": how Aveline works, the words a person
  says to their agent, tags, and what to tell a person on a first session.

  Served live by GET /api/workspaces/:slug/orientation as `primer`, ahead
  of the workspace's own orientation doc (`doc`), so every agent in every
  workspace reads the current version on its next session. Nothing is
  copied into any workspace: this module is the only copy, it changes by
  PR, and `@version` is bumped with any change to the text so the CLI can
  say once that it moved.

  Where the primer and a workspace's orientation disagree, the workspace
  doc wins; the primer says so about itself. It is called the primer in
  code and on the wire because `base_doc_id` already means a doc's
  logical id across versions.

  Every block here is asserted valid against `Aveline.Blocks.Block` by
  `Aveline.PrimerTest`, the same way the contract's examples are.
  """

  @version 1

  @doc "The primer's version. Bump it with any change to `blocks/0`."
  def version, do: @version

  @doc "The JSON-ready payload the orientation endpoint merges in."
  def payload, do: %{"version" => @version, "blocks" => blocks()}

  @person_heading "On a first session, tell the person"

  @doc "The heading of the block written for the person, for tooling and tests."
  def person_heading, do: @person_heading

  @doc "The primer as a block list, in reading order."
  def blocks do
    [
      para([
        b("Aveline, for the agent reading this. "),
        t(
          "This is Aveline's base doc, version #{@version}. Aveline serves it ahead of every workspace's own orientation, which follows it. Where the two disagree, the workspace doc wins: it is the team's rules, this is only how Aveline works. Nothing here is a rule a team cannot rewrite."
        )
      ]),
      h2("What Aveline is"),
      para([
        t(
          "A wiki for a team and its agents. Humans read and comment in the web app; agents read and write through the aveline CLI. Every doc has tags, every edit has an intent, every version is kept. Views are saved filters over tags; the pinned ones are the sidebar."
        )
      ]),
      h2("How a person hands you work"),
      para([
        t("Three words, from the person you work for. Follow the workspace doc if it defines them differently.")
      ]),
      ul([
        [
          b("BG"),
          t(
            " and what they want: file a ticket, plan it on the ticket, build it, get it reviewed, and bring them the finished pull request. One report at the end. No questions mid-way unless a guess would be unsafe. This is the default for most work."
          )
        ],
        [
          b("FG"),
          t(
            " and what they want: build it live while they watch and steer. Serve the branch, open their browser, change fast, no test suites while iterating. On \"ship\", run the checks and finish from the review step."
          )
        ],
        [b("file it"), t(" and an idea: a ticket, nothing built.")]
      ]),
      para([
        t(
          "Either way they can still ask for changes. BG is the recommendation; FG is for things they need to see to judge."
        )
      ]),
      h2("Tags"),
      para([
        t(
          "Every doc carries a few tags, and the boards are just tags grouped. A workspace set up the standard way has these; a team adds its own as it goes."
        )
      ]),
      tag_table(),
      para([
        t(
          "One tag from each family that applies. Work moves by retagging. Feedback is not its own kind of record: it rides on a ticket or an idea with a from:name tag, and the ticket's status says whether it was acted on. Tags must exist before use (aveline list-tags; create-tag with a description)."
        )
      ]),
      h2("Ideas"),
      para([
        t(
          "An idea is a one-page pitch: what and why, before anything is built. It moves through draft, in-review, approved or cancelled. Cancelled ideas stay, as the record of what was decided against. A ticket is cut from an approved idea."
        )
      ]),
      h2("Writing"),
      para([
        t(
          "Run aveline contract before your first write. New docs are born private and new views land in your personal bucket: pass --visibility workspace and --bucket team for anything the team should see. Every edit carries --intent saying why. Edit surgically with --ops; rewrite whole docs only when you mean to."
        )
      ]),
      h2("The team's rules"),
      para([
        t(
          "Everything after this doc is the team's orientation. Their rules live there; change the doc and the rules change. Read it to the end before touching anything."
        )
      ]),
      h2(@person_heading),
      para([
        t(
          "This is guidance for what you say to a person on their first session in a workspace, not a script. Write it in your own words. Under about 200 words plus the tag table. Plain, second person, no jargon, no bullet dump. Cover, in this order:"
        )
      ]),
      ol([
        [
          t(
            "Talk to me, not to Aveline: it is where the team's knowledge and work live, and you read and write it for them."
          )
        ],
        [
          t("BG, FG and file it, one sentence each; BG recommended for most things; they can still ask for changes.")
        ],
        [
          t(
            "Tags in two sentences: every doc carries a few, the boards are tags grouped; make your own as you go. Then the standard table above if the workspace was set up the standard way, or, if custom, one line: start with ticket and a status, the rest comes."
          )
        ],
        [t("An idea is a one-page pitch, what and why, before anything is built.")],
        [
          t("Their team's rules live in the orientation doc; change the doc and the rules change.")
        ],
        [t("Ask me anything about the project or the process; I will look it up.")],
        [t("What is on the board right now, or that nothing is yet.")]
      ])
    ]
  end

  defp tag_table do
    %{
      "type" => "table",
      "headers" => ["Family", "Tags"],
      "rows" => [
        [[t("Kind")], [t("ticket, idea, feedback")]],
        [[t("Ticket subtype")], [t("bug, feature, ui, refactor")]],
        [[t("Ticket status")], [t("backlog, next, in-flight, review, shipped, cancelled")]],
        [[t("Idea stage")], [t("draft, in-review, approved, cancelled")]],
        [
          [t("Yours to add")],
          [t("from:name on feedback, an area (backgammon, platform), a project (profiles)")]
        ]
      ]
    }
  end

  # ===== tiny block builders, as in Aveline.Workspaces.Template =====

  defp t(text), do: %{"text" => text}
  defp b(text), do: %{"text" => text, "marks" => ["bold"]}
  defp para(spans), do: %{"type" => "paragraph", "content" => spans}
  defp h2(text), do: %{"type" => "heading", "level" => 2, "text" => text}

  defp ul(items),
    do: %{"type" => "list", "ordered" => false, "items" => Enum.map(items, &%{"content" => &1})}

  defp ol(items),
    do: %{"type" => "list", "ordered" => true, "items" => Enum.map(items, &%{"content" => &1})}
end
