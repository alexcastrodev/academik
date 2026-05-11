# frozen_string_literal: true

module Annotations
  class CreateTool < MCP::Tool
    tool_name "annotation-create-tool"
    description "Create a new Annotation on a paper"
    annotations(read_only_hint: false, destructive_hint: false, idempotent_hint: false, open_world_hint: false)

    input_schema(
      properties: {
        paper_id: { type: "integer" },
        page: { type: "integer" },
        selected_text: { type: "string" },
        note: { type: "string" },
        color: { type: "string" },
        start_offset: { type: "integer" },
        end_offset: { type: "integer" }
      },
      required: [ "paper_id", "page", "selected_text" ]
    )

    def self.call(paper_id: nil, page: nil, selected_text: nil, note: nil, color: nil,
                  start_offset: nil, end_offset: nil, server_context:)
      annotation = Annotation.new(
        paper_id: paper_id, page: page, selected_text: selected_text,
        note: note, color: color, start_offset: start_offset, end_offset: end_offset
      )
      if annotation.save
        MCP::Tool::Response.new([ { type: "text", text: "Created #{annotation.to_mcp_response}" } ])
      else
        MCP::Tool::Response.new([ { type: "text", text: "Annotation was not created due to: #{annotation.errors.full_messages.join(', ')}" } ])
      end
    rescue StandardError => e
      MCP::Tool::Response.new([ { type: "text", text: "An error occurred: #{e.message}" } ])
    end
  end
end
