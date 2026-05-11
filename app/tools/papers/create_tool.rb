# frozen_string_literal: true

module Papers
  class CreateTool < MCP::Tool
    tool_name "paper-create-tool"
    description "Create a new Paper entity"
    annotations(
      read_only_hint: false,
      destructive_hint: false,
      idempotent_hint: false,
      open_world_hint: false
    )

    input_schema(
      properties: {
        title: { type: "string" },
        authors: { type: "string" },
        abstract: { type: "string" },
        doi: { type: "string" },
        journal: { type: "string" },
        year: { type: "integer" },
        rating: { type: "integer" },
        reading_status: { type: "string" },
        notes: { type: "string" }
      },
      required: [ "title" ]
    )

    def self.call(title: nil, authors: nil, abstract: nil, doi: nil, journal: nil,
                  year: nil, rating: nil, reading_status: nil, notes: nil, server_context:)
      paper = Paper.new(
        title: title,
        authors: authors,
        abstract: abstract,
        doi: doi,
        journal: journal,
        year: year,
        rating: rating,
        reading_status: reading_status || :unread,
        notes: notes
      )

      if paper.save
        MCP::Tool::Response.new([ { type: "text", text: "Created #{paper.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Paper was not created due to: #{paper.errors.full_messages.join(', ')}" } ])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
