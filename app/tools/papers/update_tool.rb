# frozen_string_literal: true

module Papers
  class UpdateTool < MCP::Tool
    tool_name "paper-update-tool"
    description "Update a Paper entity of a given ID"
    annotations(
      read_only_hint: false,
      destructive_hint: false,
      idempotent_hint: true,
      open_world_hint: false
    )

    input_schema(
      properties: {
        id: { type: "integer" },
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
      required: [ "id" ]
    )

    def self.call(id:, title: MCP::EmptyProperty, authors: MCP::EmptyProperty, abstract: MCP::EmptyProperty,
                  doi: MCP::EmptyProperty, journal: MCP::EmptyProperty, year: MCP::EmptyProperty,
                  rating: MCP::EmptyProperty, reading_status: MCP::EmptyProperty, notes: MCP::EmptyProperty,
                  server_context:)
      paper = Paper.find(id)

      paper.title = title unless title == MCP::EmptyProperty
      paper.authors = authors unless authors == MCP::EmptyProperty
      paper.abstract = abstract unless abstract == MCP::EmptyProperty
      paper.doi = doi unless doi == MCP::EmptyProperty
      paper.journal = journal unless journal == MCP::EmptyProperty
      paper.year = year unless year == MCP::EmptyProperty
      paper.rating = rating unless rating == MCP::EmptyProperty
      paper.reading_status = reading_status unless reading_status == MCP::EmptyProperty
      paper.notes = notes unless notes == MCP::EmptyProperty

      if paper.save
        MCP::Tool::Response.new([ { type: "text", text: "Updated #{paper.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Paper of id = #{id} was not updated due to: #{paper.errors.full_messages.join(', ')}" } ])
      end
    rescue ActiveRecord::RecordNotFound
      MCP::Tool::Response.new([ { type: "text", text: "Paper of id = #{id} was not found" } ])
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
